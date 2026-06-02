#!/usr/bin/env python3
from __future__ import annotations

import subprocess
import sys
from pathlib import Path
import re

from common import ROOT


def run(cmd: list[str], *, expect_ok: bool = True) -> subprocess.CompletedProcess:
    proc = subprocess.run(cmd, cwd=ROOT, text=True, capture_output=True)
    if expect_ok and proc.returncode != 0:
        print(proc.stdout)
        print(proc.stderr, file=sys.stderr)
        raise SystemExit(proc.returncode)
    return proc


def main() -> int:
    run(["python3", "scripts/validate.py", "--mode", "draft"])
    run(["python3", "scripts/build-manifest.py"])
    run(["python3", "scripts/generate-typst.py"])
    run(["typst", "compile", "--root", ".", "book.typ", "build/pdf/poem-book.pdf"])

    final_validation = run(["python3", "scripts/validate.py", "--mode", "final"], expect_ok=False)
    if final_validation.returncode == 0:
        print("ERROR: final validation unexpectedly passed while placeholders remain", file=sys.stderr)
        return 1
    if "placeholder" not in final_validation.stderr and "placeholder" not in final_validation.stdout:
        print("ERROR: final validation failed for a reason other than placeholder gates", file=sys.stderr)
        print(final_validation.stdout)
        print(final_validation.stderr, file=sys.stderr)
        return 1

    pdf = ROOT / "build" / "pdf" / "poem-book.pdf"
    if not pdf.exists():
        print("ERROR: build/pdf/poem-book.pdf missing", file=sys.stderr)
        return 1

    text_path = ROOT / "build" / "audit" / "poem-book.txt"
    text_path.parent.mkdir(parents=True, exist_ok=True)
    run(["pdftotext", str(pdf), str(text_path)])
    text = text_path.read_text(encoding="utf-8", errors="ignore")
    layout_text_path = ROOT / "build" / "audit" / "poem-book-layout.txt"
    run(["pdftotext", "-layout", str(pdf), str(layout_text_path)])
    pages = layout_text_path.read_text(encoding="utf-8", errors="ignore").split("\f")

    def pages_with(marker: str) -> list[int]:
        return [index + 1 for index, page in enumerate(pages) if marker in page]

    def page_with(marker: str) -> str:
        matches = pages_with(marker)
        if not matches:
            print(f"ERROR: PDF text missing page marker {marker}", file=sys.stderr)
            raise SystemExit(1)
        return pages[matches[0] - 1]

    for required in ["冶文斋诗选", "宋皿", "凡例", "年谱", "代后记：在日常里写旧体诗的一点体会", "赏析编写说明"]:
        if required not in text:
            print(f"ERROR: PDF text missing {required}", file=sys.stderr)
            return 1
    for forbidden in ["textsf", "Typst 插画本", "十、一、", "十、二、", r"\\textsf", "LLM", "未列入年谱", "夜会、心印", "> "]:
        if forbidden in text:
            print(f"ERROR: PDF text contains forbidden text {forbidden}", file=sys.stderr)
            return 1

    style_source = (ROOT / "templates" / "book-style.typ").read_text(encoding="utf-8")
    if "#let cover-title-font = poem-title-font" not in style_source:
        print("ERROR: cover title font is not tied to poem-title font role", file=sys.stderr)
        return 1
    if "#let prose-paragraph-gap = 20pt" not in style_source:
        print("ERROR: prose paragraph gap is not centrally set to the pass2 minimum", file=sys.stderr)
        return 1
    for required_source in [
        "#let poem-role-panel-margin = 5.6mm",
        "#let poem-role-frame-margin = 8mm",
        "background: role-ground(panel-margin: poem-role-panel-margin, frame-margin: poem-role-frame-margin)",
        "#let title-rule-gap = 24pt",
        "#let cover-title-rule-gap = 24pt",
        "#let toc-entry-rule-gap = 12pt",
        "line-length: 82mm",
        "#let measured-title-rule",
        "title-size.height + gap",
        "measured-title-rule(prose-title-style",
        "measured-title-rule(toc-title-style",
        "#let toc-entry-rule",
        "let entry-content = block(width: width)",
        "#toc-entry-rule(entry)",
        "#let toc-entry-row-gap = 16pt",
        "first-line-indent: 2em",
        "#h(2em)#prose-body-style(p.text)",
    ]:
        if required_source not in style_source:
            print(f"ERROR: missing requested role-page spacing contract: {required_source}", file=sys.stderr)
            return 1
    for role in [
        "book-title-style",
        "book-author-style",
        "toc-title-style",
        "toc-entry-style",
        "chapter-divider-style",
        "prose-title-style",
        "prose-body-style",
        "prose-quote-style",
        "poem-title-style",
        "poem-body-style",
        "commentary-style",
        "context-style",
        "chronology-style",
    ]:
        if f"#let {role}" not in style_source:
            print(f"ERROR: missing centralized style role {role}", file=sys.stderr)
            return 1
    for required_source in ["role-ground(", "grid(", "prose-quote-style", "chapter-divider-style"]:
        if required_source not in style_source:
            print(f"ERROR: book-style lacks required page-role renderer evidence {required_source}", file=sys.stderr)
            return 1

    poem_template = (ROOT / "templates" / "illustrated-poem-page.typ").read_text(encoding="utf-8")
    for required_source in [
        "poem-line-gap: 1pt",
        "commentary-paragraph-gap: 18pt",
        "fg-x: 8mm",
        "fg-y: 5.6mm",
        "fg-bottom: 6.4mm",
        "pad-top: 8.8mm",
        "title-body-gap-factor: 0.4",
        "resolved-title-gap * 2",
        "context-commentary-rule-gap: 14pt",
        "let review-marker = \"【人工修订未完成，仅供参考】\"",
        "let body-start = if marker-inline { 1 } else { 0 }",
        "first-line-indent: 2em",
        "#strong[【赏析】]#if marker-inline [ #review-marker]",
        "#h(2em)#p",
        "bottom-frame-text-gap: 18pt",
        'panic("poem block reaches bottom frame',
        "long-poem = poem-lines.len() >= 14",
        "continuation-page",
        'panic("poem top row overflow',
    ]:
        if required_source not in poem_template:
            print(f"ERROR: poem template lacks required split/spacing contract: {required_source}", file=sys.stderr)
            return 1

    generated_source = (ROOT / "build" / "generated" / "book.generated.typ").read_text(encoding="utf-8")
    if "LLM" in generated_source:
        print("ERROR: generated Typst still contains LLM title text", file=sys.stderr)
        return 1
    if "本章收录" in generated_source:
        print("ERROR: generated Typst still contains invented chapter divider count text", file=sys.stderr)
        return 1
    toc_page = page_with("目录")
    if re.search(r"20\d{2}年[春夏秋冬]", toc_page):
        print("ERROR: TOC includes chronology year/season child entries", file=sys.stderr)
        return 1

    for title in ["十月", "疹热", "自然", "启步"]:
        marker = text.find(title)
        if marker < 0:
            print(f"ERROR: PDF text missing known page {title}", file=sys.stderr)
            return 1
        window = text[marker : marker + 4500]
        if "【背景】" not in window:
            print(f"ERROR: known page {title} missing background marker near poem text", file=sys.stderr)
            return 1
        if "【赏析】" not in window:
            print(f"ERROR: known page {title} missing commentary marker near poem text", file=sys.stderr)
            return 1
    qibu_page = page_with("启步")
    if "此战持久莫急求" not in qibu_page:
        print("ERROR: 启步 poem page is missing its final line; long poem overflow/clipping returned", file=sys.stderr)
        return 1
    for title in ["十月", "疹热", "自然", "启步"]:
        title_pages = pages_with(title)
        bg_pages = pages_with("【背景】")
        commentary_pages = pages_with("【赏析】")
        if not set(title_pages + [p + 1 for p in title_pages]).intersection(bg_pages):
            print(f"ERROR: known page {title} does not place background on poem page or immediate continuation", file=sys.stderr)
            return 1
        if not set(title_pages + [p + 1 for p in title_pages]).intersection(commentary_pages):
            print(f"ERROR: known page {title} does not place commentary on poem page or immediate continuation", file=sys.stderr)
            return 1

    info = run(["pdfinfo", str(pdf)])
    info_text = info.stdout
    if "Page size:" not in info_text or "Pages:" not in info_text:
        print("ERROR: pdfinfo output incomplete", file=sys.stderr)
        return 1

    print("audit passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
