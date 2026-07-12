#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser(description="Add spoken cues for related blog entries.")
    parser.add_argument("--mapping", type=Path, default=Path("episodes/related_entries.json"))
    parser.add_argument("--episodes-dir", type=Path, default=Path("episodes"))
    args = parser.parse_args()

    mappings = json.loads(args.mapping.read_text(encoding="utf-8"))
    for episode, mapping in mappings.items():
        directory = next(args.episodes_dir.glob(f"{episode}-*"))
        narration_path = directory / "narration.txt"
        narration = narration_path.read_text(encoding="utf-8")
        cue = mapping["cue"]
        if cue in narration:
            print(f"Unchanged: {directory}")
            continue
        anchor = mapping["after"]
        if anchor not in narration:
            raise SystemExit(f"Cue anchor was not found in {narration_path}: {anchor}")
        narration = narration.replace(anchor, f"{anchor}\n\n{cue}", 1)
        narration_path.write_text(narration, encoding="utf-8")
        print(f"Updated: {directory}")


if __name__ == "__main__":
    main()
