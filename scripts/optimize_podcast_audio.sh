#!/bin/sh

set -eu

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 INPUT_AUDIO OUTPUT_M4A" >&2
  exit 64
fi

input=$1
output=$2

if [ ! -s "$input" ]; then
  echo "Input file is missing or empty: $input" >&2
  exit 66
fi

command -v ffmpeg >/dev/null 2>&1 || {
  echo "ffmpeg is required." >&2
  exit 69
}

mkdir -p "$(dirname "$output")"

ffmpeg -hide_banner -loglevel error -y \
  -i "$input" \
  -map_metadata -1 \
  -af "loudnorm=I=-16:TP=-3.5:LRA=11" \
  -ar 24000 \
  -ac 1 \
  -c:a aac \
  -b:a 64k \
  -movflags +faststart \
  -metadata media_type=podcast \
  "$output"

if [ ! -s "$output" ]; then
  echo "Audio optimization failed: $output" >&2
  exit 1
fi

echo "Generated: $output"
