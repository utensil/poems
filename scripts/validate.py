#!/usr/bin/env python3
from __future__ import annotations

import json
import sys

import yaml

from common import (
    ELIGIBLE_COMMENTARY,
    INELIGIBLE_COMMENTARY,
    ROOT,
    SECTIONS,
    clean_poem_body,
    iter_book_poems,
    load_book,
    poem_order_from_main_tex,
    read_markdown,
)


def fail(errors: list[str], message: str) -> None:
    errors.append(message)


def main() -> int:
    errors: list[str] = []
    branch = ""
    try:
        import subprocess

        branch = subprocess.check_output(
            ["git", "branch", "--show-current"], cwd=ROOT, text=True
        ).strip()
    except Exception as exc:
        fail(errors, f"cannot determine git branch: {exc}")
    if branch != "typst":
        fail(errors, f"branch must be typst, got {branch!r}")

    book_path = ROOT / "src" / "book.yaml"
    if not book_path.exists():
        fail(errors, "src/book.yaml is missing")
        book = {"sections": []}
    else:
        book = load_book()

    expected = poem_order_from_main_tex()
    sections = book.get("sections", [])
    if [section.get("title") for section in sections] != SECTIONS:
        fail(errors, "src/book.yaml section order does not match main.tex")

    total = sum(len(section.get("poems", [])) for section in sections)
    if total != 77:
        fail(errors, f"src/book.yaml must list 77 poems, got {total}")

    for section in sections:
        title = section.get("title")
        titles = [poem.get("title") for poem in section.get("poems", [])]
        if titles != expected.get(title, []):
            fail(errors, f"poem order mismatch in section {title}")

    seen_assets = set()
    for section, poem in iter_book_poems(book):
        poem_path = ROOT / poem["path"]
        if not poem_path.exists():
            fail(errors, f"missing poem source {poem['path']}")
            continue
        frontmatter, body = read_markdown(poem_path)
        for key in ["title", "section", "context"]:
            if key not in frontmatter:
                fail(errors, f"{poem['path']} missing frontmatter key {key}")
        if not clean_poem_body(body, frontmatter.get("context")):
            fail(errors, f"{poem['path']} has empty poem body")

        commentary = poem.get("commentary")
        if commentary:
            c_path = ROOT / commentary
            if not c_path.exists():
                fail(errors, f"missing commentary source {commentary}")
            else:
                c_frontmatter, _ = read_markdown(c_path)
                status = c_frontmatter.get("commentary-status")
                if status not in ELIGIBLE_COMMENTARY:
                    fail(errors, f"{commentary} has ineligible commentary-status {status!r}")
                if status in INELIGIBLE_COMMENTARY or status is None:
                    fail(errors, f"{commentary} must not be included with status {status!r}")

        asset = ROOT / poem["asset"]
        prompt = ROOT / poem["prompt"]
        if not asset.exists():
            fail(errors, f"missing illustration asset {poem['asset']}")
        if not prompt.exists():
            fail(errors, f"missing illustration prompt {poem['prompt']}")
        seen_assets.add(poem["asset"])

    commentary_files = list((ROOT / "src" / "commentaries").glob("*/*.md"))
    for path in commentary_files:
        frontmatter, _ = read_markdown(path)
        status = frontmatter.get("commentary-status")
        if status not in ELIGIBLE_COMMENTARY:
            fail(errors, f"{path.relative_to(ROOT)} has ineligible commentary-status {status!r}")

    for required in [
        "src/fanli.md",
        "src/postscript.md",
        "src/llm-commentary-note.md",
        "src/chronology.yaml",
        "templates/illustrated-poem-page.typ",
    ]:
        if not (ROOT / required).exists():
            fail(errors, f"missing {required}")

    chronology_path = ROOT / "src" / "chronology.yaml"
    if chronology_path.exists():
        chronology = yaml.safe_load(chronology_path.read_text(encoding="utf-8"))
        skipped = set(chronology.get("undated-skipped", []))
        for title in ["夜会", "心印"]:
            if title not in skipped:
                fail(errors, f"src/chronology.yaml must explicitly skip {title}")
        for entry in chronology.get("entries", []):
            if "-" in entry.get("period", ""):
                fail(errors, f"chronology period exposes an exact date: {entry.get('period')}")

    manifest = ROOT / "build" / "generated" / "manifest.json"
    if manifest.exists():
        data = json.loads(manifest.read_text(encoding="utf-8"))
        for section in data.get("sections", []):
            for poem in section.get("poems", []):
                status = poem.get("commentary-status")
                if status and status not in ELIGIBLE_COMMENTARY:
                    fail(errors, f"manifest includes ineligible commentary for {poem['title']}: {status}")

    if errors:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        return 1
    print("validation passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
