#!/usr/bin/env ruby

require "cgi"
require "json"
require "time"
require "yaml"

ROOT = File.expand_path("..", __dir__)
OUTPUT_PATH = File.join(ROOT, "podcast", "index.html")
RELATED_ENTRIES_PATH = File.join(ROOT, "episodes", "related_entries.json")

def load_yaml(path)
  YAML.safe_load(File.read(path), aliases: false)
end

def h(value)
  CGI.escapeHTML(value.to_s)
end

def duration(seconds)
  total = seconds.to_f.round
  format("%d:%02d", total / 60, total % 60)
end

episodes = Dir.glob(File.join(ROOT, "episodes", "*", "metadata.yaml")).sort.each_with_object([]) do |path, approved|
  metadata = load_yaml(path)
  next unless ["audio_approved", "published"].include?(metadata["status"])

  approved << metadata
end

abort "No approved episodes found" if episodes.empty?
related_entries = File.file?(RELATED_ENTRIES_PATH) ? JSON.parse(File.read(RELATED_ENTRIES_PATH)) : {}

items = episodes.sort_by { |episode| episode["episode"].to_i }.reverse.map do |episode|
  source = episode.fetch("source")
  audio = episode.fetch("audio")
  audio_filename = File.basename(audio.fetch("file"))
  related = related_entries.fetch(episode["episode"].to_s.rjust(3, "0"), {})
  related_html = related.fetch("entries", []).map do |title, url|
    %(<li><a href="#{h(url)}">#{h(title)}</a></li>)
  end.join("\n")
  related_section = related_html.empty? ? "" : "<h3>関連記事</h3>\n<ul>#{related_html}</ul>"

  (<<~HTML).gsub(/[ \t]+$/, "")
    <article>
      <p class="meta">Episode #{h(episode['episode'])} · #{h(duration(audio['duration_seconds']))}</p>
      <h2>#{h(episode['title'])}</h2>
      <audio controls preload="metadata" src="episodes/#{h(audio_filename)}"></audio>
      <p>#{h(episode['description'])}</p>
      <p><a href="#{h(source['url'])}">原文を読む</a></p>
      #{related_section}
    </article>
  HTML
end.join("\n")

html = <<~HTML
  <!doctype html>
  <html lang="ja">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Something like podcast</title>
    <meta name="description" content="Something like blogの記事を、できるだけ原文のまま朗読して届けるPodcast。">
    <style>
      :root { color-scheme: dark; font-family: system-ui, sans-serif; }
      body { margin: 0; background: #07101f; color: #f3ead9; }
      main { width: min(42rem, calc(100% - 2rem)); margin: 0 auto; padding: 3rem 0; }
      img { display: block; width: min(100%, 28rem); margin: 0 auto 2rem; border-radius: 1rem; }
      h1 { font-family: Georgia, serif; font-size: clamp(2rem, 8vw, 4rem); line-height: 1; }
      article { margin-top: 3rem; padding-top: 2rem; border-top: 1px solid #4e5360; }
      audio { width: 100%; margin: 1rem 0; }
      a { color: #ff6841; }
      .meta { color: #b7b8bc; }
    </style>
  </head>
  <body>
    <main>
      <img src="cover.jpg" alt="Something like podcast カバー">
      <h1>Something like podcast</h1>
      <p>Something like blogの記事を、できるだけ原文のまま朗読して届けるPodcast。</p>
      <p><a href="feed.xml">Podcast RSSを購読</a></p>

  #{items}
    </main>
  </body>
  </html>
HTML

File.write(OUTPUT_PATH, html)
puts "Generated: #{OUTPUT_PATH}"
