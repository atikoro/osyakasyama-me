#!/usr/bin/env ruby

require "minitest/autorun"
require "open3"
require "tmpdir"

class PrepareTtsInputTest < Minitest::Test
  SCRIPT = File.expand_path("prepare_tts_input.rb", __dir__)

  def test_applies_reading_and_removes_parenthetical_variant
    Dir.mktmpdir do |dir|
      narration = File.join(dir, "narration.txt")
      dictionary = File.join(dir, "pronunciations.yaml")
      output = File.join(dir, "tts-input.txt")
      markdown = File.join(dir, "pronunciations.md")
      File.write(narration, "托鉢(たくはつ)と托鉢。\n")
      File.write(dictionary, <<~YAML)
        version: 1
        entries:
          - surface: 托鉢
            spoken: たくはつ
            variants:
              - 托鉢(たくはつ)
            note: 仏教用語
      YAML

      _stdout, stderr, status = Open3.capture3("ruby", SCRIPT, narration, dictionary, output, markdown)
      assert status.success?, stderr
      assert_equal "たくはつとたくはつ。\n", File.read(output)
      assert_includes File.read(markdown), "| 托鉢 | たくはつ | 仏教用語 |"
    end
  end

  def test_fails_when_dictionary_is_missing
    Dir.mktmpdir do |dir|
      narration = File.join(dir, "narration.txt")
      File.write(narration, "本文\n")
      _stdout, stderr, status = Open3.capture3("ruby", SCRIPT, narration, File.join(dir, "missing.yaml"), File.join(dir, "out.txt"))
      refute status.success?
      assert_includes stderr, "Pronunciation list is required"
    end
  end

  def test_fails_when_entry_is_not_in_narration
    Dir.mktmpdir do |dir|
      narration = File.join(dir, "narration.txt")
      dictionary = File.join(dir, "pronunciations.yaml")
      File.write(narration, "本文\n")
      File.write(dictionary, "version: 1\nentries:\n  - surface: 托鉢\n    spoken: たくはつ\n")
      _stdout, stderr, status = Open3.capture3("ruby", SCRIPT, narration, dictionary, File.join(dir, "out.txt"))
      refute status.success?
      assert_includes stderr, "was not found in narration"
    end
  end
end
