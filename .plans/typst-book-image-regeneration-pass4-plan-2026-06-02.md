# Typst Poem Book Image Regeneration Plan - Pass 4

Repo:

```text
/Users/utensil/projects/poems
```

Branch:

```text
typst
```

Related plan:

```text
.plans/typst-book-image-prompt-pass3-plan-2026-06-02.md
```

Related skill update:

```text
/Users/utensil/projects/skills-land/ours/illustrated-poem-page/SKILL.md
1ce2782 docs: strengthen poem image visual story contract [AGENT: codex]
```

Pass 4 is a correction pass for the pass3 image-generation results. Pass3 created a brief/prompt workflow, but the workflow still allowed the brief to abstract away concrete poem/commentary anchors. Pass4 must regenerate the pass3 in-scope images using a stricter visual story contract and must not mark complete until checks would catch the issues found by visual review.

Pass4 must use the updated illustrated-poem-page skill, especially the "Visual Story Contract" and "Failure Patterns To Avoid" sections. The skill is the source of process truth for prompt regeneration.

## Root Cause

Pass3 validated field presence, not fidelity.

The briefs often contained the right headings but made invalid substitutions:

- concrete couple scenes became still-life tokens;
- remembered girl and missing-her emotion became paper/shadow traces;
- flower-market crowd became mountain monk scenery;
- rocky coastal crossing became urban passage/tunnel;
- landslide roadblock became a vague mountain-road mood;
- pregnancy became generic domestic warmth;
- title words became generic illustrations without the poem's major concepts.

The missing gate is a visual story contract that treats certain poem/commentary anchors as non-optional.

## Scope

Regenerate the pass3 in-scope images that were reviewed after pass3:

```text
返初
流迁
沉沦
心印
心意
喜临
孤僧
自然
启步
哧溜
穿越
途遇
```

Status from user review:

```text
返初: ok; may preserve if current image still passes pass4 checks.
流迁: acceptable, but foreground luggage needs justification or removal.
沉沦: failed; lost specific imagery/concepts, only upset person remains.
心印: failed; missing girl/travel/missing-her emotion.
心意: failed; missing couple and pose from commentary.
喜临: failed; no clear pregnancy relation and worse than previous.
孤僧: failed; monk appears, but flower-market crowd/environment and contrast are missing.
自然: acceptable, but too title-level and misses major poem concepts.
启步: acceptable, but not clearly night running; overall too bright.
哧溜: acceptable elements, but unnatural composition; person should be knee-deep in water, not on land.
穿越: failed; should be rugged mountain road and rocky seaside/coastal crossing with helpers, not city tunnel.
途遇: acceptable vibe, but roadblock, queue, clearing machinery, guarding/order are insufficient.
```

Original seven sample images remain outside regeneration scope unless explicitly rejected:

```text
夜会
疹热
十月
岩浆
泛舟
湖畔
月谷
```

## Required Artifact Update

For every pass4-scope poem, update or create:

```text
assets/poems/{title}/illustration.brief.md
assets/poems/{title}/illustration.prompt.md
assets/poems/{title}/illustration.notes.md
assets/poems/{title}/illustration.png
```

The brief must include the pass4 visual story contract:

```text
must_show:
must_not_show:
setting_contract:
figure_contract:
action_contract:
object_contract:
emotion_contract:
commentary_contract:
source_photo_contract:
composition_contract:
coverage_check:
```

`coverage_check` must map every item in `must_show` to an explicit location in the final prompt: foreground, middle ground, background, human figure, action, object, light, or camera perspective.

If a poem cannot satisfy the contract after reading poem/commentary/source photos, do not generate yet. Mark it blocked for visual design rather than generating a weak image.

## Prompt Regeneration Rule

Regenerate the brief and prompt from primary sources first:

1. Read the poem Markdown.
2. Read the commentary Markdown.
3. Read context/frontmatter, including source image paths.
4. Inspect source images when present.
5. Write a fresh `illustration.brief.md` using the updated skill's visual story contract.
6. Write a fresh `illustration.prompt.md` from that brief.

Do not read or reuse the old pass3 `illustration.brief.md` or `illustration.prompt.md` before writing the new pass4 brief and prompt. Old pass3 prompts are contaminated artifacts; they caused the failures and must not anchor the new visual design.

After the fresh pass4 brief and prompt are written, then compare against the old pass3 brief/prompt only as a regression audit:

- identify what concrete anchors pass3 dropped;
- ensure pass4 restored them;
- record the difference in `illustration.notes.md`.

The image itself may be viewed before regeneration only to understand user feedback, not as a source of visual design to preserve unless the poem-specific review says the image is acceptable.

## Poem-Specific Checks

These checks are the minimum acceptance gates. They should be encoded in audit data or a script-readable manifest, not left only as prose.

### 返初

Current image is acceptable. Pass4 may preserve it if:

- brief and prompt satisfy the visual story contract;
- image still matches the contract after visual review;
- notes record `pass4-decision: preserved-after-check`.

### 流迁

Question to resolve:

- Why is there luggage in the most foreground?

Pass4 requirement:

- Either justify the luggage from poem/context/commentary as a visual mapping of `交接牵缠`, `沉浮兜转`, `揉捏`, `泡影`, or `流迁`, and keep it visually subordinate;
- or remove/demote it and choose a stronger concrete image for transition, external handling, and shifting narratives.

Check:

- Fail if an unsupported foreground prop dominates the image.
- Fail if the prompt does not explain how any added foreground object relates to the poem theme.

### 沉沦

Failure:

- Current image shows a generically upset person and loses the poem's specific 意象/concepts.

Pass4 requirement:

- Re-read poem and commentary.
- Extract the poem's concrete sinking/trapping/pressure images and conceptual turn.
- The visual scene must show more than mood; it must include the poem's specific mechanism of沉沦.

Check:

- Fail if the only visible story is "sad/upset person".
- Fail if `must_show` lacks at least two poem-specific concrete anchors and one commentary-derived concept.

### 心印

Failure:

- Current image uses paper/shadows and misses the girl, travel/parting context, and missing-her emotion.

Pass4 requirement:

- Include the remembered girl as a non-identifying figure or memory figure.
- Show the emotional line from seen beauty to separation to missing her.
- Do not replace the person with a still-life symbol.

Check:

- Fail if `figure_contract` does not include the girl / beloved figure.
- Fail if `emotion_contract` does not include missing/longing after separation.
- Fail if final prompt centers paper, seal, shadow, or desk still-life instead of the remembered person.

### 心意

Failure:

- Current image misses the couple and their pose.

Pass4 requirement:

- Read the commentary closely, especially the interpretation of `身后臂膀环`.
- Show a couple in the flower-market context.
- Male figure cuddles/embraces from behind; female figure is in front and held within the arm ring.
- Also preserve the deeper contrast: her longing for settled sweetness / home, his longing for wandering together.

Check:

- Fail if there is no couple.
- Fail if `action_contract` does not include the behind embrace.
- Fail if the scene becomes still life, gift, token, or generic romance without the pose.

### 喜临

Failure:

- Current image has no clear relation to pregnancy and is worse than the previous version.

Pass4 requirement:

- Re-read poem/context/commentary/source photo if present.
- Pregnancy must be visible through tasteful, non-medical, non-private cues: expectant mother posture, hand on belly, family/domestic anticipation, baby-related object, or medical-check context only if source supports it.

Check:

- Fail if a viewer cannot infer pregnancy from the scene without title/commentary.
- Fail if the image uses generic domestic joy without pregnancy-specific cues.

### 孤僧

Failure:

- Monk appears, but the setting is mountains, missing the 春节花市 and the commentary's contrast.

Pass4 requirement:

- Set the scene in a Spring Festival flower market.
- Include flower stalls, lights, crowd flow / 人如潮, festive red-world warmth.
- The monk-like solitude is an internal stance or speaker metaphor within the crowd, not literal mountain seclusion.

Check:

- Fail if the setting is mountain/temple/wilderness.
- Fail if there is no visible flower market or crowd.
- Fail if `commentary_contract` does not state "inner detachment amid bustling flower market."

### 自然

Current image is acceptable but too title-level.

Pass4 requirement:

- Capture the poem's major concepts, not just generic nature:
  - not chasing dust/worldly accomplishment;
  - no thirst/craving for doctrine;
  - new dreams arising;
  - truth/reality opening in the heart.
- Use concrete visual metaphor, but preserve the philosophical structure.

Check:

- Fail if the prompt only describes plants/landscape because of the title.
- Fail if `commentary_contract` lacks the poem's inner opening / non-seeking concept.

### 启步

Current image is acceptable but too bright and only weakly indicates night running.

Pass4 requirement:

- The scene must clearly be night running or evening/night jogging.
- Road lamps, dark sky, cool night air, and runner movement must be legible.
- Keep the runner ordinary and slightly heavy-bodied but dignified.

Check:

- Fail if the overall scene reads as daytime.
- Fail if there is no visible runner movement.
- Fail if the runner is heroic/athletic rather than ordinary steady effort.

### 哧溜

Current image has major elements but lacks a coherent story; figure is on land rather than knee-deep in water.

Pass4 requirement:

- Reconstruct one coherent scene, not a collage of elements.
- Person must be in water up to the knee if that is the poem/commentary anchor.
- Environment, posture, and action must explain why the moment is comic/ordinary/lively.

Check:

- Fail if the figure is on land.
- Fail if water depth is not knee-level.
- Fail if elements feel spatially disconnected.

### 穿越

Failure:

- Current image depicts an urban tunnel/passage, missing 东西涌穿越, 崎岖山路, 乱石滩 by the sea, and helpers/手足.

Pass4 requirement:

- Setting is wild coastal crossing / mountain road plus rocky seaside terrain.
- Include rugged up/down mountain path and/or broad rocky beach/乱石滩.
- Include one or two companions helping the speaker traverse unstable rocks, reflecting `手足相抵`.
- No city tunnel, no urban corridor.

Check:

- Fail if setting is urban.
- Fail if there is no rugged mountain/coastal rock terrain.
- Fail if there are no helping figures or hand/foot cooperation.

### 途遇

Current vibe acceptable, but the concrete roadblock/rescue story is under-specified.

Pass4 requirement:

- Fallen boulder/rocks visibly block the road.
- Vehicles and/or people are queued up.
- Clearing machinery is working or clearly staged for clearing.
- People are guarding/orderly managing the path.
- Maintain the tone: dangerous but orderly, not disaster spectacle.

Check:

- Fail if stones do not actually block the road.
- Fail if there is no queue.
- Fail if there is no machinery/clearing action.
- Fail if there is no guard/order/rescue-management cue.

## Audit Requirements

Update `just audit` or a dedicated image audit to fail on these classes of issues:

- generated/reviewed pass4 images without visual story contract fields;
- pass4 briefs/prompts derived by editing old pass3 text instead of being regenerated from poem/commentary/source images first;
- empty or generic `must_show`;
- `coverage_check` missing any `must_show` item;
- unsupported dominant foreground props;
- prompt contradicts poem/commentary setting;
- prompt replaces people with still life when figures are required;
- prompt replaces concrete place with generic symbolic place;
- prompt lacks source-photo observations when source images exist;
- notes missing pass4 decision/status.

For poem-specific checks, use a manifest, for example:

```text
scripts/image_contracts.yaml
```

Each entry should contain required keywords/anchors for the brief and final prompt, forbidden settings/props, and image-review checklist text. The audit can check text-side compliance; visual review must confirm image-side compliance.

## Visual Review Requirements

After regeneration, produce a contact sheet or page preview for all twelve pass4-scope images.

Review each image against:

1. poem/context;
2. commentary;
3. visual story contract;
4. final prompt;
5. rendered book page balance.

Do not approve an image only because it has the right color/style. The visible story must match the poem.

## Verification Commands

Run:

```text
just validate
just audit
just build
```

If image/contact-sheet tooling exists, also run it for the twelve pass4 images and open the result in Chrome.

## Completion Criteria

Do not mark pass4 complete unless:

- all twelve pass4-scope images have updated briefs/prompts/notes with visual story contracts;
- every `must_show` item is mapped in `coverage_check`;
- poem-specific checks above pass;
- regenerated images visually satisfy the contracts;
- `返初` is either preserved after pass4 check or regenerated with explanation;
- `流迁` resolves the foreground luggage issue by justification or removal;
- `just validate`, `just audit`, and `just build` pass;
- previews/contact sheet are opened in Chrome;
- the final state is committed and pushed to `origin/typst`.

## Directive For The Next Goal

Work in `/Users/utensil/projects/poems` on branch `typst`. Implement pass4 according to `.plans/typst-book-image-regeneration-pass4-plan-2026-06-02.md`, using the updated illustrated-poem-page skill. Regenerate or re-approve only the twelve pass3 in-scope images: `返初`, `流迁`, `沉沦`, `心印`, `心意`, `喜临`, `孤僧`, `自然`, `启步`, `哧溜`, `穿越`, `途遇`.

The goal must pass checks that would catch the reported failures: missing girl/missing emotion in `心印`, missing behind-embrace couple in `心意`, missing pregnancy in `喜临`, mountain instead of 花市 in `孤僧`, title-only nature in `自然`, over-bright non-night `启步`, land figure instead of knee-deep water in `哧溜`, urban tunnel instead of rugged coastal/mountain crossing in `穿越`, weak roadblock/queue/machinery/guarding in `途遇`, generic upset-person `沉沦`, and unsupported foreground luggage in `流迁`.

Report to Discord and push to origin after every phase completes. Ack the task after reading the file.
