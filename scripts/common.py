from __future__ import annotations

import base64
import json
import re
import shutil
import struct
import zlib
from collections import defaultdict
from pathlib import Path

import yaml


ROOT = Path(__file__).resolve().parents[1]
COG_POEMS = Path("/Users/utensil/projects/cog-land/blogs/poems")
COG_COMMENTARIES = COG_POEMS / "commentaries"
ILLUSTRATED = Path("/Users/utensil/projects/cog-land/.illustrated-poem-page")
SKILL_TEMPLATE = Path("/Users/utensil/projects/skills-land/ours/illustrated-poem-page/templates/poem-page.typ")
AUTO_PINYIN = ILLUSTRATED / "eval-pinyin" / "auto-pinyin"

SECTIONS = [
    "职业生涯",
    "压力阴郁",
    "情感与家庭",
    "哲思禅意",
    "心情与事件",
    "云南丽江香格里拉之旅",
]

ELIGIBLE_COMMENTARY = {"human-revised", "reference-quality"}
INELIGIBLE_COMMENTARY = {"ai-review-only", "iterated", "unclear"}

PILOT_ASSET_SLUGS = {
    "夜会": "yehui",
    "疹热": "zhenre",
    "月谷": "yuegu",
    "泛舟": "fanzhou",
    "湖畔": "hupan",
    "岩浆": "yanjiang",
    "十月": "shiyue",
}

TONE_VOWELS = {
    "a": "āáǎàa",
    "e": "ēéěèe",
    "i": "īíǐìi",
    "o": "ōóǒòo",
    "u": "ūúǔùu",
    "v": "ǖǘǚǜü",
    "ü": "ǖǘǚǜü",
}


def split_frontmatter(text: str) -> tuple[dict, str]:
    if not text.startswith("---\n"):
        return {}, text
    end = text.find("\n---", 4)
    if end == -1:
        return {}, text
    front = text[4:end]
    body = text[text.find("\n", end + 4) + 1 :]
    return yaml.safe_load(front) or {}, body.lstrip("\n")


def read_markdown(path: Path) -> tuple[dict, str]:
    return split_frontmatter(path.read_text(encoding="utf-8"))


def write_markdown(path: Path, frontmatter: dict, body: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    rendered = yaml.safe_dump(frontmatter, allow_unicode=True, sort_keys=False).strip()
    path.write_text(f"---\n{rendered}\n---\n\n{body.strip()}\n", encoding="utf-8")


def clean_poem_body(body: str, context: str | None = None) -> str:
    lines = body.strip().splitlines()
    cleaned: list[str] = []
    for line in lines:
        stripped = line.strip()
        if stripped.startswith(">"):
            quote = stripped.lstrip("> ").strip()
            if not context or quote == context.strip():
                continue
        if stripped:
            cleaned.append(stripped)
    return "\n".join(cleaned)


def poem_order_from_main_tex() -> dict[str, list[str]]:
    text = (ROOT / "main.tex").read_text(encoding="utf-8")
    order: dict[str, list[str]] = {section: [] for section in SECTIONS}
    current = None
    for line in text.splitlines():
        section_match = re.match(r"\\section\{(.+)\}", line.strip())
        if section_match:
            current = section_match.group(1)
            order.setdefault(current, [])
            continue
        poem_match = re.match(r"\\begin\{poem\}\{\}\{(.+)\}", line.strip())
        if current and poem_match:
            order[current].append(latex_inline_to_text(poem_match.group(1)))
    return {section: order.get(section, []) for section in SECTIONS}


def latex_inline_to_text(value: str) -> str:
    value = re.sub(r"\\xpinyin\{([^{}]+)\}\{[^{}]+\}", r"\1", value)
    value = value.replace("{", "").replace("}", "")
    return value


def safe_title(title: str) -> str:
    return re.sub(r"[《》「」]", "", title).replace("/", "-").strip()


def commentary_title(path: Path) -> str | None:
    match = re.search(r"《(.+?)》", path.name)
    return match.group(1) if match else None


def find_commentaries() -> dict[str, Path]:
    chosen: dict[str, Path] = {}
    for path in sorted(COG_COMMENTARIES.glob("*/*.md")):
        title = commentary_title(path)
        if not title:
            continue
        frontmatter, _ = read_markdown(path)
        if frontmatter.get("commentary-status") in ELIGIBLE_COMMENTARY:
            chosen[title] = path
    return chosen


def pinyin_num_to_tone(value: str) -> str:
    def convert_one(syllable: str) -> str:
        match = re.match(r"^([A-Za-züÜv:]+)([1-5])$", syllable.strip())
        if not match:
            return syllable
        base = match.group(1).replace("u:", "ü").replace("U:", "Ü")
        tone = int(match.group(2))
        if tone == 5:
            return base.replace("v", "ü")
        lower = base.lower()
        if "a" in lower:
            index = lower.index("a")
        elif "e" in lower:
            index = lower.index("e")
        elif "ou" in lower:
            index = lower.index("o")
        else:
            vowel_positions = [i for i, char in enumerate(lower) if char in "aeiouvü"]
            index = vowel_positions[-1] if vowel_positions else -1
        if index < 0:
            return base
        char = lower[index]
        replacement = TONE_VOWELS[char][tone - 1]
        if base[index].isupper():
            replacement = replacement.upper()
        return base[:index] + replacement + base[index + 1 :].replace("v", "ü")

    return " ".join(convert_one(part) for part in str(value).split())


def pinyin_overrides(frontmatter: dict) -> dict[str, str]:
    overrides: dict[str, str] = {}
    for item in frontmatter.get("pinyin") or []:
        char = item.get("char")
        pinyin = item.get("pinyin")
        if char and pinyin:
            overrides[str(char)] = pinyin_num_to_tone(str(pinyin))
    return overrides


def season_for_date(value) -> tuple[str, str] | None:
    if not value:
        return None
    text = str(value)
    match = re.match(r"^(\d{4})-(\d{2})", text)
    if not match:
        return None
    year = int(match.group(1))
    month = int(match.group(2))
    quarter = (month - 1) // 3 + 1
    season = {1: "春", 2: "夏", 3: "秋", 4: "冬"}[quarter]
    return f"{year}年{season}", f"{year}-Q{quarter}"


def write_png(path: Path, title: str, section: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    width, height = 900, 1350
    seed = sum(ord(char) for char in title + section)
    c1 = ((seed * 29) % 110 + 80, (seed * 17) % 90 + 95, (seed * 11) % 70 + 105)
    c2 = ((seed * 7) % 80 + 120, (seed * 13) % 70 + 125, (seed * 19) % 90 + 130)
    rows = []
    for y in range(height):
        raw = bytearray([0])
        for x in range(width):
            t = (x / width * 0.35) + (y / height * 0.65)
            wave = ((x * 3 + y * 2 + seed) % 97) / 97 * 18
            r = int(c1[0] * (1 - t) + c2[0] * t + wave)
            g = int(c1[1] * (1 - t) + c2[1] * t + wave)
            b = int(c1[2] * (1 - t) + c2[2] * t + wave)
            raw.extend((min(r, 255), min(g, 255), min(b, 255)))
        rows.append(bytes(raw))
    data = zlib.compress(b"".join(rows), 9)
    signature = b"\x89PNG\r\n\x1a\n"

    def chunk(kind: bytes, payload: bytes) -> bytes:
        crc = zlib.crc32(kind + payload) & 0xFFFFFFFF
        return struct.pack(">I", len(payload)) + kind + payload + struct.pack(">I", crc)

    png = signature
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0))
    png += chunk(b"IDAT", data)
    png += chunk(b"IEND", b"")
    path.write_bytes(png)


def copy_or_create_asset(title: str, section: str, target_dir: Path) -> None:
    image = target_dir / "illustration.png"
    prompt = target_dir / "illustration.prompt.md"
    notes = target_dir / "illustration.notes.md"
    target_dir.mkdir(parents=True, exist_ok=True)
    pilot_slug = PILOT_ASSET_SLUGS.get(title)
    if pilot_slug:
        source_dir = ILLUSTRATED / pilot_slug / "assets"
        source_image = source_dir / f"{pilot_slug}-illustration.png"
        source_prompt = source_dir / f"{pilot_slug}-illustration.prompt.md"
        if source_image.exists():
            shutil.copy2(source_image, image)
        if source_prompt.exists():
            shutil.copy2(source_prompt, prompt)
        rejected = source_dir / f"{pilot_slug}-illustration.rejected-iterations.md"
        if rejected.exists():
            shutil.copy2(rejected, notes)
    if not image.exists():
        write_png(image, title, section)
    if not prompt.exists():
        prompt.write_text(
            "\n".join(
                [
                    f"# 《{title}》插画提示词",
                    "",
                    "Textless literary illustration for a Typst poem book page.",
                    f"Use the poem title, section, and context as the source: {section}.",
                    "Keep the image subdued, atmospheric, and supportive of the poem text.",
                    "Avoid calligraphy, captions, seals, decorative text, and generic ancient-China clichés.",
                ]
            )
            + "\n",
            encoding="utf-8",
        )


def typst_string(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def typst_array(values: list[str]) -> str:
    if not values:
        return "()"
    rendered = ", ".join(typst_string(v) for v in values)
    if len(values) == 1:
        rendered += ","
    return f"({rendered})"


def typst_dict(values: dict[str, str]) -> str:
    if not values:
        return "(:)"
    parts = [f"{typst_string(k)}: {typst_string(v)}" for k, v in values.items()]
    return "(" + ", ".join(parts) + ")"


def load_book() -> dict:
    return yaml.safe_load((ROOT / "src" / "book.yaml").read_text(encoding="utf-8"))


def iter_book_poems(book: dict):
    for section in book.get("sections", []):
        for poem in section.get("poems", []):
            yield section, poem
