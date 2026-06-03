#!/usr/bin/env python3
from __future__ import annotations

import json

from common import ROOT, clean_poem_body, leading_quote_context, leading_quote_context_parts, load_book, pinyin_overrides, read_markdown


def main() -> None:
    book = load_book()
    manifest = {"title": book.get("title", "冶文斋诗选"), "sections": []}
    for section in book.get("sections", []):
        rendered_section = {"title": section["title"], "poems": []}
        for poem in section.get("poems", []):
            poem_frontmatter, poem_body = read_markdown(ROOT / poem["path"])
            commentary_body = ""
            commentary_status = None
            if poem.get("commentary"):
                commentary_frontmatter, commentary_body = read_markdown(ROOT / poem["commentary"])
                commentary_status = commentary_frontmatter.get("commentary-status")
            rendered_section["poems"].append(
                {
                    **poem,
                    "context": leading_quote_context(poem_body, poem_frontmatter.get("context")),
                    "context-parts": leading_quote_context_parts(poem_body, poem_frontmatter.get("context")),
                    "body": clean_poem_body(poem_body, poem_frontmatter.get("context")),
                    "commentary-body": commentary_body.strip(),
                    "commentary-status": commentary_status,
                    "pinyin-overrides": pinyin_overrides(poem_frontmatter),
                }
            )
        manifest["sections"].append(rendered_section)

    out = ROOT / "build" / "generated"
    out.mkdir(parents=True, exist_ok=True)
    (out / "manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    print(f"wrote {out / 'manifest.json'}")


if __name__ == "__main__":
    main()
