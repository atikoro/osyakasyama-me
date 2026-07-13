#!/bin/sh

set -eu

# Validate every episode before making any billable API request.
for directory in episodes/0{02,03,04,05,06,07,08,09,10,11}-*; do
  scripts/prepare_tts_input.rb \
    "$directory/narration.txt" \
    "$directory/pronunciations.yaml" \
    "$directory/tts-input.txt" \
    "$directory/pronunciations.md"
done

for directory in episodes/0{02,03,04,05,06,07,08,09,10,11}-*; do
  episode=$(basename "$directory" | cut -d- -f1)
  source_mp3="$directory/audio/episode-$episode-source.mp3"
  output_m4a="$directory/audio/episode-$episode.m4a"
  scripts/generate_openai_tts_long.sh "$directory/narration.txt" "$source_mp3"
  scripts/optimize_podcast_audio.sh "$source_mp3" "$output_m4a"
done
