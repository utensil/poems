#!/usr/bin/env python3
from __future__ import annotations

import shutil
from collections import defaultdict

import yaml

from common import (
    AUTO_PINYIN,
    COG_POEMS,
    COMMENTARY_WARNING,
    ROOT,
    SKILL_TEMPLATE,
    clean_poem_body,
    copy_or_create_asset,
    extract_postscript_markdown,
    find_commentaries,
    INCLUDED_COMMENTARY,
    UNREVIEWED_COMMENTARY,
    pinyin_overrides,
    poem_order_from_main_tex,
    read_markdown,
    safe_title,
    season_for_date,
    write_markdown,
)


def main() -> None:
    src = ROOT / "src"
    poem_root = src / "poems"
    commentary_root = src / "commentaries"
    asset_root = ROOT / "assets" / "poems"
    template_root = ROOT / "templates"

    for path in [poem_root, commentary_root, asset_root, template_root]:
        path.mkdir(parents=True, exist_ok=True)

    order = poem_order_from_main_tex()
    commentaries = find_commentaries()
    book = {"title": "冶文斋诗选", "sections": []}
    chronology = defaultdict(list)
    undated: list[str] = []

    for section_name, titles in order.items():
        section_entry = {"title": section_name, "poems": []}
        for index, title in enumerate(titles, start=1):
            slug = safe_title(title)
            source = COG_POEMS / f"{title}.md"
            frontmatter, body = read_markdown(source)
            context = frontmatter.get("context", "")
            local_poem = poem_root / section_name / f"{slug}.md"
            poem_frontmatter = {
                "title": title,
                "section": section_name,
                "context": context,
            }
            for key in ["original-written", "images", "pinyin"]:
                if key in frontmatter:
                    poem_frontmatter[key] = frontmatter[key]
            poem_body = clean_poem_body(body, context)
            if title == "启步":
                poem_frontmatter["layout"] = {
                    "line-breaks": [
                        "脂重乏肌显体圆，",
                        "志虚轻誓总断延。",
                        "鞋环衣裤皆齐备，",
                        "东风乍起旗又偃。",
                        "午间会后健房满，",
                        "晨床迟起无澡时。",
                        "轻装放空入夜丛，",
                        "野径路灯伴胖影。",
                        "汗酣血活心宇阔，",
                        "设标昂首越路人。",
                        "面红气短歇不停，",
                        "耳乐恢宏重拾步。",
                        "踝适膝承喘渐平，",
                        "脚下里程腋成裘。",
                        "配速虽缓阶踏实，",
                        "此战持久莫急求。",
                    ]
                }
                poem_body = "\n".join(poem_frontmatter["layout"]["line-breaks"])
            write_markdown(local_poem, poem_frontmatter, poem_body)

            commentary_path = None
            commentary_status = None
            if title in commentaries:
                c_frontmatter, c_body = read_markdown(commentaries[title])
                commentary_status = c_frontmatter.get("commentary-status")
                if commentary_status in INCLUDED_COMMENTARY:
                    local_commentary = commentary_root / section_name / f"{slug}.md"
                    normalized = dict(c_frontmatter)
                    normalized["title"] = c_frontmatter.get("title", f"《{title}》赏析")
                    normalized["poem"] = f"src/poems/{section_name}/{slug}.md"
                    normalized["section"] = section_name
                    if commentary_status in UNREVIEWED_COMMENTARY and not c_body.lstrip().startswith(COMMENTARY_WARNING):
                        c_body = f"{COMMENTARY_WARNING}\n\n{c_body.strip()}\n"
                    write_markdown(local_commentary, normalized, c_body)
                    commentary_path = local_commentary.relative_to(ROOT).as_posix()

            asset_dir = asset_root / slug
            copy_or_create_asset(title, section_name, asset_dir)

            dated = None if title in {"夜会", "心印"} else season_for_date(frontmatter.get("original-written"))
            if dated is None:
                undated.append(title)
            else:
                period, sort_key = dated
                chronology[(sort_key, period)].append(title)

            section_entry["poems"].append(
                {
                    "title": title,
                    "slug": slug,
                    "order": index,
                    "path": local_poem.relative_to(ROOT).as_posix(),
                    "commentary": commentary_path,
                    "commentary-status": commentary_status,
                    "asset": f"assets/poems/{slug}/illustration.png",
                    "prompt": f"assets/poems/{slug}/illustration.prompt.md",
                    "pinyin-overrides": pinyin_overrides(poem_frontmatter),
                }
            )
        book["sections"].append(section_entry)

    (src / "book.yaml").write_text(
        yaml.safe_dump(book, allow_unicode=True, sort_keys=False), encoding="utf-8"
    )

    chronology_entries = [
        {"period": period, "sort": sort_key, "poems": poems}
        for (sort_key, period), poems in sorted(chronology.items())
    ]
    (src / "chronology.yaml").write_text(
        yaml.safe_dump(
            {"entries": chronology_entries, "undated-skipped": sorted(undated)},
            allow_unicode=True,
            sort_keys=False,
        ),
        encoding="utf-8",
    )

    (src / "fanli.md").write_text(
        """# 凡例

本书按题材分章，章节顺序与诗作顺序承袭原《冶文斋诗选》。

每首诗页包含题名、正文、创作背景、拼音标注与插画。只有对应赏析标记为 `human-revised` 或 `reference-quality` 时，才收入并排入诗页。

拼音标注以自动查音为基础，并叠加诗作 frontmatter 中的人工修正；人工修正优先。

创作背景来自诗作 frontmatter 的 `context` 字段。

收入的赏析为 LLM 辅助起草、作者审订后的文本。方法与限制见附录《LLM 辅助赏析写作说明》。

插画是依据诗作与赏析生成的文学化阐释，不作为纪实证据或精确复原。

部分诗作缺少可确认写作时间，年谱只按年份与季节展示，未定年诗作不列入年谱。
""",
        encoding="utf-8",
    )
    (src / "preface.md").write_text("# 序\n\n（待补）\n", encoding="utf-8")
    (src / "postscript.md").write_text(extract_postscript_markdown(), encoding="utf-8")
    (src / "llm-commentary-note.md").write_text(
        """# LLM 辅助赏析写作说明

本书部分赏析由大语言模型辅助起草，再经作者审阅、修订或重写后收入。

收入标准以 frontmatter 的 `commentary-status` 为准：`human-revised` 与 `reference-quality` 可进入正文；`ai-review-only`、`iterated`、`unclear` 或缺少状态的文本不进入本书。

LLM 的作用主要是提供初稿结构、意象展开和可供反驳的解释线索。最终文本仍以作者确认后的版本为准。赏析不声称穷尽诗意，也不替代作者原始写作处境。
""",
        encoding="utf-8",
    )

    shutil.copy2(SKILL_TEMPLATE, template_root / "illustrated-poem-page.typ")
    auto_target = template_root / "auto-pinyin"
    auto_target.mkdir(parents=True, exist_ok=True)
    for name in ["lib.typ", "auto-pinyin.wasm"]:
        shutil.copy2(AUTO_PINYIN / name, auto_target / name)

    print(
        f"synced {sum(len(section['poems']) for section in book['sections'])} poems, "
        f"{sum(1 for section in book['sections'] for poem in section['poems'] if poem['commentary'])} included commentaries"
    )


if __name__ == "__main__":
    main()
