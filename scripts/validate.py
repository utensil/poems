#!/usr/bin/env python3
from __future__ import annotations

import json
import argparse
import re
import sys

import yaml

from common import (
    ELIGIBLE_COMMENTARY,
    INCLUDED_COMMENTARY,
    MAX_POEM_LINE_CELLS,
    PLACEHOLDER_PROMPT_SIGNATURE,
    ROOT,
    SECTIONS,
    COMMENTARY_WARNING,
    UNREVIEWED_COMMENTARY,
    clean_poem_body,
    extract_postscript_markdown,
    iter_book_poems,
    load_book,
    poem_order_from_main_tex,
    read_markdown,
    split_frontmatter,
)


def fail(errors: list[str], message: str) -> None:
    errors.append(message)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--mode", choices=["draft", "final"], default="draft")
    args = parser.parse_args()
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
        if re.search(r"\\[A-Za-z]+", body):
            fail(errors, f"{poem['path']} contains raw LaTeX command")
        for line in clean_poem_body(body, frontmatter.get("context")).splitlines():
            if len(line) > MAX_POEM_LINE_CELLS and not frontmatter.get("layout", {}).get("line-breaks"):
                fail(errors, f"{poem['path']} line exceeds {MAX_POEM_LINE_CELLS} cells without layout line-breaks: {line}")

        commentary = poem.get("commentary")
        if commentary:
            c_path = ROOT / commentary
            if not c_path.exists():
                fail(errors, f"missing commentary source {commentary}")
            else:
                c_frontmatter, _ = read_markdown(c_path)
                status = c_frontmatter.get("commentary-status")
                if status not in INCLUDED_COMMENTARY:
                    fail(errors, f"{commentary} has unsupported commentary-status {status!r}")
                if status in UNREVIEWED_COMMENTARY:
                    _, c_body = read_markdown(c_path)
                    if not c_body.lstrip().startswith(COMMENTARY_WARNING):
                        fail(errors, f"{commentary} missing unreviewed commentary warning")

        asset = ROOT / poem["asset"]
        prompt = ROOT / poem["prompt"]
        notes = asset.parent / "illustration.notes.md"
        if not asset.exists():
            fail(errors, f"missing illustration asset {poem['asset']}")
        if not prompt.exists():
            fail(errors, f"missing illustration prompt {poem['prompt']}")
        else:
            prompt_text = prompt.read_text(encoding="utf-8")
            if poem["title"] not in prompt_text:
                fail(errors, f"{poem['prompt']} does not mention poem title {poem['title']}")
            if args.mode == "final" and PLACEHOLDER_PROMPT_SIGNATURE in prompt_text:
                fail(errors, f"{poem['prompt']} is a draft placeholder prompt")
        if not notes.exists():
            fail(errors, f"missing illustration metadata {notes.relative_to(ROOT)}")
        else:
            notes_frontmatter, _ = split_frontmatter(notes.read_text(encoding="utf-8"))
            status = notes_frontmatter.get("image-status")
            if status not in {"generated", "reviewed", "placeholder"}:
                fail(errors, f"{notes.relative_to(ROOT)} has invalid image-status {status!r}")
            if args.mode == "final" and status == "placeholder":
                fail(errors, f"{notes.relative_to(ROOT)} is placeholder in final mode")
        seen_assets.add(poem["asset"])

    commentary_files = list((ROOT / "src" / "commentaries").glob("*/*.md"))
    for path in commentary_files:
        frontmatter, _ = read_markdown(path)
        status = frontmatter.get("commentary-status")
        if status not in INCLUDED_COMMENTARY:
            fail(errors, f"{path.relative_to(ROOT)} has unsupported commentary-status {status!r}")

    for required in [
        "src/fanli.md",
        "src/postscript.md",
        "src/llm-commentary-note.md",
        "src/chronology.yaml",
        "templates/book-style.typ",
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

    postscript_path = ROOT / "src" / "postscript.md"
    if postscript_path.exists():
        postscript = postscript_path.read_text(encoding="utf-8")
        extracted = extract_postscript_markdown()
        if len(postscript) < 8000:
            fail(errors, "src/postscript.md is too short to be the real extracted postscript")
        for snippet in ["这个过程中，个人总结，一首诗的创作，可以分为八个步骤", "创造力是发散与收敛的一种平衡"]:
            if snippet not in postscript:
                fail(errors, f"src/postscript.md missing extracted source snippet: {snippet}")
        if abs(len(postscript) - len(extracted)) > 1500:
            fail(errors, "src/postscript.md length diverges from main.tex extraction")

    manifest = ROOT / "build" / "generated" / "manifest.json"
    if manifest.exists():
        data = json.loads(manifest.read_text(encoding="utf-8"))
        for section in data.get("sections", []):
            for poem in section.get("poems", []):
                status = poem.get("commentary-status")
                if status and status not in INCLUDED_COMMENTARY:
                    fail(errors, f"manifest includes unsupported commentary for {poem['title']}: {status}")

    if errors:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        return 1
    print("validation passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
