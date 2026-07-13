#!/bin/sh

set -eu

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
  echo "Usage: $0 INPUT_AUDIO OUTPUT_DIR [MODEL]" >&2
  exit 64
fi

if [ -z "${OPENAI_API_KEY:-}" ]; then
  echo "OPENAI_API_KEY is not set." >&2
  exit 78
fi

input=$1
output_dir=$2
model=${3:-gpt-4o-transcribe}
language=${TRANSCRIPTION_LANGUAGE:-ja}
prompt=${TRANSCRIPTION_PROMPT:-聞こえた内容を省略せず文字起こししてください。}
chunk_seconds=${TRANSCRIPTION_CHUNK_SECONDS:-120}
overlap_seconds=${TRANSCRIPTION_OVERLAP_SECONDS:-2}

if [ ! -s "$input" ]; then
  echo "Input audio is missing or empty: $input" >&2
  exit 66
fi

for command in curl ffmpeg ffprobe python3; do
  if ! command -v "$command" >/dev/null 2>&1; then
    echo "Required command is unavailable: $command" >&2
    exit 69
  fi
done

work=$(mktemp -d "${TMPDIR:-/tmp}/podcast-transcription.XXXXXX")
trap 'rm -rf "$work"' EXIT HUP INT TERM
mkdir -p "$output_dir/chunks"

duration=$(ffprobe -v error -show_entries format=duration \
  -of default=noprint_wrappers=1:nokey=1 "$input")

python3 - "$duration" "$chunk_seconds" <<'PY' > "$work/starts.txt"
import math
import sys

duration = float(sys.argv[1])
step = int(sys.argv[2])
for start in range(0, math.ceil(duration), step):
    print(start)
PY

while IFS= read -r start; do
  name=$(printf 'chunk-%06d' "$start")
  audio="$work/$name.mp3"
  response="$output_dir/chunks/$name.json"

  ffmpeg -hide_banner -loglevel error -y \
    -ss "$start" -t "$((chunk_seconds + overlap_seconds))" -i "$input" \
    -ac 1 -ar 24000 -b:a 64k "$audio"

  http_status=$(curl --silent --show-error \
    --output "$response" \
    --write-out '%{http_code}' \
    https://api.openai.com/v1/audio/transcriptions \
    --header "Authorization: Bearer $OPENAI_API_KEY" \
    --form "file=@$audio" \
    --form "model=$model" \
    --form "language=$language" \
    --form 'response_format=json' \
    --form "prompt=$prompt")

  case "$http_status" in
    2??) ;;
    *)
      echo "OpenAI transcription failed with HTTP $http_status." >&2
      cat "$response" >&2
      exit 1
      ;;
  esac
done < "$work/starts.txt"

python3 - "$input" "$output_dir" "$model" "$language" \
  "$chunk_seconds" "$overlap_seconds" "$work/starts.txt" <<'PY'
import json
import sys
from pathlib import Path

input_path, output_dir, model, language, chunk_seconds, overlap_seconds, starts_path = sys.argv[1:]
output = Path(output_dir)
lines = [
    "# 音声文字起こし",
    "",
    f"- 対象: `{input_path}`",
    f"- モデル: `{model}`",
    f"- 言語: `{language}`",
    f"- 分割: {chunk_seconds}秒ごと、末尾{overlap_seconds}秒を次区間と重複",
    "- 注意: 分割境界の文章は重複する場合があります。",
    "",
]

starts = (int(value) for value in Path(starts_path).read_text().splitlines())
for start in starts:
    path = output / "chunks" / f"chunk-{start:06d}.json"
    data = json.loads(path.read_text(encoding="utf-8"))
    text = data.get("text")
    if not isinstance(text, str):
        raise SystemExit(f"Transcription response has no text: {path}")
    lines.extend((f"## {start // 60:02d}:{start % 60:02d}〜", "", text.strip(), ""))

(output / "transcription.md").write_text("\n".join(lines), encoding="utf-8")
PY

echo "Generated: $output_dir/transcription.md"
