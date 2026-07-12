#!/bin/sh

set -eu

if [ "$#" -lt 2 ] || [ "$#" -gt 4 ]; then
  echo "Usage: $0 INPUT_TEXT OUTPUT_MP3 [MODEL] [VOICE]" >&2
  exit 64
fi

if [ -z "${OPENAI_API_KEY:-}" ]; then
  echo "OPENAI_API_KEY is not set." >&2
  exit 78
fi

input=$1
output=$2
model=${3:-tts-1-hd}
voice=${4:-coral}

if [ ! -s "$input" ]; then
  echo "Input file is missing or empty: $input" >&2
  exit 66
fi

payload=$(mktemp "${TMPDIR:-/tmp}/podcast-tts.XXXXXX")
trap 'rm -f "$payload"' EXIT HUP INT TERM

python3 - "$input" "$model" "$voice" > "$payload" <<'PY'
import json
import sys
from pathlib import Path

input_path, model, voice = sys.argv[1:]
print(json.dumps({
    "model": model,
    "voice": voice,
    "input": Path(input_path).read_text(encoding="utf-8"),
    "response_format": "mp3",
}, ensure_ascii=False))
PY

mkdir -p "$(dirname "$output")"

http_status=$(curl --silent --show-error \
  --output "$output" \
  --write-out '%{http_code}' \
  https://api.openai.com/v1/audio/speech \
  --header "Authorization: Bearer $OPENAI_API_KEY" \
  --header 'Content-Type: application/json' \
  --data-binary "@$payload")

case "$http_status" in
  2??) ;;
  *)
    echo "OpenAI speech generation failed with HTTP $http_status." >&2
    cat "$output" >&2
    exit 1
    ;;
esac

if [ ! -s "$output" ]; then
  echo "Audio generation returned an empty file: $output" >&2
  exit 1
fi

echo "Generated: $output"
