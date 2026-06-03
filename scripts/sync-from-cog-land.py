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
    split_frontmatter,
    structured_generated_prompt,
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
            notes_path = asset_dir / "illustration.notes.md"
            notes_frontmatter = {}
            if notes_path.exists():
                notes_frontmatter, _ = split_frontmatter(notes_path.read_text(encoding="utf-8"))
            if notes_frontmatter.get("image-status") in {"generated", "reviewed"}:
                source_image = None
                prompt_existing = asset_dir / "illustration.prompt.md"
                if prompt_existing.exists():
                    for line in prompt_existing.read_text(encoding="utf-8", errors="ignore").splitlines():
                        if "generated image source:" in line.lower() or "source_generated_image:" in line:
                            source_image = line.split(":", 1)[-1].strip(" `")
                commentary_body_for_prompt = ""
                if commentary_path:
                    _, commentary_body_for_prompt = read_markdown(ROOT / commentary_path)
                (asset_dir / "illustration.prompt.md").write_text(
                    structured_generated_prompt(
                        title,
                        section_name,
                        context,
                        poem_body,
                        commentary_body_for_prompt,
                        source_image=source_image,
                    ),
                    encoding="utf-8",
                )

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

    (src / "conventions.md").write_text(
        """# Conventions

本书按题材分章，章节顺序与诗作顺序承袭原《冶文斋诗选》。各章内部大体保留原有编排，不以创作年月重新排序；若需查看写作时间的先后，可参见书末《年谱》。

每首诗页以诗作为中心，依次呈现题名、正文、拼音、创作背景、配图与赏析。题名与正文尽量保留诗作原貌；背景只作读诗的入口，不替代诗本身的含蓄与留白。

拼音置于诗句上方，旨在减少生僻字、多音字造成的阅读中断。它服务于朗读与辨音，不作为训诂；若遇多音或特殊读法，以作者整理时的判断为准。

创作背景多为一句短注，说明诗作由何事、何境、何念而起。它不是题解，也不是作者对诗意的最终限定；读者仍可从诗句本身进入更宽的理解。

赏析用于帮助读者进入诗中的意象、遣词、结构与情志。部分赏析已经作者审订，部分仍保留“人工修订未完成”的提示；有提示者只代表当前整理状态，不代表定稿。

配图用于补足阅读时的气氛与想象。它依据诗作、背景与赏析生成或整理，是一种文学化阐释，并非纪实照片，也不承担对人物、地点、动作的精确复原。

年谱只列可以确认大致时间的诗作，并按年份、季节与先后排列。少数无法确认写作时间的诗作不列入年谱，以免用猜测填补空白。
""",
        encoding="utf-8",
    )
    (src / "preface.md").write_text("# 序\n\n（待补）\n", encoding="utf-8")
    (src / "postscript.md").write_text(extract_postscript_markdown(), encoding="utf-8")
    (src / "commentary-and-illustration-note.md").write_text(
        """# 赏析与配图说明

## 赏析

少年时代，我非常喜欢《唐诗鉴赏辞典》，它对每一首诗从创作背景、遣词炼句到意象、主旨都有详尽深入的解读，算是在鉴赏上对我最初的启蒙。

时至今日，生成式大语言模型已经能够在引导下对我的诗作进行有效的赏析。本书所收赏析，正是在这种辅助下起草，再由作者逐篇校读、修订、取舍而成。理想状态并不是把诗意解释得一览无余，而是替读者点亮几处入口：创作背景如何进入诗句，某个字为什么不换成更平常的字，几组意象之间如何互相牵动，诗中有意留下的空白又应当停在何处。

写作赏析时，我尽量要求它回到诗本身。创作背景是第一锚点，诗句的顺序、用字、意象与句法是第二锚点；赏析可以提出读法，却不应替诗作下最后判词。对于近体诗而言，许多意味正存在于压缩、转折与未言明之处，若把每一处都翻成直白的情绪说明，反而会伤到诗的余味。

值得说明的是，大语言模型难免有过度解读或者牵强附会之处，偏差较大的，已经尽量通过引导去除；有一些虽和创作时的想法不完全一样，却能打开新的读法，又不违背诗句与背景的，则会予以保留。未标明已经人工修订的赏析，只是当前整理阶段的参考文本，读者宜以诗作为本。

## 配图

本书配图也借助生成式图像模型完成。它的作用不是替诗配一张“说明图”，而是从诗作、背景与赏析中提炼可见的场景、姿态、物象、光色与情绪，使读者在进入诗页时，先获得一层气氛上的牵引。

配图生成前，会先写出文字化的视觉 brief：哪些元素必须出现，哪些元素不能出现，场景应在何处，人物之间是什么关系，动作应当停在哪一刻，物件是否真的来自诗中，还是只是容易误导的象征替代。之后再把 brief 写成可以直接生成图像的提示词。这样做，是为了让图像模型执行已经确定的视觉故事，而不是让它临场解释诗意。

若诗作原本附有照片，照片只提供光色、地点、氛围或物件线索，不直接等同于最终插图。涉及家人、朋友、旅伴等私人经验时，配图也会尽量避免可识别面孔，把重心放在姿态、关系、环境与气氛上。

配图最容易出错之处，在于把抽象词硬变成道具，或把诗中暗示的力量画成过分直白的动作。因此本书的配图更偏向用姿态、留白、光线、痕迹与场景结构来表达。例如某种“被外力改变”的感觉，未必要画出一只手；一种“不再追逐”的心境，也未必要放下一只杯子。图像若能保留诗的含蓄，而不是替诗说尽，才算合适。

这些插图因此都只能看作文学化阐释。它们不作为纪实证据，也不保证对真实人物、地点、天气、器物的精确复原。若读者觉得图像与诗句之间仍有距离，那距离本身也可以作为重新回到诗句的契机。
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
