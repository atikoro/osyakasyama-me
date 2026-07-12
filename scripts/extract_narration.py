#!/usr/bin/env python3

from __future__ import annotations

import argparse
from pathlib import Path


def extract(markdown: str) -> str:
    lines: list[str] = []
    for line in markdown.splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            if lines and lines[-1] != "":
                lines.append("")
            continue
        lines.append(stripped)
    return "\n".join(lines).strip() + "\n"


def main() -> None:
    parser = argparse.ArgumentParser(description="Extract narration text from a Markdown script.")
    parser.add_argument("input", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()

    narration = extract(args.input.read_text(encoding="utf-8"))
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(narration, encoding="utf-8")
    print(f"Generated: {args.output}")


if __name__ == "__main__":
    main()
