#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import re

from common import (
    PASS3_PRESERVE_ORIGINAL,
    PASS3_REGENERATE,
    ROOT,
    clean_poem_body,
    load_book,
    read_markdown,
    split_frontmatter,
)


VISUALS: dict[str, dict[str, str]] = {
    "启步": {
        "reading": "A mundane but serious restart: the poem turns failed self-promises into one durable night-running step.",
        "thesis": "Show ordinary self-discipline beginning in the dark, not athletic triumph.",
        "scene": "A dim riverside or park path at night, with one slightly heavy modern runner moving away under warm lamps.",
        "foreground": "Soft path edge, faint fallen leaves, and a low pool of lamplight near the runner's feet.",
        "middle": "The runner seen from behind, small but clear, mid-stride with effort and restraint.",
        "background": "A receding row of lamps, trees, and pale city silhouettes dissolved into paper haze.",
        "figures": "One non-identifying adult runner; no close face, no brand logo, no heroic pose.",
        "camera": "Standing behind and slightly left of the runner at calm walking distance.",
        "symbol": "The lamp-lit path maps to '启步'; the small body shadow maps to the poem's self-aware '胖影'.",
    },
    "自然": {
        "reading": "A philosophical negation of striving: truth appears when pursuit and thirst fall away.",
        "thesis": "Use sparse natural vitality and open space to show '实相在心豁'.",
        "scene": "A quiet branch or bamboo stem leaning into pale air beside an empty washed landscape.",
        "foreground": "Light grasses and stone wash at the lower right.",
        "middle": "A single bamboo or slender branch, alive but not decorative.",
        "background": "Open cream mist with barely visible distant water and birds.",
        "figures": "No human figure.",
        "camera": "Still-life distance, level with the branch, with wide negative space.",
        "symbol": "Open blankness maps to the mind becoming clear; the living branch maps to unforced nature.",
    },
    "哧溜": {
        "reading": "Childlike creek play: quick fish, cold shallow water, and the comic failure of capture.",
        "thesis": "Show the moment a fish vanishes into muddied current rather than a static landscape.",
        "scene": "A shallow mountain creek with a small hand net hovering above rippled water as a fish slips away.",
        "foreground": "Wet stones, a bamboo-handled net, and splashed water.",
        "middle": "A quick silver fish shape disappearing into stirred brown-green current.",
        "background": "Cool creek banks and soft foliage in pale October light.",
        "figures": "Only partial hands or a small crouched silhouette if needed; no identifiable face.",
        "camera": "Low close view above the creek surface, angled like someone crouching to catch fish.",
        "symbol": "The vanishing fish maps to '倏而没湍泥'; the net's emptiness keeps the poem's playful tone.",
    },
    "喜临": {
        "reading": "The poem moves from anxious envy of family life to sudden pregnancy joy, figured as sprouting beans and blooming mountain flowers.",
        "thesis": "Show private domestic joy arriving like first spring growth, not a literal medical scene.",
        "scene": "A quiet home table or windowsill with a small sprout, soft flowers, and morning light after news of pregnancy.",
        "foreground": "Tiny bean sprout in a cup or dish, warm fabric, and a small domestic object.",
        "middle": "A softly lit pair of adult hands near the sprout, suggesting shared news without showing faces.",
        "background": "Window glow and blurred spring flowers, hinting at '山花烂漫'.",
        "figures": "Anonymous adult hands only; no pregnant body close-up, no ultrasound, no baby imagery.",
        "camera": "Intimate tabletop view, slightly above and close, but with open space for poem text.",
        "symbol": "The sprout maps to '豆发芽'; flowers map to joy arriving after hesitation.",
    },
    "孤僧": {
        "reading": "A solitary monk image carries discipline, distance, and inner quiet rather than tourist scenery.",
        "thesis": "Use one small monk-like figure in a vast muted landscape to show chosen solitude.",
        "scene": "A lone robed figure walking beside misty cliffs and sparse trees at dawn.",
        "foreground": "Stone path, dry grasses, and a small shadow.",
        "middle": "The solitary figure, back turned, moving slowly.",
        "background": "Layered mountains and pale sky fading into paper grain.",
        "figures": "One non-identifying monk-like silhouette; restrained, no theatrical costume detail.",
        "camera": "Long shot from behind, slightly elevated.",
        "symbol": "Distance and empty mountain air map to the poem's inward separation.",
    },
    "心印": {
        "reading": "An intimate emotional imprint: affection remains as a quiet mark rather than a dramatic scene.",
        "thesis": "Show memory as a small, durable trace in ordinary light.",
        "scene": "A quiet desk or window with a faint pressed mark, folded paper, and soft evening light.",
        "foreground": "Paper fiber, a cup rim, and a subtle handprint-like or seal-like trace without literal text.",
        "middle": "A pair of overlapping shadows or hands just out of frame.",
        "background": "Warm room light fading into blank paper space.",
        "figures": "No faces; only implied human presence through hands or shadows.",
        "camera": "Close still-life, top-oblique angle.",
        "symbol": "The trace maps to '印'; paired shadows map to emotional connection.",
    },
    "心意": {
        "reading": "A gift or intention carried quietly; emotional value comes from restraint and care.",
        "thesis": "Show careful preparation of a small token, not sentimental display.",
        "scene": "A small wrapped object or letter on a wooden table beside soft plant shadow.",
        "foreground": "Folded cloth, string, and paper texture.",
        "middle": "The prepared token, centered but modest.",
        "background": "A calm interior with light falling from one side.",
        "figures": "Optional partial hand placing the token; no face.",
        "camera": "Tabletop close view with generous negative space.",
        "symbol": "The wrapped token maps to intention held in reserve.",
    },
    "沉沦": {
        "reading": "Pressure and downward pull dominate, but the poem needs human fatigue rather than spectacle.",
        "thesis": "Show a figure weighed by dim interior shadow and sinking posture.",
        "scene": "A muted room or underpass-like interior with one seated figure leaning forward in low light.",
        "foreground": "Dark floor wash, scattered papers or rain-dark reflections.",
        "middle": "Small hunched figure, non-identifying, shoulders lowered.",
        "background": "Heavy vertical shadows and a faint far exit glow.",
        "figures": "One anonymous adult figure; no melodrama, no horror.",
        "camera": "Medium-long view from slightly above, emphasizing surrounding pressure.",
        "symbol": "Downward shadows map to sinking; distant glow keeps the image from becoming despair-only.",
    },
    "穿越": {
        "reading": "Moving through an obstacle or threshold; the poem needs passage, not fantasy time travel.",
        "thesis": "Show a person crossing from rain-dark steps into pale light.",
        "scene": "A narrow stair, bridge, or corridor with wet stone and a figure passing through.",
        "foreground": "Wet steps and reflected light.",
        "middle": "A small walking figure, umbrella or coat suggested, moving across the threshold.",
        "background": "Layered vertical architecture dissolving into brightness.",
        "figures": "One non-identifying traveler, back or side view.",
        "camera": "Slightly low corridor perspective, emphasizing passage.",
        "symbol": "The threshold maps to crossing difficulty; light maps to emergence.",
    },
    "流迁": {
        "reading": "Life and work move through changing places; the emotion is drift with continuity.",
        "thesis": "Use a moving-water/road image with one carried object to show migration without chaos.",
        "scene": "A riverbank road or station-like edge where water, path, and distant buildings overlap.",
        "foreground": "A small suitcase or bag near puddled ground.",
        "middle": "A lone figure walking along water or road.",
        "background": "Distant city blocks and river haze.",
        "figures": "One anonymous adult figure; posture steady, not lost.",
        "camera": "Wide quiet view from behind and to the side.",
        "symbol": "Water and road map to movement; the carried bag maps to continuity of self.",
    },
    "返初": {
        "reading": "A return to origin through forest, bridge, stone color, and water; the poem seeks cleaned simplicity.",
        "thesis": "Show a quiet wooden bridge and clear water as return to first clarity.",
        "scene": "A small wooden bridge over green-blue water, with stone colors and forest wind.",
        "foreground": "Mossy stones and water edge.",
        "middle": "Simple bridge and a path crossing without footprints.",
        "background": "Soft forest, distant bird shapes, and calm light.",
        "figures": "No dominant figure; a tiny walker may appear only as scale.",
        "camera": "Eye-level landscape vignette, calm and slightly withdrawn.",
        "symbol": "Bridge and path map to return; clear water maps to washed mind.",
    },
    "途遇": {
        "reading": "Travel interruption by landslide becomes a study in order, risk, and gratitude for rescue.",
        "thesis": "Show roadside danger held in calm order, not disaster spectacle.",
        "scene": "A mountain road stopped by fallen rocks at dusk, with vehicles waiting in an orderly line and rescue machinery suggested.",
        "foreground": "Road edge, warning stones, and damp asphalt.",
        "middle": "A stopped vehicle line and a small group waiting calmly.",
        "background": "Steep cliff wall, fresh slide mark, and clearing sky threatening evening rain.",
        "figures": "Tiny anonymous travelers and workers, no close faces.",
        "camera": "Roadside documentary-literary distance, looking along the queue toward the blockage.",
        "symbol": "Orderly queue maps to '队序如安'; cliff and clouds map to suspended risk.",
    },
}

PRESERVE_VISUALS = {
    "夜会": "Preserve the accepted intimate night-meeting image; normalize sidecars only.",
    "疹热": "Preserve the accepted family fever-night image; normalize sidecars only.",
    "十月": "Preserve the accepted quiet pregnancy/memory image; normalize sidecars only.",
    "岩浆": "Preserve the accepted pressure/underground heat image; normalize sidecars only.",
    "泛舟": "Preserve the accepted boat-on-water travel image; normalize sidecars only.",
    "湖畔": "Preserve the accepted lakeside travel image; normalize sidecars only.",
    "月谷": "Preserve the accepted blue-moon valley travel image; normalize sidecars only.",
}


def one_line(value: str, limit: int = 520) -> str:
    return re.sub(r"\s+", " ", value.strip())[:limit]


def yamlish(fields: list[tuple[str, str]]) -> str:
    return "\n".join(f"{key}: {value}" for key, value in fields) + "\n"


def source_images(frontmatter: dict) -> list[str]:
    result = []
    for raw in frontmatter.get("images") or []:
        path = str(raw).replace("~", str(Path.home()), 1)
        result.append(path)
    return result


def source_observation(title: str, images: list[str]) -> tuple[str, str, str]:
    if not images:
        return (
            "No source photos in poem frontmatter; visual design is derived from poem context and commentary.",
            "No source-photo palette; use muted paper-compatible colors chosen from the poem's emotional register.",
            "No source-photo place cues; scene design comes from poem imagery and commentary.",
        )
    joined = "; ".join(images)
    if title == "喜临":
        return (
            f"Source photo path(s): {joined}. Treat as private domestic reference: use warm indoor daylight, ordinary family-life softness, and springlike warmth; do not copy faces or exact composition.",
            "Warm cream, gentle flower colors, soft daylight, subdued green from domestic plants or spring growth.",
            "Domestic/private-life cues and new-family atmosphere, redesigned as sprout and tabletop scene.",
        )
    if title == "返初":
        return (
            f"Source photo path(s): {joined}. Use outdoor walk palette, water/stone/wood cues, and quiet travel atmosphere; do not copy the exact photograph.",
            "Green-blue water, weathered wood, mossy gray stone, pale daylight.",
            "Wooden bridge, forest path, stones, and water as cues for return-to-origin imagery.",
        )
    if title == "途遇":
        return (
            f"Source photo path(s): {joined}. Use mountain-road interruption cues: cliff, road, vehicles, slide debris, dusk/travel light; redesign without copying private travelers.",
            "Road gray, cliff earth, muted vehicle colors, thin evening blue, possible rain-dark asphalt.",
            "Mountain road, landslide, waiting vehicles, and rescue order as place/object cues.",
        )
    return (
        f"Source photo path(s): {joined}. Use palette, light, and place atmosphere only; do not copy faces or exact composition.",
        "Palette derived from the source photo atmosphere, moderated for low-contrast paper layout.",
        "Place/object cues from source photo, redesigned as a literary illustration.",
    )


def note_frontmatter(path: Path) -> dict:
    if not path.exists():
        return {}
    text = path.read_text(encoding="utf-8", errors="ignore")
    frontmatter, _ = split_frontmatter(text)
    return frontmatter


def make_brief(title: str, poem_path: str, commentary_path: str | None, poem_fm: dict, poem_body: str, commentary_body: str, visual: dict[str, str], scope: str) -> str:
    images = source_images(poem_fm)
    observation, palette, cues = source_observation(title, images)
    is_regen = scope == "pass3-regenerate"
    return yamlish(
        [
            ("title", f"《{title}》"),
            ("source_files", f"{poem_path}; {commentary_path or 'no commentary file'}"),
            ("poem_context", poem_fm.get("context", "")),
            ("poem_reading", visual.get("reading", one_line(poem_body)) if is_regen else one_line(poem_body)),
            ("commentary_interpretation", one_line(commentary_body, 700) or "No included commentary; use poem context and body only."),
            ("source_image_paths", "; ".join(images) or "none"),
            ("source_image_observations", observation),
            ("palette_from_source_images", palette),
            ("lighting_from_source_images", "Use low-contrast literary light; if source photos exist, inherit their daylight/night/dusk quality without copying composition."),
            ("place_or_object_cues_from_source_images", cues),
            ("visual_thesis", visual["thesis"] if is_regen else str(visual)),
            ("main_scene", visual["scene"] if is_regen else str(visual)),
            ("foreground", visual["foreground"] if is_regen else "Preserve existing accepted image; no new foreground design."),
            ("middle_ground", visual["middle"] if is_regen else "Preserve existing accepted image; no new middle-ground design."),
            ("background", visual["background"] if is_regen else "Preserve existing accepted image; no new background design."),
            ("human_figures", visual["figures"] if is_regen else "Preserve existing accepted figure treatment."),
            ("camera_position", visual["camera"] if is_regen else "Preserve existing accepted camera treatment."),
            ("composition", "Portrait 2:3 book illustration, quiet negative space, right/central image mass where possible, no overpowering contrast."),
            ("symbolic_mapping", visual["symbol"] if is_regen else "Existing accepted symbolic mapping is preserved."),
            ("page_layout_role", "Visible poem-page illustration supporting adjacent/overlaid text; readable as a literary panel, not a standalone poster."),
            ("avoid", "No text, captions, calligraphy, seals, watermark, generic ancient-China costume cliché, photorealism, private likeness copying, saturated poster colors."),
        ]
    )


def make_prompt(title: str, brief: str, visual: dict[str, str] | str, scope: str, source_generated: str) -> str:
    if scope != "pass3-regenerate":
        scene = str(visual)
        subjects = "Preserve existing accepted generated image; no regeneration requested."
        fg = mid = bg = "Preserve existing accepted composition."
        camera = "Preserve existing accepted camera treatment."
        light = "Preserve existing accepted palette and light."
        final_prompt = "Preserve the existing accepted image asset. This sidecar records pass3 scope and should not be used for regeneration unless the user explicitly rejects the preserved original."
    else:
        v = visual
        scene = v["scene"]
        subjects = v["figures"]
        fg = v["foreground"]
        mid = v["middle"]
        bg = v["background"]
        camera = v["camera"] + " " + "Portrait 2:3 with generous negative space for poem layout."
        light = "Muted paper-compatible palette, low contrast, soft atmospheric depth; apply source-photo palette only as vibe/place reference when available."
        final_prompt = (
            f"Create a textless quiet Chinese-literary illustration for 《{title}》. "
            f"Scene: {scene} Foreground: {fg} Middle ground: {mid} Background: {bg} "
            f"Human/subject treatment: {subjects} Camera/composition: {camera} "
            f"Symbolic intent: {v['symbol']} Keep it restrained, page-compatible, and visually quieter than the poem text."
        )
    return yamlish(
        [
            ("title", f"《{title}》"),
            ("use_case", "illustration-story"),
            ("asset_type", "portrait 2:3 illustration for a Typst Chinese poem book page"),
            ("primary_request", f"Execution-ready textless illustration for 《{title}》; do not add typography."),
            ("scene_backdrop", scene),
            ("subjects_and_actions", subjects),
            ("foreground", fg),
            ("middle_ground", mid),
            ("background", bg),
            ("camera_and_composition", camera),
            ("light_and_color", light),
            ("style", "Textless contemporary Chinese literary illustration, ink-wash plus soft gouache, fine paper grain, restrained detail."),
            ("page_layout_constraints", "Leave quiet negative space and low contrast so poem, pinyin, context, and commentary remain dominant and legible."),
            ("negative_constraints", "No text, no Chinese characters, no calligraphy, no seals, no watermark, no labels, no AI-art orbs, no bokeh blobs, no generic ancient-China costume cliché, no photorealistic private likeness."),
            ("final_image_prompt", final_prompt),
            ("source_generated_image", source_generated or "pending-pass3-generation"),
        ]
    )


def notes(title: str, poem_path: str, commentary_path: str | None, poem_fm: dict, scope: str, source_generated: str, image_status: str) -> str:
    images = source_images(poem_fm)
    review_status = "preserved-original-seven" if scope == "preserve-original-seven" else "needs-pass3-image-generation"
    if scope == "pass3-regenerate" and source_generated and source_generated != "pending-pass3-generation":
        review_status = "generated-pass3"
    frontmatter = yamlish(
        [
            ("image-status", image_status),
            ("prompt-source", "pass3-brief"),
            ("brief-status", "pass3-written"),
            ("review-status", review_status),
            ("source-poem", poem_path),
            ("source-commentary", commentary_path or "none"),
            ("source-images", "; ".join(images) or "none"),
            ("generation-tool", "built-in image_gen" if scope == "pass3-regenerate" and source_generated and source_generated != "pending-pass3-generation" else "not-run"),
            ("generated-image-source", source_generated or "pending-pass3-generation"),
            ("regeneration-scope", scope),
            ("human-feedback", "pass3 image concept remediation; original seven preserved unless explicitly rejected"),
        ]
    )
    return f"---\n{frontmatter}---\n\n《{title}》pass3 image lifecycle metadata.\n"


def main() -> int:
    book = load_book()
    poem_by_title = {poem["title"]: poem for section in book["sections"] for poem in section["poems"]}
    for title in sorted(PASS3_PRESERVE_ORIGINAL | PASS3_REGENERATE):
        poem = poem_by_title[title]
        poem_fm, poem_body_raw = read_markdown(ROOT / poem["path"])
        poem_body = clean_poem_body(poem_body_raw, poem_fm.get("context"))
        commentary_body = ""
        if poem.get("commentary"):
            _, commentary_body = read_markdown(ROOT / poem["commentary"])
        asset_dir = ROOT / "assets" / "poems" / poem["slug"]
        note_path = asset_dir / "illustration.notes.md"
        note_fm = note_frontmatter(note_path)
        source_generated = note_fm.get("generated-image-source") or note_fm.get("source-generated-image") or "pending-pass3-generation"
        if title in PASS3_PRESERVE_ORIGINAL:
            scope = "preserve-original-seven"
            visual = PRESERVE_VISUALS[title]
            image_status = note_fm.get("image-status", "generated")
        else:
            scope = "pass3-regenerate"
            visual = VISUALS[title]
            image_status = note_fm.get("image-status", "generated")
        brief = make_brief(title, poem["path"], poem.get("commentary"), poem_fm, poem_body, commentary_body, visual, scope)
        (asset_dir / "illustration.brief.md").write_text(brief, encoding="utf-8")
        (asset_dir / "illustration.prompt.md").write_text(
            make_prompt(title, brief, visual, scope, source_generated),
            encoding="utf-8",
        )
        (asset_dir / "illustration.notes.md").write_text(
            notes(title, poem["path"], poem.get("commentary"), poem_fm, scope, source_generated, image_status),
            encoding="utf-8",
        )
    print(f"wrote pass3 briefs/prompts/notes for {len(PASS3_PRESERVE_ORIGINAL | PASS3_REGENERATE)} assets")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
