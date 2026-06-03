#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import shutil

import yaml

from common import COMMENTARY_WARNING, ROOT, UNREVIEWED_COMMENTARY, typst_array, typst_dict, typst_string


def paragraphs(markdown: str) -> list[dict[str, str]]:
    text = re.sub(r"^---\n.*?\n---\n", "", markdown.strip(), flags=re.S)
    parts = []
    current_quote: list[str] = []
    current_para: list[str] = []

    def flush_para() -> None:
        nonlocal current_para
        if current_para:
            lines = current_para
            if lines[0].startswith("#"):
                lines[0] = lines[0].lstrip("#").strip()
            parts.append({"kind": "para", "text": "\n".join(lines)})
            current_para = []

    def flush_quote() -> None:
        nonlocal current_quote
        if current_quote:
            parts.append({"kind": "quote", "text": "\n".join(current_quote)})
            current_quote = []

    for raw in text.splitlines():
        line = raw.strip()
        if not line:
            flush_para()
            flush_quote()
            continue
        if line.startswith("## "):
            flush_para()
            flush_quote()
            parts.append({"kind": "heading", "text": line.lstrip("#").strip()})
            continue
        if line.startswith(">"):
            flush_para()
            current_quote.append(line.lstrip("> ").strip())
            continue
        flush_quote()
        current_para.append(line)
    flush_para()
    flush_quote()
    return parts


def paragraph_texts(markdown: str) -> list[str]:
    return [part["text"] for part in paragraphs(markdown) if part["kind"] == "para"]


def with_signature_block(parts: list[dict[str, str]]) -> list[dict[str, str]]:
    if len(parts) < 2:
        return parts
    if parts[-2]["kind"] != "para" or parts[-1]["kind"] != "para":
        return parts
    return parts[:-2] + [{"kind": "signature", "text": f"{parts[-2]['text']}\n{parts[-1]['text']}"}]


def typst_block_array(parts: list[dict[str, str]]) -> str:
    if not parts:
        return "()"
    rendered = ", ".join(
        f"(kind: {typst_string(part['kind'])}, text: {typst_string(part['text'])})"
        for part in parts
    )
    if len(parts) == 1:
        rendered += ","
    return f"({rendered})"


def context_parts(poem: dict) -> list[dict[str, str]]:
    parts = poem.get("context-parts") or []
    if parts:
        return parts
    return [{"kind": "para", "text": poem.get("context") or "（无背景说明）"}]


def commentary_paragraphs(markdown: str) -> list[str]:
    parts = []
    for part in re.split(r"\n\s*\n", re.sub(r"^---\n.*?\n---\n", "", markdown.strip(), flags=re.S)):
        lines = [line.strip().lstrip("> ").strip() for line in part.splitlines() if line.strip()]
        if not lines:
            continue
        if lines[0].startswith("#"):
            lines[0] = lines[0].lstrip("#").strip()
        parts.append("\n".join(lines))
    return parts


def emit_paragraphs(parts: list[str]) -> str:
    if not parts:
        return ""
    rendered = []
    for part in parts:
        rendered.append(f"#block(above: 0pt, below: 9pt)[#txt({typst_string(part)})]")
    return "\n".join(rendered)


def typst_chronology_entries(entries: list[dict]) -> str:
    rendered = []
    for entry in entries:
        poems = "".join(f"《{title}》" for title in entry.get("poems", []))
        rendered.append(f"(period: {typst_string(entry['period'])}, poems: {typst_string(poems)})")
    return "(" + ", ".join(rendered) + ("," if len(rendered) == 1 else "") + ")"


def part_name(index: int, title: str) -> str:
    safe = re.sub(r"[^\w\u3400-\u9fff.-]+", "-", title, flags=re.UNICODE).strip("-")
    return f"{index:02d}-{safe or 'chapter'}.typ"


def render_poem_block(poem: dict) -> list[str]:
    body_lines = [line for line in poem["body"].splitlines() if line.strip()]
    commentary_parts = commentary_paragraphs(poem.get("commentary-body", ""))
    if poem.get("commentary-status") in UNREVIEWED_COMMENTARY and commentary_parts:
        if not commentary_parts[0].startswith(COMMENTARY_WARNING):
            commentary_parts = [COMMENTARY_WARNING] + commentary_parts
    return [
        "#{",
        f"  let title = {typst_string(poem['title'])}",
        f"  let poem_lines = {typst_array(body_lines)}",
        f"  let context_note = {typst_block_array(context_parts(poem))}",
        f"  let commentary = {typst_array(commentary_parts)}",
        f"  let asset = {typst_string(poem['asset'])}",
        f"  let override = {typst_dict(poem.get('pinyin-overrides') or {})}",
        "  render-poem(title, poem_lines, context_note, commentary, asset, override)",
        "}",
        "#pagebreak()",
    ]


def write_typst(path, lines: list[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(line for line in lines if line is not None) + "\n", encoding="utf-8")
    print(f"wrote {path}")


def main() -> None:
    manifest = json.loads((ROOT / "build" / "generated" / "manifest.json").read_text(encoding="utf-8"))
    chronology = yaml.safe_load((ROOT / "src" / "chronology.yaml").read_text(encoding="utf-8"))
    conventions = (ROOT / "src" / "conventions.md").read_text(encoding="utf-8")
    preface = (ROOT / "src" / "preface.md").read_text(encoding="utf-8")
    postscript = (ROOT / "src" / "postscript.md").read_text(encoding="utf-8")
    commentary_illustration_note = (ROOT / "src" / "commentary-and-illustration-note.md").read_text(encoding="utf-8")

    generated_root = ROOT / "build" / "generated"
    for stale_dir in [generated_root / "parts", generated_root / "chapters"]:
        if stale_dir.exists():
            shutil.rmtree(stale_dir)

    helper_lines: list[str] = [
        '#import "../../templates/book-style.typ": *',
        '#import "../../templates/illustrated-poem-page.typ": illustrated-poem-page',
        '#import "../../templates/auto-pinyin/lib.typ": to-pinyin',
        "",
        "#let txt(value) = text(value)",
        "#let pinyin-annotations(lines, override) = {",
        "  let annotations = ()",
        "  for (line-index, line) in lines.enumerate() {",
        "    let chars = line.clusters()",
        '    let pinyins = to-pinyin(line, style: "tone", override: override)',
        "    for (cell-index, cell) in chars.enumerate() {",
        "      let py = pinyins.at(cell-index)",
        "      if py != cell {",
        "        annotations.push((line: line-index, cell: cell-index, text: py))",
        "      }",
        "    }",
        "  }",
        "  annotations",
        "}",
        "",
        "#let title-pinyin(title, override) = {",
        '  to-pinyin(title, style: "tone", override: override).zip(title.clusters()).map(pair => if pair.first() == pair.last() { none } else { pair.first() })',
        "}",
        "",
        "#let render-poem(title, poem-lines, context-note, commentary, asset, override) = {",
        "  let render-image = (w, h, fit) => image(\"../../\" + asset, width: w, height: h, fit: fit)",
        "  illustrated-poem-page(",
        "    title,",
        "    poem-lines.map(line => line.clusters()),",
        "    context-note,",
        "    commentary,",
        "    render-image,",
        "    pinyin: pinyin-annotations(poem-lines, override),",
        "    title-cells: title.clusters(),",
        "    title-pinyin: title-pinyin(title, override),",
        "  )",
        "}",
        "",
    ]
    write_typst(generated_root / "_helpers.typ", helper_lines)

    frontmatter: list[str] = [
        '#import "../_helpers.typ": *',
        "",
        '#cover-page("冶文斋诗选", "宋皿")',
        "#pagebreak()",
        f'#prose-page("序", {typst_block_array(with_signature_block(paragraphs(preface)[1:]))})',
        "#pagebreak()",
        f'#prose-page("凡例", {typst_block_array(paragraphs(conventions)[1:])})',
        "#pagebreak()",
        "#toc-page((",
        '  "序",',
        '  "凡例",',
        *[f'  "{section["title"]}",' for section in manifest["sections"]],
        '  "年谱",',
        '  "代后记：在日常里写旧体诗的一点体会",',
        '  "赏析与配图说明",',
        "))",
        "#pagebreak()",
    ]
    write_typst(generated_root / "parts" / "frontmatter.typ", frontmatter)

    chapter_paths: list[str] = []
    for index, section in enumerate(manifest["sections"], start=1):
        title_lines = [section["title"]]
        if section["title"] == "云南丽江香格里拉之旅":
            title_lines = ["云南丽江", "香格里拉之旅"]
        chapter_lines = [
            '#import "../_helpers.typ": *',
            "",
            f"#chapter-divider({typst_array(title_lines)}, {len(section['poems'])})",
            "#pagebreak()",
        ]
        for poem in section["poems"]:
            chapter_lines.extend(render_poem_block(poem))
        path = generated_root / "chapters" / part_name(index, section["title"])
        write_typst(path, chapter_lines)
        chapter_paths.append(path.relative_to(generated_root).as_posix())

    backmatter: list[str] = [
        '#import "../_helpers.typ": *',
        "",
        f"#chronology-page({typst_chronology_entries(chronology.get('entries', []))})",
        "#pagebreak()",
        f'#appendix-article("代后记：在日常里写旧体诗的一点体会", {typst_block_array(paragraphs(postscript)[1:])})',
        "#pagebreak()",
        f'#appendix-article("赏析与配图说明", {typst_block_array(paragraphs(commentary_illustration_note)[1:])})',
    ]
    write_typst(generated_root / "parts" / "backmatter.typ", backmatter)

    root_lines = [
        '#set document(title: "冶文斋诗选", author: "宋皿")',
        "",
        '#include "parts/frontmatter.typ"',
        *[f'#include "{path}"' for path in chapter_paths],
        '#include "parts/backmatter.typ"',
    ]
    write_typst(generated_root / "book.generated.typ", root_lines)


if __name__ == "__main__":
    main()
