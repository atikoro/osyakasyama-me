#!/bin/sh

set -eu

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 INPUT_TEXT OUTPUT_MP3" >&2
  exit 64
fi

input=$1
output=$2
episode_dir=$(dirname "$input")
pronunciations="$episode_dir/pronunciations.yaml"
tts_input="$episode_dir/tts-input.txt"
pronunciations_md="$episode_dir/pronunciations.md"
work=$(mktemp -d "${TMPDIR:-/tmp}/podcast-long-tts.XXXXXX")
trap 'rm -rf "$work"' EXIT HUP INT TERM

scripts/prepare_tts_input.rb "$input" "$pronunciations" "$tts_input" "$pronunciations_md"

python3 - "$tts_input" "$work" "${TTS_CHUNK_CHARS:-1600}" <<'PY'
import sys
from pathlib import Path

source = Path(sys.argv[1]).read_text(encoding="utf-8")
destination = Path(sys.argv[2])
limit = int(sys.argv[3])
chunks = []
current = ""
for paragraph in (p.strip() for p in source.split("\n\n") if p.strip()):
    candidate = f"{current}\n\n{paragraph}".strip()
    if current and len(candidate) > limit:
        chunks.append(current)
        current = paragraph
    else:
        current = candidate
if current:
    chunks.append(current)
for index, chunk in enumerate(chunks, start=1):
    (destination / f"chunk-{index:03d}.txt").write_text(chunk + "\n", encoding="utf-8")
PY

: > "$work/concat.txt"
for chunk in "$work"/chunk-*.txt; do
  number=$(basename "$chunk" .txt)
  mp3="$work/$number.mp3"
  scripts/generate_openai_tts.sh "$chunk" "$mp3"
  printf "file '%s'\n" "$mp3" >> "$work/concat.txt"
done

ffmpeg -hide_banner -loglevel error -y \
  -f concat -safe 0 -i "$work/concat.txt" \
  -c:a libmp3lame -b:a 160k \
  "$output"
echo "Generated: $output"
