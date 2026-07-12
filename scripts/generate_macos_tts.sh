#!/bin/sh

set -eu

if [ "$#" -lt 3 ] || [ "$#" -gt 4 ]; then
  echo "Usage: $0 INPUT_TEXT OUTPUT_AUDIO VOICE [RATE]" >&2
  exit 64
fi

input=$1
output=$2
voice=$3
rate=${4:-180}

if [ ! -s "$input" ]; then
  echo "Input file is missing or empty: $input" >&2
  exit 66
fi

mkdir -p "$(dirname "$output")"
say -v "$voice" -r "$rate" -o "$output" -f "$input"

if [ ! -s "$output" ]; then
  echo "Audio generation failed: $output" >&2
  exit 1
fi

echo "Generated: $output"
