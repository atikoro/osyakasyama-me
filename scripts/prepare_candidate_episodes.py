#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


def yaml_string(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def clean_source(text: str, source_key: str) -> str:
    paragraphs = [paragraph.strip() for paragraph in text.split("\n\n") if paragraph.strip()]
    paragraphs = paragraphs[3:]

    if source_key == "010-ai-slop":
        paragraphs = paragraphs[: paragraphs.index("おまけ")]

    if source_key == "011-misskey-admin-tools":
        start = next((i for i, p in enumerate(paragraphs) if p.startswith("それはさておき、Noteを消す")), None)
        end = next((i for i, p in enumerate(paragraphs) if p.startswith("以上、misskeyのnoteテーブル")), None)
        if start is not None and end is not None:
            paragraphs[start:end] = [
                "作成したスクリプトで、一定期間より古いリモートnoteを定期的に削除するようにしました。",
                "当時の環境では、一度に大量のnoteを削除すると長時間かかったため、cronを使って毎日少しずつ処理する運用に切り替えました。",
            ]

    cleaned = "\n\n".join(paragraphs)
    cleaned = re.sub(r"\(図[^)]*\)", "", cleaned)
    cleaned = cleaned.replace("WinWin", "ウィンウィン")
    cleaned = cleaned.replace("Github", "GitHub")
    return cleaned.strip()


def narration(entry: dict[str, object], body: str) -> str:
    episode = entry["episode"]
    title = entry["title"]
    source_date = entry["source_date"].replace("-", "年", 1).replace("-", "月", 1) + "日"
    return f"""Something like podcast。

この番組では、Something like blogの記事を、できるだけ原文のまま朗読してお届けします。

第{episode}話は、{source_date}に公開された「{title}」です。

{body}

今回は、Something like blogの「{title}」を、できるだけ原文のまま朗読してお届けしました。

原文へのリンクは、エピソードの説明欄に掲載しています。

原作は pleasure666。Creative Commons 表示-非営利 4.0のもとで公開されています。この音声版では、画像、コード、外部リンクなど、音声化できない箇所のみ一部調整しています。

それでは、また次回。
"""


def metadata(entry: dict[str, object]) -> str:
    tags = "\n".join(f"  - {tag}" for tag in entry["tags"])
    return f"""id: {int(entry['episode']):03d}-{entry['slug']}
episode: {entry['episode']}
title: {yaml_string(str(entry['title']))}
slug: {entry['slug']}
status: script_draft
published_at: null
source:
  title: {yaml_string(str(entry['title']))}
  author: pleasure666
  published_at: {yaml_string(str(entry['source_date']))}
  url: {yaml_string(str(entry['source_url']))}
  license: "CC BY-NC 4.0"
  license_url: "https://creativecommons.org/licenses/by-nc/4.0/"
description: {yaml_string(str(entry['description']))}
credits: >-
  原作: pleasure666「{entry['title']}」。CC BY-NC 4.0。
  画像、コード、外部リンクなど、音声化できない箇所のみ一部調整しています。
audio:
  engine: openai
  model: tts-1-hd
  voice: coral
  file: audio/episode-{int(entry['episode']):03d}.m4a
  duration_seconds: null
  mime_type: audio/mp4
  review:
    status: pending
    changes_required: null
explicit: false
tags:
{tags}
"""


def main() -> None:
    parser = argparse.ArgumentParser(description="Prepare draft podcast episodes from extracted articles.")
    parser.add_argument("source_dir", type=Path)
    parser.add_argument("--manifest", type=Path, default=Path("episodes/candidates.json"))
    parser.add_argument("--episodes-dir", type=Path, default=Path("episodes"))
    args = parser.parse_args()

    entries = json.loads(args.manifest.read_text(encoding="utf-8"))
    for entry in entries:
        source_path = args.source_dir / f"{entry['source_key']}.txt"
        if not source_path.is_file():
            raise SystemExit(f"Missing extracted article: {source_path}")

        directory = args.episodes_dir / f"{int(entry['episode']):03d}-{entry['slug']}"
        directory.mkdir(parents=True, exist_ok=True)
        (directory / "audio").mkdir(exist_ok=True)
        (directory / "source.txt").write_text(source_path.read_text(encoding="utf-8"), encoding="utf-8")
        body = clean_source(source_path.read_text(encoding="utf-8"), str(entry["source_key"]))
        (directory / "narration.txt").write_text(narration(entry, body), encoding="utf-8")
        (directory / "metadata.yaml").write_text(metadata(entry), encoding="utf-8")
        (directory / "README.md").write_text(
            f"# 第{entry['episode']}話「{entry['title']}」制作メモ\n\n"
            "- [x] 原文取得\n"
            "- [x] 音声用テキスト初稿\n"
            "- [ ] 原文との照合\n"
            "- [ ] 発音確認\n"
            "- [ ] AI音声生成\n"
            "- [ ] 試聴\n"
            "- [ ] 配信用M4A生成\n"
            "- [ ] 公開承認\n",
            encoding="utf-8",
        )
        print(f"Prepared: {directory}")


if __name__ == "__main__":
    main()
