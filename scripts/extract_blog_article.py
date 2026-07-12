#!/usr/bin/env python3

from __future__ import annotations

import argparse
from html.parser import HTMLParser
from pathlib import Path


SKIP_TAGS = {"script", "style", "nav", "iframe", "video"}
SKIP_CLASSES = {"entry-navi", "footer-content", "meta-info"}


class ArticleParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.article_depth = 0
        self.skip_depth = 0
        self.parts: list[str] = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        attributes = dict(attrs)
        classes = set((attributes.get("class") or "").split())

        if self.article_depth == 0 and tag == "article" and "content" in classes:
            self.article_depth = 1
            return

        if self.article_depth == 0:
            return

        self.article_depth += 1
        if self.skip_depth:
            self.skip_depth += 1
        elif tag in SKIP_TAGS or classes.intersection(SKIP_CLASSES):
            self.skip_depth = 1
        elif tag in {"p", "h1", "h2", "h3", "li", "blockquote", "pre", "br", "hr"}:
            self.parts.append("\n")

    def handle_endtag(self, tag: str) -> None:
        if self.article_depth == 0:
            return
        if self.skip_depth:
            self.skip_depth -= 1
        elif tag in {"p", "h1", "h2", "h3", "li", "blockquote", "pre"}:
            self.parts.append("\n")
        self.article_depth -= 1

    def handle_data(self, data: str) -> None:
        if self.article_depth and not self.skip_depth:
            text = " ".join(data.split())
            if text:
                self.parts.append(text)

    def text(self) -> str:
        lines = [" ".join(line.split()) for line in "".join(self.parts).splitlines()]
        return "\n\n".join(line for line in lines if line).strip() + "\n"


def main() -> None:
    parser = argparse.ArgumentParser(description="Extract readable article text from a WiLiKi HTML page.")
    parser.add_argument("input", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()

    article_parser = ArticleParser()
    article_parser.feed(args.input.read_text(encoding="utf-8"))
    text = article_parser.text()
    if not text.strip():
        raise SystemExit("Article body was not found.")

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(text, encoding="utf-8")
    print(f"Generated: {args.output}")


if __name__ == "__main__":
    main()
