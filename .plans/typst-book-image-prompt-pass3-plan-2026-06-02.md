# Typst Poem Book Image Prompt Plan - Pass 3

This plan is for the image-generation remediation pass after the layout/style remediation work.

Repo:

```text
/Users/utensil/projects/poems
```

Branch:

```text
typst
```

Related prior plans:

```text
/Users/utensil/.illustrated-poem-page/typst-book-design-and-goal.md
/Users/utensil/.illustrated-poem-page/typst-book-remediation-plan-2026-06-01.md
/Users/utensil/.illustrated-poem-page/typst-book-remediation-plan-2026-06-01-pass2.md
/Users/utensil/.illustrated-poem-page/typst-book-post-pass2-feedback-adjustments-2026-06-02.md
```

This pass is about image concept quality. Do not treat a prompt sidecar as acceptable just because it has the right fields. The language model must first interpret the poem, context, commentary, and source photos, then design an explicit visual scene for the image model to execute.

## Problem

The current batch prompt generator does not follow the illustrated-poem-page skill. It often writes instructions such as:

```text
Select concrete images from the poem...
Infer from poem/commentary...
```

That is not a final image prompt. It asks the image model to do literary interpretation, which produces generic images that match the style but miss the poem's actual content, people, objects, background, and emotional pressure.

The correct division of labor is:

- Language model: interpret the poem/commentary and design the visual scene.
- Image model: execute the already-designed scene.

## Mode

Use practical mode:

1. Build the new brief/prompt pipeline.
2. Apply it first to the regeneration scope below.
3. Audit generated briefs and prompts before image generation.
4. Regenerate a reviewed sample set first.
5. Expand only after the prompt process is visibly working.

Do not require human review for every brief before the first pass, but every generated image must have an auditable brief and prompt sidecar.

## Preserve Scope

Preserve the original seven sample-scale images unless the user explicitly rejects one later:

```text
夜会
疹热
十月
岩浆
泛舟
湖畔
月谷
```

These came from the earlier individual/sample illustrated-poem-page workflow under:

```text
/Users/utensil/projects/cog-land/.illustrated-poem-page/
```

Their image files may still need metadata cleanup, prompt sidecar normalization, or source-photo notes, but the image assets themselves are not in the regeneration scope for this pass.

## Regeneration Scope

The following current book assets are marked generated, but were produced during pass1/pass2 batch/remediation work and are in scope for regeneration:

```text
启步
自然
哧溜
喜临
孤僧
心印
心意
沉沦
穿越
流迁
返初
途遇
```

Reason:

- They may have the right visual style.
- They do not reliably reflect the poem's important background, figures, objects, scene logic, or emotional vibe.
- Their prompts were not consistently designed according to the skill.

## Placeholder Scope

All remaining placeholder images are not "regeneration" cases, but they must use the same pass3 pipeline when real images are produced.

Draft/layout builds may keep placeholders. Final/release builds must fail on placeholders unless explicitly allowed by a draft mode.

## Required Artifacts

Each real generated image must have three sidecars:

```text
assets/poems/{title}/illustration.brief.md
assets/poems/{title}/illustration.prompt.md
assets/poems/{title}/illustration.notes.md
```

### `illustration.brief.md`

The brief is the interpretation and visual design document. It must be written before image generation.

Required fields:

```text
title:
source_files:
poem_context:
poem_reading:
commentary_interpretation:
source_image_paths:
source_image_observations:
palette_from_source_images:
lighting_from_source_images:
place_or_object_cues_from_source_images:
visual_thesis:
main_scene:
foreground:
middle_ground:
background:
human_figures:
camera_position:
composition:
symbolic_mapping:
page_layout_role:
avoid:
```

The brief should explain why the chosen scene represents the poem. It should not merely summarize the poem.

### `illustration.prompt.md`

The prompt is the final image-model execution prompt.

Required fields:

```text
title:
use_case:
asset_type:
primary_request:
scene_backdrop:
subjects_and_actions:
foreground:
middle_ground:
background:
camera_and_composition:
light_and_color:
style:
page_layout_constraints:
negative_constraints:
final_image_prompt:
source_generated_image:
```

The prompt must contain concrete visual decisions. It must not ask the image model to infer, choose, or interpret the poem.

### `illustration.notes.md`

The notes file records lifecycle metadata.

Required fields:

```text
image-status:
prompt-source:
brief-status:
review-status:
source-poem:
source-commentary:
source-images:
generation-tool:
generated-image-source:
regeneration-scope:
human-feedback:
```

Use `regeneration-scope: preserve-original-seven`, `regeneration-scope: pass3-regenerate`, or `regeneration-scope: placeholder-future`.

## Source Image Policy

When poem frontmatter includes images, the pass3 pipeline must inspect them and use them as inspiration for:

- color palette
- light quality
- place atmosphere
- real objects or spatial cues
- overall vibe

Do not use source photos directly as final illustration panels unless the user explicitly requests documentary/photo layout.

Do not copy private faces or exact photo composition. The source photos are references for palette, atmosphere, and scene realism.

The brief must explicitly state what was learned from the source images. A phrase such as "use source photo for inspiration" is insufficient.

Example of acceptable source-image observation:

```text
The source images show pale highland lake water, bright thin daylight, low mountain silhouettes, and a tourist boat with close seating. Use the blue-green palette and intimate boat spacing, but redesign the composition as the poet's seated POV rather than copying the photograph.
```

## Prompt Quality Rules

Fail any generated/reviewed prompt that contains unresolved instruction language:

```text
Infer from poem/commentary
Select concrete images
based on the poem
use the commentary to decide
to be determined
No commentary source available
generic literary illustration
```

Fail any generated/reviewed prompt that lacks:

- a concrete main scene
- foreground/middle-ground/background placement
- camera position
- human figure treatment when people are present
- source-photo observations when source images exist
- at least one poem-specific concrete image
- at least one commentary-derived interpretive anchor
- clear page-layout constraints so the image does not overpower the poem text

## Generation Workflow

For each poem in the pass3 regeneration scope:

1. Read the poem Markdown.
2. Read the commentary Markdown.
3. Read context, pinyin, and image frontmatter.
4. Inspect source images if present.
5. Write `illustration.brief.md`.
6. Audit the brief for concrete visual design.
7. Write `illustration.prompt.md` from the brief.
8. Audit the prompt for execution-ready specificity.
9. Generate the image.
10. Update `illustration.notes.md`.
11. Build the relevant book/contact-sheet preview.
12. Visually compare the generated image against the brief.

Do not generate from a prompt that still contains interpretation delegation.

## Skill Updates

Update the illustrated-poem-page skill so batch generation cannot regress.

Required skill changes:

- State that final image prompts are execution prompts, not interpretation prompts.
- Require a separate visual brief before image generation.
- Require source-image observations when source photos exist.
- Require foreground/middle-ground/background, camera, human figures, and symbolic mapping.
- Prohibit generic "infer/select/read the poem" language in generated/reviewed prompts.
- Preserve the original seven sample images unless explicitly rejected.

Skill path:

```text
/Users/utensil/projects/skills-land/ours/illustrated-poem-page/SKILL.md
```

## Audit Updates

Update repo validation/audit so the current failure would be caught automatically.

Required checks:

- `generated` or `reviewed` image assets require `illustration.brief.md`.
- Preserve/regenerate/placeholder scope must be recorded in notes.
- Prompts with forbidden unresolved phrases fail.
- Prompts below a meaningful content threshold fail.
- If source poem has `images:` frontmatter, the brief must include non-empty source-image observation fields.
- Preserve-scope assets must not be overwritten during pass3.
- Regeneration-scope assets must not be marked accepted until the new brief/prompt workflow has been used.

## Verification

Run:

```text
just validate
just audit
just build
```

Then visually inspect:

```text
one preserved original-seven image page
one regenerated pass3 image page with people
one regenerated pass3 image page without people
one poem page whose source has photos
one placeholder page to confirm draft labeling remains clear
```

Open previews/PDF in Chrome when visual inspection is needed.

## Completion Criteria

Do not mark pass3 complete unless:

- the skill has been updated;
- the repo has an explicit preserve/regenerate/placeholder scope policy;
- the original seven image assets are preserved;
- the twelve pass1/pass2 generated assets listed above are either regenerated or explicitly staged for regeneration with pass3 briefs/prompts;
- generated/reviewed image assets have `illustration.brief.md`, `illustration.prompt.md`, and `illustration.notes.md`;
- source images are inspected and reflected in brief fields when present;
- prompt audit fails unresolved instruction language;
- `just validate`, `just audit`, and `just build` pass;
- visual inspection confirms at least one regenerated image reflects poem/commentary content, not only general style.

## Directive For The Next Goal

Work in `/Users/utensil/projects/poems` on branch `typst`, and update the illustrated-poem-page skill in `/Users/utensil/projects/skills-land/ours/illustrated-poem-page` as needed. Implement pass3 according to `/Users/utensil/.illustrated-poem-page/typst-book-image-prompt-pass3-plan-2026-06-02.md`.

Use practical mode. Preserve the original seven sample images: `夜会`, `疹热`, `十月`, `岩浆`, `泛舟`, `湖畔`, `月谷`. Treat the pass1/pass2 generated images `启步`, `自然`, `哧溜`, `喜临`, `孤僧`, `心印`, `心意`, `沉沦`, `穿越`, `流迁`, `返初`, `途遇` as in scope for pass3 regeneration. Add explicit visual briefs before prompts, use source photos for palette/vibe/place cues, audit prompts so they cannot delegate interpretation to the image model, and verify with `just validate`, `just audit`, and `just build`.

Report to Discord and push to origin after every phase completes. Ack the task after reading the file.
