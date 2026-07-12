#!/usr/bin/env ruby

require "fileutils"
require "json"
require "rexml/document"
require "time"
require "yaml"

ROOT = File.expand_path("..", __dir__)
CONFIG_PATH = File.join(ROOT, "podcast", "feed-config.yaml")
OUTPUT_PATH = File.join(ROOT, "podcast", "feed.xml")
RELATED_ENTRIES_PATH = File.join(ROOT, "episodes", "related_entries.json")

def load_yaml(path)
  YAML.safe_load(File.read(path), aliases: false)
end

def require_value(hash, key, source)
  value = hash[key]
  abort "Missing #{key} in #{source}" if value.nil? || value.to_s.empty?
  value
end

config = load_yaml(CONFIG_PATH)
related_entries = File.file?(RELATED_ENTRIES_PATH) ? JSON.parse(File.read(RELATED_ENTRIES_PATH)) : {}
episode_paths = Dir.glob(File.join(ROOT, "episodes", "*", "metadata.yaml")).sort
abort "No episode metadata found" if episode_paths.empty?

episodes = episode_paths.each_with_object([]) do |path, approved|
  metadata = load_yaml(path)
  next unless ["audio_approved", "published"].include?(metadata["status"])

  audio = require_value(metadata, "audio", path)
  relative_audio_path = require_value(audio, "file", path)
  local_audio_path = File.expand_path(relative_audio_path, File.dirname(path))
  abort "Audio file not found: #{local_audio_path}" unless File.file?(local_audio_path)

  published_at = require_value(metadata, "published_at", path)
  approved << metadata.merge(
    "metadata_path" => path,
    "local_audio_path" => local_audio_path,
    "published_at" => published_at,
  )
end

abort "No approved episodes found" if episodes.empty?

document = REXML::Document.new
document << REXML::XMLDecl.new("1.0", "UTF-8")
rss = document.add_element(
  "rss",
  {
    "version" => "2.0",
    "xmlns:itunes" => "http://www.itunes.com/dtds/podcast-1.0.dtd",
    "xmlns:content" => "http://purl.org/rss/1.0/modules/content/",
    "xmlns:atom" => "http://www.w3.org/2005/Atom",
  },
)
channel = rss.add_element("channel")

channel.add_element("title").text = require_value(config, "title", CONFIG_PATH)
channel.add_element("link").text = require_value(config, "site_url", CONFIG_PATH)
channel.add_element("description").text = require_value(config, "description", CONFIG_PATH)
channel.add_element("language").text = require_value(config, "language", CONFIG_PATH)
channel.add_element("copyright").text = require_value(config, "copyright", CONFIG_PATH)
channel.add_element("lastBuildDate").text = Time.now.rfc2822
channel.add_element("atom:link", {
  "href" => require_value(config, "feed_url", CONFIG_PATH),
  "rel" => "self",
  "type" => "application/rss+xml",
})
channel.add_element("itunes:author").text = require_value(config, "author", CONFIG_PATH)
channel.add_element("itunes:summary").text = config["description"]
channel.add_element("itunes:explicit").text = config["explicit"] ? "true" : "false"
channel.add_element("itunes:type").text = "episodic"
channel.add_element("itunes:image", { "href" => require_value(config, "cover_url", CONFIG_PATH) })
category = channel.add_element("itunes:category", { "text" => require_value(config, "category", CONFIG_PATH) })
category.add_element("itunes:category", { "text" => config["subcategory"] }) if config["subcategory"]

episodes.sort_by { |episode| Time.parse(episode["published_at"]) }.reverse_each do |episode|
  source = require_value(episode, "source", episode["metadata_path"])
  audio = episode["audio"]
  audio_filename = File.basename(audio["file"])
  audio_url = "#{config['audio_base_url']}/#{audio_filename}"
  published_at = Time.parse(episode["published_at"])

  item = channel.add_element("item")
  item.add_element("title").text = require_value(episode, "title", episode["metadata_path"])
  item.add_element("link").text = require_value(source, "url", episode["metadata_path"])
  item.add_element("description").text = require_value(episode, "description", episode["metadata_path"])
  related = related_entries.fetch(episode["episode"].to_s.rjust(3, "0"), {})
  related_text = related.fetch("entries", []).map { |title, url| "#{title}: #{url}" }.join(" / ")
  item.add_element("content:encoded").text = [
    episode["description"],
    "原文: #{source['url']}",
    related_text.empty? ? nil : "関連記事: #{related_text}",
    episode["credits"],
    "ライセンス: #{source['license_url']}",
  ].compact.join(" ")
  item.add_element("pubDate").text = published_at.rfc2822
  item.add_element("guid", { "isPermaLink" => "false" }).text = "osyakasyama-me:podcast:#{episode['id']}"
  item.add_element("enclosure", {
    "url" => audio_url,
    "length" => File.size(episode["local_audio_path"]).to_s,
    "type" => audio["mime_type"],
  })
  item.add_element("itunes:author").text = config["author"]
  item.add_element("itunes:episode").text = episode["episode"].to_s
  item.add_element("itunes:episodeType").text = "full"
  item.add_element("itunes:explicit").text = episode["explicit"] ? "true" : "false"
  item.add_element("itunes:duration").text = audio["duration_seconds"].round.to_s
end

formatter = REXML::Formatters::Pretty.new(2)
formatter.compact = true
output = String.new
formatter.write(document, output)
output << "\n"

FileUtils.mkdir_p(File.dirname(OUTPUT_PATH))
File.write(OUTPUT_PATH, output)
puts "Generated: #{OUTPUT_PATH}"
