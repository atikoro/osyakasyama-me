#!/usr/bin/env ruby

require "yaml"

abort "Usage: #{$PROGRAM_NAME} NARRATION PRONUNCIATIONS_YAML TTS_INPUT [PRONUNCIATIONS_MD]" unless (3..4).cover?(ARGV.length)

narration_path, pronunciations_path, output_path, markdown_path = ARGV
abort "Narration is missing or empty: #{narration_path}" unless File.size?(narration_path)
abort "Pronunciation list is required: #{pronunciations_path}" unless File.size?(pronunciations_path)

data = YAML.load_file(pronunciations_path)
entries = data.fetch("entries", [])
abort "Pronunciation list must contain at least one entry: #{pronunciations_path}" unless entries.is_a?(Array) && !entries.empty?

source = File.read(narration_path, encoding: "UTF-8")
replacements = []

entries.each_with_index do |entry, index|
  abort "Pronunciation entry #{index + 1} must be a mapping" unless entry.is_a?(Hash)
  surface = entry.fetch("surface", "").to_s.strip
  spoken = entry.fetch("spoken", "").to_s.strip
  abort "Pronunciation entry #{index + 1} has an empty surface" if surface.empty?
  abort "Pronunciation entry #{index + 1} (#{surface}) has an empty spoken value" if spoken.empty?

  variants = Array(entry["variants"]).map(&:to_s)
  candidates = (variants + [surface]).uniq
  unless candidates.any? { |candidate| source.include?(candidate) }
    abort "Pronunciation entry was not found in narration: #{surface}"
  end
  candidates.each { |candidate| replacements << [candidate, spoken, surface] }
end

tts_input = source.dup
applied = Hash.new(0)
replacements.sort_by { |candidate, _spoken, _surface| -candidate.length }.each do |candidate, spoken, surface|
  count = tts_input.scan(candidate).length
  next if count.zero?
  tts_input.gsub!(candidate, spoken)
  applied[surface] += count
end

missing = entries.map { |entry| entry.fetch("surface") }.reject { |surface| applied[surface].positive? }
abort "Pronunciation entries were not applied: #{missing.join(', ')}" unless missing.empty?

File.write(output_path, tts_input, encoding: "UTF-8")

if markdown_path
  rows = entries.map do |entry|
    note = entry.fetch("note", "").to_s.gsub("|", "\\|")
    "| #{entry.fetch('surface')} | #{entry.fetch('spoken')} | #{note} |"
  end
  markdown = <<~MARKDOWN
    # 発音確認リスト

    この一覧は音声生成時に必ず適用される。`pronunciations.yaml`を正本とし、このファイルは自動生成する。

    | 表記 | TTSでの読み | 備考 |
    | --- | --- | --- |
    #{rows.join("\n")}
  MARKDOWN
  File.write(markdown_path, markdown, encoding: "UTF-8")
end

puts "Prepared: #{output_path} (#{entries.length} pronunciation entries)"
