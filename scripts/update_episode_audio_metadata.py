#!/usr/bin/env python3

from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
from pathlib import Path


def command(*args: str) -> str:
    return subprocess.run(args, check=True, text=True, capture_output=True).stdout


def loudness(path: Path) -> tuple[float, float]:
    process = subprocess.run(
        [
            "ffmpeg", "-hide_banner", "-nostats", "-i", str(path),
            "-af", "loudnorm=I=-16:TP=-1:LRA=11:print_format=json",
            "-f", "null", "-",
        ],
        check=True,
        text=True,
        capture_output=True,
    )
    match = re.search(r"\{.*?\}", process.stderr, re.DOTALL)
    if not match:
        raise RuntimeError(f"Loudness data was not found for {path}")
    data = json.loads(match.group(0))
    return float(data["input_i"]), float(data["input_tp"])


def main() -> None:
    parser = argparse.ArgumentParser(description="Update draft episode metadata from a generated M4A file.")
    parser.add_argument("episode_dir", type=Path)
    parser.add_argument("--status", default="audio_generated")
    parser.add_argument("--metadata-only", action="store_true")
    args = parser.parse_args()

    metadata_path = args.episode_dir / "metadata.yaml"
    readme_path = args.episode_dir / "README.md"
    episode = args.episode_dir.name.split("-", 1)[0]
    audio_path = args.episode_dir / "audio" / f"episode-{episode}.m4a"

    probe = json.loads(command(
        "ffprobe", "-v", "error", "-select_streams", "a:0",
        "-show_entries", "stream=codec_name,sample_rate,channels,bit_rate,duration",
        "-of", "json", str(audio_path),
    ))["streams"][0]
    integrated, true_peak = loudness(audio_path)
    digest = hashlib.sha256(audio_path.read_bytes()).hexdigest()

    text = metadata_path.read_text(encoding="utf-8")
    text = re.sub(r"^status: .*?$", f"status: {args.status}", text, flags=re.MULTILINE)
    text = re.sub(
        r"^  duration_seconds:.*?(?=^  review:)",
        (
            f"  duration_seconds: {float(probe['duration']):.3f}\n"
            f"  sample_rate_hz: {probe['sample_rate']}\n"
            f"  channels: {probe['channels']}\n"
            f"  bitrate_bps: {probe['bit_rate']}\n"
            f"  size_bytes: {audio_path.stat().st_size}\n"
            f"  sha256: {digest}\n"
            f"  loudness_lufs: {integrated:.2f}\n"
            f"  true_peak_dbtp: {true_peak:.2f}\n"
            "  mime_type: audio/mp4\n"
        ),
        text,
        flags=re.MULTILINE | re.DOTALL,
    )
    metadata_path.write_text(text, encoding="utf-8")

    if args.metadata_only:
        print(f"Updated: {args.episode_dir}")
        return

    readme = readme_path.read_text(encoding="utf-8")
    readme = readme.replace("- [ ] AI音声生成", "- [x] AI音声生成")
    readme = readme.replace("- [ ] 配信用M4A生成", "- [x] 配信用M4A生成")
    readme = re.sub(r"\n## 生成結果\n.*\Z", "", readme, flags=re.DOTALL)
    readme += (
        "\n## 生成結果\n\n"
        f"- ファイル: `audio/episode-{episode}.m4a`\n"
        f"- 再生時間: {float(probe['duration']) / 60:.1f}分\n"
        f"- ファイルサイズ: {audio_path.stat().st_size:,} bytes\n"
        f"- Integrated loudness: {integrated:.2f} LUFS\n"
        f"- True peak: {true_peak:.2f} dBTP\n"
        "- 状態: 試聴・原文照合前。GitHub Pagesには未公開。\n"
    )
    readme_path.write_text(readme, encoding="utf-8")
    print(f"Updated: {args.episode_dir}")


if __name__ == "__main__":
    main()
