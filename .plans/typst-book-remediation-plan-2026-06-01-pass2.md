# Typst Poem Book Remediation Plan - Pass 2

This plan follows the failed remediation commit:

```text
c2661af fix: remediate typst book pipeline audit gates [AGENT: peri]
```

Repo:

```text
/Users/utensil/projects/poems
```

Branch:

```text
typst
```

Do not overwrite these earlier planning files:

```text
/Users/utensil/.illustrated-poem-page/typst-book-design-and-goal.md
/Users/utensil/.illustrated-poem-page/typst-book-remediation-plan-2026-06-01.md
```

This pass is not complete unless the produced PDF is visually checked and the automated audit would have caught the concrete failures listed below.

## Root Cause

The previous pass still treated several book roles as separate local layouts. It improved the illustrated poem page, but cover, table of contents, preface, appendix prose, chronology, chapter dividers, poem overflow, and image prompts were not bound to one enforceable design system.

The next pass must convert the system from "Typst compiles" to "every page role has a contract, and the audit checks the contract."

## Non-Negotiable User Decisions

- Book title is `冶文斋诗选`.
- Author is learned from the LaTeX source and rendered as `宋皿`.
- The book title must use the same font family/style as poem titles.
- Every chapter/topic has a divider page.
- Chapter dividers render only the title unless the source has a real note/tagline. Do not invent notes.
- Unreviewed commentary stays in the book and starts with `【人工修订未完成，仅供参考】`.
- Placeholder images are allowed during layout remediation, but must be labeled as placeholders and excluded by final/release validation.
- Existing accepted generated images do not need to be regenerated in this pass.
- New generated images must use content-rich prompts derived from poem, context, and commentary.
- 年谱 uses Jan-Mar as 春, Apr-Jun as 夏, Jul-Sep as 秋, Oct-Dec as 冬.
- 年谱 should omit unlisted/undated poems silently; do not add a paragraph saying which poems were skipped.

## Current Concrete Failures To Fix

### Global Styling

Cover, table of contents, preface, and appendices do not yet share the book's visual language.

Required fix:

- Centralize all page-role styles in `templates/book-style.typ`.
- Make cover title use the poem title font role.
- Make TOC/index, preface, appendix articles, chronology, and chapter dividers use explicit role renderers, not Typst defaults.
- Use one prose text style for 序、凡例、代后记、赏析编写说明 and other appendix prose.

Recommended role names:

```text
book-title-style
book-author-style
toc-title-style
toc-entry-style
chapter-divider-style
prose-title-style
prose-body-style
prose-quote-style
poem-title-style
poem-body-style
commentary-style
context-style
chronology-style
```

### Poem Page Spacing

The poem pages are still too vertically loose, causing overflow and a different look from the accepted sample pages.

Required global changes:

- Cut inter-poem-line distance by half for all poem pages.
- Cut title-body distance by half for all poem pages.
- Apply these as named template parameters, not per-poem hand tuning.

Acceptance:

- The change must affect `十月`, `疹热`, `自然`, `启步`, and ordinary short poems.
- The title/body spacing and poem line spacing must be traceable to one central config.

### Poem Overflow And Split Logic

Known failed pages:

```text
十月
疹热
自然
启步
```

Observed failures:

- `十月`: poem body and image consume the whole page; `【背景】` and `【赏析】` disappear.
- `疹热`: commentary overflow.
- `自然`: commentary overflow.
- `启步`: poem body itself overflows.

Required strategy:

- Preflight each poem's title/body/image block before rendering.
- If title/body/image block leaves insufficient room for context/commentary, use a deterministic split mode.
- Split after the last full commentary paragraph that fits on a page.
- If the poem body itself cannot fit, split the poem page before commentary rather than letting the poem grid overflow.
- For long poems, allow a poem-first page followed by one or more commentary continuation pages.
- Do not solve this by per-poem paragraph spacing tweaks.

Acceptance cases:

- `十月` must show poem, image, context, and commentary, even if commentary starts on a following page.
- `疹热` must not overflow commentary.
- `自然` must not overflow commentary.
- `启步` poem body must not overflow horizontally or vertically.

Audit requirements:

- Fail if any rendered poem page that has context/commentary source lacks `【背景】` or `【赏析】` in extracted PDF text.
- Fail if Typst layout assertions report overflow.
- Fail if known case pages do not trigger the expected split mode.
- Fail if a poem source line exceeds the configured grid width without a source rebreak or split policy.

### 代后记

Current failures:

- Title wraps naturally at the final character.
- Interparagraph distance is wrong.
- Markdown quote rendering is wrong.

Required fix:

- Use the real `代后记` article from `main.tex`.
- Convert LaTeX prose carefully to Markdown or a structured intermediate form.
- Preserve block quotes as quote blocks in Typst, not raw `>` text and not flattened paragraphs.
- Render with the same appendix prose style as 凡例 and the preface placeholder.
- Prevent title orphan/wrap by using a title block with enough width, smaller fallback size, or deliberate line break if needed.

Audit requirements:

- Fail if `src/postscript.md` is short placeholder text.
- Fail if extracted PDF text misses distinctive phrases from the real `代后记`.
- Fail if rendered PDF text includes raw Markdown quote markers.

### 赏析编写说明

Current failure:

- The appendix did not capture the commentary-writing notes from the beginning of:

```text
\section{附录：诗词赏析}
```

Required fix:

- Extract the prose notes at the beginning of that section before the first poem commentary subsection.
- Convert them to the same appendix prose style.
- Use a title that fits the book style and does not mention "LLM" directly.

Chosen title for this pass:

```text
赏析编写说明
```

Rationale:

- It describes the editorial method without making the appendix title sound like a tooling note.
- Any AI-assistance disclosure can live inside the prose where it belongs.

Audit requirements:

- Fail if the appendix source is missing the extracted prose before the first commentary subsection.
- Fail if the PDF/table of contents uses a title containing `LLM`.

### 年谱

Current failure:

- Subsection numbering pollutes 年谱 and the table of contents.

Required fix:

- Year/quarter labels in 年谱 are styled body blocks, not numbered/outlined headings.
- The TOC includes the 年谱 appendix title only, not every year/quarter row.
- Do not mention skipped undated poems.

Audit requirements:

- Fail if PDF outline/TOC includes 年谱 child entries for individual year/quarter labels.
- Fail if the rendered 年谱 text contains an explicit skipped/undated poem list.

### Chapter Dividers

Required fix:

- Each chapter/topic gets its own divider page.
- Title is centered vertically and horizontally.
- Long titles must wrap intentionally, especially:

```text
云南丽江香格里拉之旅
```

- If no source tagline exists, render only the title.
- If a real source tagline exists, render it smaller/lighter and spaced from the title.

Audit requirements:

- Fail if any configured chapter does not have a divider page.
- Fail if a divider contains generated/invented note text.

### Image Prompt Quality

Current failure:

- New generated images use short, thin prompts.
- They capture generic style but miss poem/commentary content and key human scene details.

Required fix:

- Treat prompt writing as part of the illustrated-poem-page skill, not a generic image placeholder.
- Each real image prompt sidecar must be content-rich and auditable.
- A generated image prompt must be based on the poem, context, commentary, and any user-provided scene corrections.

Minimum prompt sidecar structure:

```text
title:
source_poem_summary:
commentary_reading:
key_imagery:
human_subjects:
camera_and_composition:
emotional_tone:
color_palette:
style:
negative_constraints:
```

Prompt quality requirements:

- No two-line generic prompts.
- Include concrete visual anchors from the poem.
- Include commentary-derived interpretation where it changes the scene.
- For poems involving people, specify identity/role, posture, gaze, relation to the speaker, and camera point of view.
- Preserve the accepted visual style: quiet Chinese-literary illustration, usable behind or beside text, not visually louder than the poem.

Audit requirements:

- Fail real generated images whose prompt sidecar lacks the required fields.
- Fail prompts under a minimum meaningful length, except explicit placeholder prompts.
- Fail prompts that do not mention at least one poem-specific image or commentary-specific interpretive anchor.

## Verification Workflow

The next goal must not report completion until all of these pass:

```text
just validate
just audit
just build
```

Then perform a visual spot-check in Chrome for:

```text
cover
toc/index
chapter divider for 云南丽江香格里拉之旅
序 or preface placeholder
凡例
十月
疹热
自然
启步
代后记
赏析编写说明
年谱
one generated-image poem
one placeholder-image poem
```

The audit must include machine-readable checks for:

- cover includes `冶文斋诗选` and `宋皿`
- cover title uses the poem-title font role in Typst source
- TOC/index does not include 年谱 year/quarter children
- TOC/index does not include `LLM`
- no raw LaTeX commands remain in Markdown poem/commentary source
- no raw Markdown quote markers appear in rendered appendix text
- no known overflow pages are missing `【背景】` or `【赏析】`
- known pages `十月`, `疹热`, `自然`, `启步` pass layout assertions
- generated image prompt sidecars meet the required structure
- placeholder images are allowed only in draft/layout mode

## Implementation Guidance

Do the work in this order:

1. Normalize the style system first.
2. Fix source extraction for `代后记` and `赏析编写说明`.
3. Fix poem spacing globally.
4. Implement robust split/preflight for poem pages.
5. Add audit checks that fail on the current known bad cases.
6. Rebuild and visually inspect before touching image generation.
7. Upgrade prompt sidecar generation and regenerate only the selected new sample images if needed.

Avoid hand-adjusting individual poems unless the source text itself is wrong, such as raw LaTeX font tags or an intentionally rebreakable long source line.

## Directive For The Next Goal

Work in `/Users/utensil/projects/poems` on branch `typst`. Remediate the Typst poem book according to `/Users/utensil/.illustrated-poem-page/typst-book-remediation-plan-2026-06-01-pass2.md`.

Do not mark the goal complete until:

- the global style roles cover poem pages, cover, TOC, preface, appendices, chronology, and chapter dividers;
- poem line gap and title-body gap are halved through central template parameters;
- `十月`, `疹热`, `自然`, and `启步` render without overflow or missing context/commentary;
- real `代后记` and `赏析编写说明` are extracted and rendered with correct prose/quote styling;
- 年谱 has no noisy subsection numbering or explicit skipped-poem list;
- generated image prompt sidecars are content-rich and structured;
- `just validate`, `just audit`, and `just build` pass;
- the rebuilt PDF is opened in Chrome and the listed spot-check pages are visually reviewed.
