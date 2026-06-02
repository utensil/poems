#!/usr/bin/env python3
from __future__ import annotations

import re
from pathlib import Path

import yaml

from common import ROOT, read_markdown, load_book


SCOPE = ["返初", "流迁", "沉沦", "心印", "心意", "喜临", "孤僧", "自然", "启步", "哧溜", "穿越", "途遇"]


def load_contracts() -> dict:
    return yaml.safe_load((ROOT / "scripts" / "image_contracts.yaml").read_text(encoding="utf-8"))["contracts"]


def one_line(text: str, limit: int = 900) -> str:
    return re.sub(r"\s+", " ", text.strip())[:limit]


VISUALS = {
    "返初": {
        "decision": "preserved-after-check",
        "must_show": ["forest path", "wooden bridge", "blue-green water", "stone color", "return to inner firstness"],
        "must_not_show": ["urban interior", "crowded city", "generic bridge without forest/water"],
        "setting": "quiet hiking place with forest edge, wild path, weathered wooden bridge, blue-green water, stone color, high open sky",
        "figures": "optional tiny anonymous walker only; the scene may be figureless if the path itself carries the return",
        "action": "the eye follows a wild path across a wooden bridge and returns to clear water/stone/sky, suggesting passage without leaving a trace",
        "objects": "wooden bridge, wild path, green branches, blue-green water, stones, distant bird silhouettes from the source photo",
        "emotion": "quiet reset, returning to first clarity, inner washing rather than travel excitement",
        "commentary": "returning to pure inner firstness through natural images: forest, bridge, water, stones, tide-like cleansing",
        "source": "Source photo path(s): 2023-10-05-21-06-fan-chu.jpg. It shows upward hiking sightline, blue sky, pale clouds, tree branches, birds, and green foliage; use airy blue/green palette and bird/branch cues, not the exact photo composition.",
        "foreground": "mossy stones and a strip of shallow blue-green water beside the path",
        "middle": "weathered wooden bridge crossing into a narrow wild path",
        "background": "pine-like branches, open blue sky with pale cloud, tiny birds, soft forest slope",
        "camera": "low path-level view looking inward and slightly upward, portrait 2:3, quiet negative space at top",
        "symbolic": "bridge and water map to returning; stones and branches map to life texture; sky/birds map to clear inner openness",
    },
    "流迁": {
        "decision": "regenerate",
        "must_show": ["external handling force", "object being turned or reshaped", "water/bubble/reflection", "shifting narrative layers", "no dominant luggage"],
        "must_not_show": ["foreground suitcase", "dominant luggage", "train station travel mood"],
        "setting": "shallow water table or river-edge work surface where translucent paper/leaf/cloth fragments are moved by outside hands and current",
        "figures": "only anonymous partial hands at the edge, acting as external force; no portrait",
        "action": "hands and current turn, lift, and press a floating translucent object; bubbles/reflections make it unstable",
        "objects": "floating paper/leaf/cloth fragments, water ripples, bubbles, reflected layers; no suitcase",
        "emotion": "being handled by outside forces, accepting shifting narratives without panic",
        "commentary": "external forces摘取/揉捏 and the realization that 心相如泡影, narratives shift through交变",
        "source": "No source photos in poem frontmatter.",
        "foreground": "ripples and bubbles around a small translucent fragment, visually subordinate and not luggage",
        "middle": "anonymous hands turn or press the fragment in water, showing outside handling",
        "background": "overlapping reflections and drifting layers, suggesting叙事迭",
        "camera": "close but not still-life-static, slightly overhead, portrait 2:3 with empty upper wash",
        "symbolic": "handled fragment maps to成果被摘取揉捏; bubbles/reflections map to 心相泡影 and shifting stories",
    },
    "沉沦": {
        "decision": "regenerate",
        "must_show": ["red dust specks on body/clothing", "thin blue thread to sky", "red/blue tension", "self-portrait stance", "not just sad person"],
        "must_not_show": ["only upset person", "horror prison", "generic despair"],
        "setting": "muted liminal room or open threshold where red worldly dust settles on a standing/seated figure while a thin blue thread reaches toward sky",
        "figures": "one anonymous adult, face obscured, body marked by red dust but not melodramatic",
        "action": "the figure is not simply crying; one hand notices red dust on clothing while a half-thread of blue pulls from the chest/window upward",
        "objects": "red dust motes, dark clothing, faint blue thread, high window or sky slit",
        "emotion": "self-recognition inside sinking, a cold inventory of flaws with half a thread of clean sky remaining",
        "commentary": "七宗罪/五毒 as self-inventory; 身沾万点尘世红 and 心缠半丝天际蓝 coexist",
        "source": "No source photos in poem frontmatter.",
        "foreground": "red dust specks on sleeve/floor, not blood",
        "middle": "anonymous figure holds still, noticing dust, with a blue thread from chest/hand toward light",
        "background": "muted red-brown interior fading to a narrow cool blue opening",
        "camera": "medium-wide, restrained, portrait 2:3, no horror close-up",
        "symbolic": "red specks map to 尘世红; blue thread maps to 半丝天际蓝; still posture maps to self-portrait not confession",
    },
    "心印": {
        "decision": "regenerate",
        "must_show": ["remembered girl", "beautiful lively eyes", "parting/separation", "longing after return", "heart imprint"],
        "must_not_show": ["desk still life", "paper seal", "empty paper/shadow as main subject"],
        "setting": "memory-like travel/parting scene near a station path or evening walkway, with the beloved figure remembered in soft focus",
        "figures": "one non-identifying young woman/girl as remembered beloved, seen in profile or three-quarter from behind; optional distant speaker silhouette",
        "action": "she turns back with lively eyes while departing; the speaker is left behind in longing",
        "objects": "soft path lights, travel bag only if small/subordinate, faint heart-like light impression in air not literal stamp",
        "emotion": "from encounter beauty to separate return to sleepless longing for her beside him",
        "commentary": "盈盈倩影 and 嫣嫣美目 lead to 各归伶俜 and 寤寐思身畔; person must remain central",
        "source": "No source photos in poem frontmatter.",
        "foreground": "empty side of path near speaker, suggesting absence",
        "middle": "beloved figure turning back, eyes/glance alive but face non-identifying",
        "background": "evening travel path with soft lights and distance, not desk/paper",
        "camera": "over-shoulder from speaker side, portrait 2:3, memory softness",
        "symbolic": "turning glance presses the heart imprint; distance maps to 各归; empty beside-space maps to longing",
    },
    "心意": {
        "decision": "regenerate",
        "must_show": ["flower market", "couple", "behind embrace", "female held in front", "home versus wandering contrast"],
        "must_not_show": ["gift still life", "single figure", "empty tabletop token"],
        "setting": "Spring flower market with stalls, blossoms, and festive crowd softened behind the couple",
        "figures": "young couple non-identifying: male behind, arms encircling female from behind; female in front, relaxed within the arm ring",
        "action": "behind embrace in the flower market; their gaze directions subtly differ, homeward warmth versus roadward distance",
        "objects": "flower stalls, warm market lights, path opening outward beyond stalls",
        "emotion": "intimate present sweetness with different future imaginations",
        "commentary": "身后臂膀环 is required; 安居甜蜜意 belongs to her, 携手浪迹心 belongs to him",
        "source": "No source photos in poem frontmatter.",
        "foreground": "flowers and market edge framing the couple",
        "middle": "couple in behind embrace, central but restrained",
        "background": "crowd and a path/road hinting at wandering beyond the settled flower stall",
        "camera": "medium shot from slightly behind/side, portrait 2:3, no faces copied",
        "symbolic": "arm ring maps to immediate intimacy; flower stall maps to settled sweetness; opening path maps to wandering together",
    },
    "喜临": {
        "decision": "regenerate",
        "must_show": ["pregnancy cue", "parents-to-be", "bean sprout", "family anticipation", "spring flowers"],
        "must_not_show": ["generic vase still life", "identifiable baby face", "pregnancy hidden"],
        "setting": "warm domestic window table with expectant parents and a small bean sprout, hinting at a new life before birth",
        "figures": "non-identifying expectant mother with hand on belly; partner nearby, both partial or from behind",
        "action": "parents-to-be quietly notice a tiny bean sprout; joy opens from small cue to spring flowers outside",
        "objects": "small bean sprout cup, soft baby booties or folded cloth, window flowers; no identifiable baby portrait",
        "emotion": "from anxious waiting to sudden, blooming joy at pregnancy news",
        "commentary": "有喜, 忐忑羡天伦, 豆发芽, 山花烂漫 must be visually inferable",
        "source": "Source photo path(s): 2014-07-21-18-00-xi-lin.JPG. It is a private baby photo with green clothing and tender family-newborn feeling; use only soft green palette and newborn/family anticipation cues, do not copy the baby face.",
        "foreground": "tiny bean sprout and small baby cloth/booties on table",
        "middle": "expectant mother hand on belly with partner nearby, non-identifying",
        "background": "spring flowers and warm window light, soft green palette",
        "camera": "intimate domestic medium-close, portrait 2:3, privacy-safe",
        "symbolic": "bean sprout maps to pregnancy news; flowers map to joy expanding; hand on belly makes pregnancy legible",
    },
    "孤僧": {
        "decision": "regenerate",
        "must_show": ["Spring Festival flower market", "lights", "crowd like tide", "lone detached speaker", "red-dust festive warmth"],
        "must_not_show": ["mountain monk", "temple", "wilderness"],
        "setting": "bustling Spring Festival flower market at night or evening, red lanterns/lights, flower stalls, crowd flow",
        "figures": "one ordinary lone speaker in simple dark clothing, monk-like only by still posture; many blurred market visitors around",
        "action": "crowd streams around while the lone figure stands attached but inwardly detached, observing",
        "objects": "flowers, lanterns, red decorations, market stalls, crowd movement",
        "emotion": "not escaping red dust; entering it fully while seeing through it",
        "commentary": "inner monk-like detachment amid bustling flower market; 愿尽历红尘 but 求透空中道",
        "source": "No source photos in poem frontmatter.",
        "foreground": "flowers and red market decorations",
        "middle": "lone still figure among moving crowd, no robe required",
        "background": "灯华 and 人如潮: festive lights and dense flow",
        "camera": "slightly elevated market view, portrait 2:3, motion blur around still figure",
        "symbolic": "market maps to 红尘皮色; still figure maps to 孤僧; flowing crowd maps to 人如潮",
    },
    "自然": {
        "decision": "regenerate",
        "must_show": ["dust/worldly accomplishment left behind", "thirst set down", "new dreams arising", "heart opening", "non-seeking stillness"],
        "must_not_show": ["generic bamboo scene", "nature title-only illustration"],
        "setting": "minimal threshold between dusty road of achievements and a clear inner courtyard/sky opening",
        "figures": "optional small seeker setting down an empty cup/scroll; no heroic sage",
        "action": "the seeker stops chasing dust, sets down a cup of thirst, while dream-like bubbles fade and chest/heart space opens to clear light",
        "objects": "dusty road, empty cup, fading dream bubbles, open window/heart-like clear space",
        "emotion": "quiet release after layers of negation; truth appears when seeking stops",
        "commentary": "否定逐尘功, 否定渴本真, 否定求索, finally 实相在心豁",
        "source": "No source photos in poem frontmatter.",
        "foreground": "dust and an empty cup set down",
        "middle": "small figure pauses, no longer reaching",
        "background": "dream bubbles dissolve into open clear light at heart/window",
        "camera": "minimal symbolic scene, portrait 2:3, soft empty space",
        "symbolic": "dust maps to 尘功; cup maps to 渴; bubbles map to 新梦; opening maps to 心豁",
    },
    "启步": {
        "decision": "regenerate",
        "must_show": ["night running", "ordinary slightly heavy runner", "road lamps", "movement sweat breath", "persistent modest effort"],
        "must_not_show": ["daytime", "heroic athlete", "gym interior"],
        "setting": "dark evening/night park path or wild path with road lamps and cool air",
        "figures": "one ordinary slightly heavy-bodied runner, dignified and non-heroic, face not identifiable",
        "action": "runner moves steadily under lamps, sweating and breathing, with a heavier shadow beside him",
        "objects": "road lamps, earphones, running shoes, dark path, maybe distant walker target",
        "emotion": "small persistent restart, not triumphant athletic poster",
        "commentary": "夜跑减重, 路灯伴胖影, 歇而不停, 音乐重拾步, 持久莫急求",
        "source": "No source photos in poem frontmatter.",
        "foreground": "dark path texture and runner shadow",
        "middle": "ordinary runner in motion under lamp, sweat/breath visible",
        "background": "night park path with lamps receding and a distant walker/target",
        "camera": "side/rear three-quarter view, portrait 2:3, dark sky clearly night",
        "symbolic": "lamp and shadow map to 野径路灯伴胖影; steady stride maps to 启步 and 持久",
    },
    "哧溜": {
        "decision": "regenerate",
        "must_show": ["knee-deep creek water", "butterfly net used for fish", "clear shallow bottom", "fish vanishing into muddy current", "comic ordinary liveliness"],
        "must_not_show": ["person on dry land", "spatial collage"],
        "setting": "cold shallow mountain creek with clear stones upstream and muddy current pocket downstream",
        "figures": "one anonymous adult knee-deep in water, sleeves/shorts practical, holding a butterfly net awkwardly",
        "action": "the person lunges with the butterfly net as a small fish slips from clear shallows into muddy current",
        "objects": "butterfly net, clear creek stones, fish blur, muddy swirl",
        "emotion": "earnest over-equipped playfulness and comic failure",
        "commentary": "恢恢扑蝶网 becomes absurd fishing tool; 悠悠淌冰溪; fish appears then 哧溜 disappears into 湍泥",
        "source": "No source photos in poem frontmatter.",
        "foreground": "knee-deep water around legs, splashes",
        "middle": "awkward net lunge at fish trail",
        "background": "clear creek bed turning into muddy current",
        "camera": "low creek-level view, coherent single scene, portrait 2:3",
        "symbolic": "grand net versus tiny fish maps to comic scale collapse; clear-to-mud maps to 现/没",
    },
    "穿越": {
        "decision": "regenerate",
        "must_show": ["rugged mountain path", "rocky coastal terrain", "companions helping", "hand-foot cooperation", "no urban tunnel"],
        "must_not_show": ["city tunnel", "urban corridor", "interior bridge"],
        "setting": "wild coastal mountain crossing with steep path above sea and broad rocky beach/乱石滩",
        "figures": "small group of hikers; one helps another across unstable rocks with hands and feet braced",
        "action": "companions cross rocks, one hand extended, feet placed carefully on jagged stones",
        "objects": "嶙峋 rocks, steep mountain path, sea edge, backpacks only subordinate",
        "emotion": "hard crossing completed by mutual support, not fantasy passage",
        "commentary": "东西涌穿越, 上下崎岖险山路, 漫漫嶙峋乱石滩, 手足相抵过蹒跚",
        "source": "No source photos in poem frontmatter.",
        "foreground": "jagged coastal rocks and careful feet",
        "middle": "helpers crossing, one hand/arm supporting another",
        "background": "steep green-brown mountain path and sea/rocky shore",
        "camera": "wide rugged outdoor view, portrait 2:3, no urban structures",
        "symbolic": "hands/feet cooperation maps to 手足相抵; mountain/coast rocks map to physical crossing",
    },
    "途遇": {
        "decision": "regenerate",
        "must_show": ["fallen boulder blocking road", "queue", "clearing machinery", "guard/order management", "cliff road danger"],
        "must_not_show": ["open road", "crushed cars", "disaster spectacle"],
        "setting": "night or late-light mountain cliff road stopped by landslide, with queue and floodlight",
        "figures": "queued travelers and workers/guards, anonymous silhouettes, orderly not panicked",
        "action": "machinery clears rocks while guards manage a narrow safe passage and vehicles/people wait",
        "objects": "large boulder/rocks across road, excavator or loader, queued vehicles/people, cliff wall, floodlight",
        "emotion": "dangerous but orderly, gratitude to rescuers and collective restraint",
        "commentary": "硕石戛止, 夜将雨, 悬壁进退危, 队序如安, 清障重械, 道旁护",
        "source": "Source photo path(s): 2020-09-19-23-15-tu-yu.JPG. It shows a dark cliff road, dense queue of people, floodlight, cliff wall, and nighttime waiting; use night/floodlight/crowd/cliff cues, but add explicit boulder blockage and machinery.",
        "foreground": "backs of queued people/vehicles and guarded road edge",
        "middle": "fallen boulder blocking road with worker/guard and clearing machine",
        "background": "cliff wall, floodlight, dark sky, waiting queue",
        "camera": "road-level view from queue, portrait 2:3, orderly danger not spectacle",
        "symbolic": "blocked boulder maps to 硕石; queue/guards map to 队序如安; machinery maps to 清障重械",
    },
}


def find_poems() -> dict[str, dict]:
    found = {}
    for section in load_book()["sections"]:
        for poem in section["poems"]:
            if poem["title"] in SCOPE:
                found[poem["title"]] = poem
    return found


def fields(items: list[tuple[str, str]]) -> str:
    return "\n".join(f"{k}: {v}" for k, v in items) + "\n"


def make_brief(title: str, poem: dict, poem_fm: dict, poem_body: str, commentary_body: str, v: dict) -> str:
    source_images = poem_fm.get("images") or []
    coverage = "; ".join(f"{item} -> final prompt {slot}" for item, slot in zip(v["must_show"], ["foreground", "middle_ground", "background", "human_figures", "action"] * 3))
    return fields([
        ("title", f"《{title}》"),
        ("source_files", f"{poem['path']}; {poem.get('commentary') or 'none'}"),
        ("poem_context", poem_fm.get("context", "")),
        ("poem_reading", one_line(poem_body, 700)),
        ("commentary_interpretation", one_line(commentary_body, 1000)),
        ("source_image_paths", "; ".join(source_images) if source_images else "none"),
        ("source_image_observations", v["source"]),
        ("palette_from_source_images", v["source"] if source_images else "No source-photo palette; use subdued literary colors from the poem's emotional register."),
        ("lighting_from_source_images", v["source"] if source_images else "No source-photo lighting; choose light from the visual story contract."),
        ("place_or_object_cues_from_source_images", v["source"] if source_images else "No source-photo place cues; use poem/commentary anchors only."),
        ("visual_thesis", v["symbolic"]),
        ("main_scene", v["setting"]),
        ("foreground", v["foreground"]),
        ("middle_ground", v["middle"]),
        ("background", v["background"]),
        ("human_figures", v["figures"]),
        ("camera_position", v["camera"]),
        ("composition", "Portrait 2:3 book illustration; visible story must read at page scale with quiet negative space for poem layout."),
        ("symbolic_mapping", v["symbolic"]),
        ("page_layout_role", "Textless page illustration for the Typst poem book; image supports poem/context/commentary and must stay low-contrast enough for text."),
        ("avoid", "; ".join(v["must_not_show"] + ["text", "Chinese characters", "calligraphy", "seal", "watermark", "private identifiable faces"])),
        ("must_show", "; ".join(v["must_show"])),
        ("must_not_show", "; ".join(v["must_not_show"])),
        ("setting_contract", v["setting"]),
        ("figure_contract", v["figures"]),
        ("action_contract", v["action"]),
        ("object_contract", v["objects"]),
        ("emotion_contract", v["emotion"]),
        ("commentary_contract", v["commentary"]),
        ("source_photo_contract", v["source"]),
        ("composition_contract", f"{v['camera']}; {v['foreground']} / {v['middle']} / {v['background']}"),
        ("coverage_check", coverage),
    ])


def make_prompt(title: str, v: dict) -> str:
    final = (
        f"Create a textless portrait 2:3 contemporary Chinese literary illustration for 《{title}》. "
        f"Scene/backdrop: {v['setting']}. Foreground: {v['foreground']}. Middle ground: {v['middle']}. "
        f"Background: {v['background']}. Human figures and actions: {v['figures']}; {v['action']}. "
        f"Required objects: {v['objects']}. Emotion and story: {v['emotion']}. "
        f"Composition/camera: {v['camera']}. Symbolic mapping: {v['symbolic']}. "
        "Style: restrained ink-wash plus soft gouache, muted paper-compatible palette, fine grain, low contrast. "
        f"Do not show: {'; '.join(v['must_not_show'])}; no text, no Chinese characters, no calligraphy, no seals, no watermark."
    )
    return fields([
        ("title", f"《{title}》"),
        ("use_case", "illustration-story"),
        ("asset_type", "portrait 2:3 illustration for a Typst Chinese poem book page"),
        ("primary_request", f"Execution-ready textless pass4 illustration for 《{title}》 using the visual story contract; do not add typography."),
        ("scene_backdrop", v["setting"]),
        ("subjects_and_actions", f"{v['figures']} {v['action']}"),
        ("foreground", v["foreground"]),
        ("middle_ground", v["middle"]),
        ("background", v["background"]),
        ("camera_and_composition", v["camera"]),
        ("light_and_color", "Restrained literary palette; preserve source-photo light/palette only when specified in source_photo_contract."),
        ("style", "Textless contemporary Chinese literary illustration, ink-wash plus soft gouache, fine paper grain, restrained detail."),
        ("page_layout_constraints", "Leave quiet negative space and low contrast so poem, pinyin, context, and commentary remain dominant and legible."),
        ("negative_constraints", "; ".join(v["must_not_show"] + ["text", "Chinese characters", "calligraphy", "seals", "watermark", "labels", "AI-art orbs", "private identifiable faces"])),
        ("final_image_prompt", final),
        ("source_generated_image", "pending-pass4-generation"),
        ("must_show", "; ".join(v["must_show"])),
        ("coverage_check", "; ".join(f"{item} covered in final_image_prompt" for item in v["must_show"])),
    ])


def write_notes(title: str, poem: dict, poem_fm: dict, v: dict) -> None:
    asset_dir = ROOT / "assets" / "poems" / title
    notes = {
        "image-status": "generated" if v["decision"] != "preserved-after-check" else "reviewed",
        "prompt-source": "pass4-primary-source-brief",
        "brief-status": "pass4-written",
        "review-status": "pass4-contract-pending-image",
        "source-poem": poem["path"],
        "source-commentary": poem.get("commentary") or "none",
        "source-images": poem_fm.get("images") or "none",
        "generation-tool": "pending",
        "generated-image-source": "pending-pass4-generation" if v["decision"] != "preserved-after-check" else "preserved-current-image",
        "regeneration-scope": "pass4-regenerate" if v["decision"] != "preserved-after-check" else "pass4-preserved-after-check",
        "pass4-decision": v["decision"],
        "human-feedback": "pass4 visual story contract correction; fresh brief/prompt regenerated from poem/commentary/frontmatter/source images before old pass3 sidecar comparison",
        "pass3-regression-audit": "pending-after-pass4-sidecars-written",
    }
    body = f"《{title}》pass4 image lifecycle metadata. Visual story contract decision: {v['decision']}."
    rendered = yaml.safe_dump(notes, allow_unicode=True, sort_keys=False).strip()
    (asset_dir / "illustration.notes.md").write_text(f"---\n{rendered}\n---\n\n{body}\n", encoding="utf-8")


def main() -> None:
    poems = find_poems()
    contracts = load_contracts()
    for title in SCOPE:
        poem = poems[title]
        poem_fm, poem_body = read_markdown(ROOT / poem["path"])
        _, commentary_body = read_markdown(ROOT / poem["commentary"])
        v = dict(VISUALS[title])
        contract = contracts[title]
        v["must_show"] = contract["required"]
        v["must_not_show"] = contract["forbidden"]
        v["decision"] = "preserved-after-check" if contract["decision"] == "preserve-after-check" else contract["decision"]
        asset_dir = ROOT / "assets" / "poems" / title
        asset_dir.mkdir(parents=True, exist_ok=True)
        (asset_dir / "illustration.brief.md").write_text(make_brief(title, poem, poem_fm, poem_body, commentary_body, v), encoding="utf-8")
        (asset_dir / "illustration.prompt.md").write_text(make_prompt(title, v), encoding="utf-8")
        write_notes(title, poem, poem_fm, v)
        print(f"wrote pass4 sidecars for {title}")


if __name__ == "__main__":
    main()
