#!/usr/bin/env python3
from __future__ import annotations

import json
import argparse
import re
import sys

import yaml

from common import (
    BRIEF_FIELDS,
    ELIGIBLE_COMMENTARY,
    INCLUDED_COMMENTARY,
    MAX_POEM_LINE_CELLS,
    NOTES_FIELDS,
    PASS3_PRESERVE_ORIGINAL,
    PASS3_REGENERATE,
    PLACEHOLDER_PROMPT_SIGNATURE,
    PROMPT_FIELDS,
    PROMPT_FORBIDDEN_PHRASES,
    ROOT,
    SECTIONS,
    COMMENTARY_WARNING,
    UNREVIEWED_COMMENTARY,
    clean_poem_body,
    extract_postscript_markdown,
    extract_commentary_note_markdown,
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
                c_frontmatter, c_body = read_markdown(c_path)
                status = c_frontmatter.get("commentary-status")
                if status not in INCLUDED_COMMENTARY:
                    fail(errors, f"{commentary} has unsupported commentary-status {status!r}")
                if re.search(r"\\[A-Za-z]+", c_body):
                    fail(errors, f"{commentary} contains raw LaTeX command")
                if status in UNREVIEWED_COMMENTARY:
                    if not c_body.lstrip().startswith(COMMENTARY_WARNING):
                        fail(errors, f"{commentary} missing unreviewed commentary warning")

        asset = ROOT / poem["asset"]
        prompt = ROOT / poem["prompt"]
        notes = asset.parent / "illustration.notes.md"
        brief = asset.parent / "illustration.brief.md"
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
            if status in {"generated", "reviewed"} and prompt.exists():
                if not brief.exists():
                    fail(errors, f"{brief.relative_to(ROOT)} missing for generated/reviewed asset")
                else:
                    brief_text = brief.read_text(encoding="utf-8")
                    missing_brief = [field for field in BRIEF_FIELDS if f"{field}:" not in brief_text]
                    if missing_brief:
                        fail(errors, f"{brief.relative_to(ROOT)} missing brief fields: {', '.join(missing_brief)}")
                    if len(brief_text) < 1400:
                        fail(errors, f"{brief.relative_to(ROOT)} is too short for a concrete visual brief")
                    if frontmatter.get("images"):
                        for field in [
                            "source_image_observations:",
                            "palette_from_source_images:",
                            "lighting_from_source_images:",
                            "place_or_object_cues_from_source_images:",
                        ]:
                            if field not in brief_text:
                                fail(errors, f"{brief.relative_to(ROOT)} missing source-photo field {field}")
                        if "Source photo path(s):" not in brief_text:
                            fail(errors, f"{brief.relative_to(ROOT)} lacks concrete source-photo observations")
                prompt_text = prompt.read_text(encoding="utf-8")
                missing = [field for field in PROMPT_FIELDS if f"{field}:" not in prompt_text]
                if missing:
                    fail(errors, f"{poem['prompt']} missing prompt fields: {', '.join(missing)}")
                if len(prompt_text) < 1200:
                    fail(errors, f"{poem['prompt']} is too short for a content-rich generated prompt")
                for phrase in PROMPT_FORBIDDEN_PHRASES:
                    if phrase in prompt_text:
                        fail(errors, f"{poem['prompt']} contains unresolved prompt language: {phrase}")
                for anchor in ["foreground:", "middle_ground:", "background:", "camera_and_composition:", "final_image_prompt:"]:
                    if anchor not in prompt_text:
                        fail(errors, f"{poem['prompt']} lacks execution anchor {anchor}")
                missing_notes = [field for field in NOTES_FIELDS if f"{field}:" not in notes_frontmatter and field not in notes_frontmatter]
                if missing_notes:
                    fail(errors, f"{notes.relative_to(ROOT)} missing note fields: {', '.join(missing_notes)}")
                scope = notes_frontmatter.get("regeneration-scope")
                if poem["title"] in PASS3_PRESERVE_ORIGINAL and scope != "preserve-original-seven":
                    fail(errors, f"{notes.relative_to(ROOT)} must preserve original seven scope")
                if poem["title"] in PASS3_REGENERATE and scope != "pass3-regenerate":
                    fail(errors, f"{notes.relative_to(ROOT)} must be pass3-regenerate scope")
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

    note_path = ROOT / "src" / "llm-commentary-note.md"
    if note_path.exists():
        note = note_path.read_text(encoding="utf-8")
        extracted_note = extract_commentary_note_markdown()
        if "少年时代，我非常喜欢《唐诗鉴赏辞典》" not in note:
            fail(errors, "src/llm-commentary-note.md missing extracted commentary-writing note")
        if abs(len(note) - len(extracted_note)) > 300:
            fail(errors, "src/llm-commentary-note.md length diverges from main.tex commentary note extraction")

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
