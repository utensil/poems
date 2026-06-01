#!/usr/bin/env python3
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

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

    generated_source = (ROOT / "build" / "generated" / "book.generated.typ").read_text(encoding="utf-8")
    if "LLM" in generated_source:
        print("ERROR: generated Typst still contains LLM title text", file=sys.stderr)
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

    info = run(["pdfinfo", str(pdf)])
    info_text = info.stdout
    if "Page size:" not in info_text or "Pages:" not in info_text:
        print("ERROR: pdfinfo output incomplete", file=sys.stderr)
        return 1

    print("audit passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
