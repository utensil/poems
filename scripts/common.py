from __future__ import annotations

import json
import re
import shutil
import struct
import zlib
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
INCLUDED_COMMENTARY = {"human-revised", "reference-quality", "ai-review-only", "iterated"}
UNREVIEWED_COMMENTARY = {"ai-review-only", "iterated"}
COMMENTARY_WARNING = "【人工修订未完成，仅供参考】"
PLACEHOLDER_PROMPT_SIGNATURE = "TEMPORARY PLACEHOLDER IMAGE - DRAFT/LAYOUT ONLY"
MAX_POEM_LINE_CELLS = 14
PROMPT_FIELDS = [
    "title",
    "use_case",
    "asset_type",
    "primary_request",
    "scene_backdrop",
    "subjects_and_actions",
    "foreground",
    "middle_ground",
    "background",
    "camera_and_composition",
    "light_and_color",
    "style",
    "page_layout_constraints",
    "negative_constraints",
    "final_image_prompt",
    "source_generated_image",
]

BRIEF_FIELDS = [
    "title",
    "source_files",
    "poem_context",
    "poem_reading",
    "commentary_interpretation",
    "source_image_paths",
    "source_image_observations",
    "palette_from_source_images",
    "lighting_from_source_images",
    "place_or_object_cues_from_source_images",
    "visual_thesis",
    "main_scene",
    "foreground",
    "middle_ground",
    "background",
    "human_figures",
    "camera_position",
    "composition",
    "symbolic_mapping",
    "page_layout_role",
    "avoid",
]

NOTES_FIELDS = [
    "image-status",
    "prompt-source",
    "brief-status",
    "review-status",
    "source-poem",
    "source-commentary",
    "source-images",
    "generation-tool",
    "generated-image-source",
    "regeneration-scope",
    "human-feedback",
]

PASS3_PRESERVE_ORIGINAL = {"夜会", "疹热", "十月", "岩浆", "泛舟", "湖畔", "月谷"}
PASS3_REGENERATE = {"启步", "自然", "哧溜", "喜临", "孤僧", "心印", "心意", "沉沦", "穿越", "流迁", "返初", "途遇"}
PROMPT_FORBIDDEN_PHRASES = [
    "Infer from poem/commentary",
    "infer from poem/commentary",
    "Select concrete images",
    "select concrete images",
    "based on the poem",
    "use the commentary to decide",
    "to be determined",
    "To be determined",
    "No commentary source available",
    "generic literary illustration",
]

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
            cleaned.extend(rebreak_poem_line(clean_latex_inline(stripped)))
    return "\n".join(cleaned)


def rebreak_poem_line(line: str) -> list[str]:
    if len(line) <= MAX_POEM_LINE_CELLS:
        return [line]
    if "，" in line:
        parts = []
        segments = line.split("，")
        for i, segment in enumerate(segments):
            if not segment:
                continue
            punctuation = "，" if i < len(segments) - 1 else ""
            parts.append(segment + punctuation)
        if all(len(part) <= MAX_POEM_LINE_CELLS for part in parts):
            return parts
    return [line]


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
    value = clean_latex_inline(value)
    value = value.replace("{", "").replace("}", "")
    return value


def clean_latex_inline(value: str) -> str:
    value = re.sub(r"\{\\textsf\s+([^{}]+)\}", r"\1", value)
    value = re.sub(r"\\xpinyin\{([^{}]+)\}\{[^{}]+\}", r"\1", value)
    value = value.replace("``", "“").replace("''", "”")
    value = value.replace("\\%", "%").replace("\\&", "&")
    return value


def safe_title(title: str) -> str:
    return re.sub(r"[《》「」]", "", title).replace("/", "-").strip()


def commentary_title(path: Path) -> str | None:
    match = re.search(r"《(.+?)》", path.name)
    return match.group(1) if match else None


def find_commentaries() -> dict[str, Path]:
    chosen: dict[str, tuple[int, Path]] = {}
    priority = {"human-revised": 0, "reference-quality": 1, "ai-review-only": 2, "iterated": 3}
    for path in sorted(COG_COMMENTARIES.glob("*/*.md")):
        title = commentary_title(path)
        if not title:
            continue
        frontmatter, _ = read_markdown(path)
        status = frontmatter.get("commentary-status")
        if status in INCLUDED_COMMENTARY:
            candidate = (priority[status], path)
            if title not in chosen or candidate[0] < chosen[title][0]:
                chosen[title] = candidate
    return {title: path for title, (_, path) in chosen.items()}


def extract_postscript_markdown() -> str:
    text = (ROOT / "main.tex").read_text(encoding="utf-8")
    start_marker = r"\section{代后记：在日常里写旧体诗的一点体会}"
    stop_marker = r"\section{附录：诗词赏析}"
    start = text.index(start_marker) + len(start_marker)
    stop = text.index(stop_marker, start)
    body = text[start:stop].strip()
    body = body.replace("\r\n", "\n")
    body = re.sub(r"\\begin\{quote\}\n?(.*?)\n?\\end\{quote\}", quote_to_markdown, body, flags=re.S)
    body = clean_latex_inline(body)
    body = re.sub(r"\\[a-zA-Z]+\*?(?:\[[^\]]*\])?(?:\{([^{}]*)\})?", r"\1", body)
    body = body.replace("\n\n\n", "\n\n")
    return "# 代后记：在日常里写旧体诗的一点体会\n\n" + body.strip() + "\n"


def extract_commentary_note_markdown() -> str:
    text = (ROOT / "main.tex").read_text(encoding="utf-8")
    start_marker = r"\section{附录：诗词赏析}"
    start = text.index(start_marker) + len(start_marker)
    subsection = text.index(r"\subsection", start)
    body = text[start:subsection].strip()
    body = clean_latex_inline(body)
    body = re.sub(r"\\[a-zA-Z]+\*?(?:\[[^\]]*\])?(?:\{([^{}]*)\})?", r"\1", body)
    return "# 赏析编写说明\n\n" + body.strip() + "\n"


def quote_to_markdown(match: re.Match) -> str:
    inner = clean_latex_inline(match.group(1).strip())
    lines = []
    for line in inner.splitlines():
        stripped = line.strip()
        if stripped:
            lines.append(f"> {stripped}")
        else:
            lines.append(">")
    return "\n".join(lines)


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
    status = "placeholder"
    prompt_source = "poem-only"
    review_status = "needs-regeneration"
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
        if source_image.exists():
            status = "generated"
            prompt_source = "poem-commentary"
            review_status = "accepted"
    if not image.exists():
        write_png(image, title, section)
    if not prompt.exists():
        prompt.write_text(placeholder_prompt(title, section), encoding="utf-8")
    if not notes.exists() or "image-status:" not in notes.read_text(encoding="utf-8", errors="ignore"):
        existing_notes = notes.read_text(encoding="utf-8", errors="ignore") if notes.exists() else ""
        notes.write_text(
            "\n".join(
                [
                    "---",
                    f"image-status: {status}",
                    f"prompt-source: {prompt_source}",
                    f"review-status: {review_status}",
                    "---",
                    "",
                    f"《{title}》asset metadata.",
                    "Placeholder assets are allowed only in draft/layout validation.",
                    "",
                    existing_notes.strip(),
                ]
            )
            + "\n",
            encoding="utf-8",
        )


def placeholder_prompt(title: str, section: str) -> str:
    return (
        "\n".join(
            [
                f"title: 《{title}》",
                f"source_poem_summary: {PLACEHOLDER_PROMPT_SIGNATURE}; generate only after reading the poem body and context.",
                "commentary_reading: Placeholder prompt; replace with commentary-derived reading before accepting a generated image.",
                f"key_imagery: Chapter anchor is {section}; concrete poem imagery must be filled before generation.",
                "human_subjects: To be determined from poem/commentary.",
                "camera_and_composition: Quiet portrait composition with negative space for poem layout.",
                "emotional_tone: Subdued and literary.",
                "color_palette: Muted paper-compatible palette.",
                "style: Textless Chinese-literary illustration, not louder than the poem text.",
                "negative_constraints: no text, no calligraphy, no captions, no seals, no watermark, no generic ancient-China clichés.",
            ]
        )
        + "\n"
    )


def structured_generated_prompt(
    title: str,
    section: str,
    context: str,
    poem_body: str,
    commentary_body: str,
    source_image: str | None = None,
) -> str:
    poem_lines = " / ".join(line.strip() for line in poem_body.splitlines() if line.strip())
    commentary_excerpt = re.sub(r"\s+", " ", commentary_body.strip())[:420] if commentary_body else "No commentary source available; use poem and context only."
    human_subjects = "Infer from poem/commentary; if people appear, keep them restrained, non-portrait, and subordinate to the literary scene."
    if any(word in context + poem_body + commentary_body for word in ["妻", "女", "恋", "别", "童", "家庭", "父母", "孩子"]):
        human_subjects = "Use human figures only where the poem/commentary calls for them; show role, posture, and relationship through quiet body language, not literal labels."
    return (
        "\n".join(
            [
                f"title: 《{title}》",
                f"source_poem_summary: {context or 'No explicit context.'} Poem text anchors: {poem_lines[:520]}",
                f"commentary_reading: {commentary_excerpt}",
                f"key_imagery: Select concrete images from 《{title}》, especially visible nouns, actions, landscape, weather, light, road/water/body details, and the commentary's interpretive turn.",
                f"human_subjects: {human_subjects}",
                "camera_and_composition: Portrait-oriented book illustration; quiet negative space; camera positioned like the poet's observing eye when the scene is personal, otherwise at a calm documentary-literary distance.",
                "emotional_tone: Subdued, literary, specific to the poem's pressure, tenderness, travel, reflection, or joy; never melodramatic.",
                "color_palette: Muted paper-compatible palette, low contrast, soft atmospheric depth, no saturated poster colors.",
                "style: Textless Chinese-literary painterly illustration with modern subtlety; usable behind or beside poem text and not visually louder than the poem.",
                "negative_constraints: no written characters, no captions, no calligraphy, no seals, no watermark, no generic ancient-China costume cliché, no decorative filler unrelated to the poem.",
                f"source_generated_image: {source_image or 'existing project asset'}",
            ]
        )
        + "\n"
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
