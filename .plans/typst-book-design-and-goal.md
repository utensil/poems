# Typst Illustrated Poem Book Design And Goal

This is the handoff/design brief for developing the next version of `github.com/utensil/poems` as a Typst-based illustrated poem collection.

## Objective

Develop a `typst` branch of `/Users/utensil/projects/poems` that turns the poem collection, human-reviewed commentaries, generated illustrations, image prompts, and appendices into a version-controlled Typst book.

The book should preserve Markdown as the authoring/source format for poems, commentaries, 凡例, 序, 代后记, LLM-writing notes, and 年谱 data, while using Typst for final page layout and PDF rendering.

## Source Repositories

- Publication repo: `/Users/utensil/projects/poems`
- Remote: `https://github.com/utensil/poems`
- Implementation branch: `typst`, created from `origin/master`
- Existing canonical order source: `/Users/utensil/projects/poems/main.tex`
- Current richer Markdown source corpus: `/Users/utensil/projects/cog-land/blogs/poems`
- Current commentary corpus: `/Users/utensil/projects/cog-land/blogs/poems/commentaries`
- Existing illustrated-page skill/template: `/Users/utensil/projects/skills-land/ours/illustrated-poem-page`
- Previous local artifact handoff: `/Users/utensil/projects/cog-land/.illustrated-poem-page/HANDOFF.md`

At design time, `cog-land/books/` has no usable implementation beyond its declared convention: Markdown -> Quarto -> Typst -> PDF. For this project, prefer direct Markdown/YAML -> generated Typst -> PDF, because the page design needs exact pinyin grids, image fitting, and commentary pagination.

## Current Corpus Shape

Canonical section order from `utensil/poems/main.tex`:

1. 职业生涯
2. 压力阴郁
3. 情感与家庭
4. 哲思禅意
5. 心情与事件
6. 云南丽江香格里拉之旅

Canonical poem counts:

- 职业生涯: 23
- 压力阴郁: 16
- 情感与家庭: 6
- 哲思禅意: 4
- 心情与事件: 18
- 云南丽江香格里拉之旅: 10
- Total: 77 poems

The `main.tex` order is canonical for chapter ordering. Do not infer order from filenames or Markdown directory traversal.

## Recommended Repository Layout

```text
poems/
  README.md
  justfile
  typst.toml
  book.typ
  src/
    book.yaml
    fanli.md
    preface.md
    postscript.md
    llm-commentary-note.md
    chronology.yaml
    poems/
      <section>/<slug>.md
    commentaries/
      <section>/<slug>.md
  assets/
    poems/<slug>/
      illustration.png
      illustration.prompt.md
      illustration.notes.md
  templates/
    illustrated-poem-page.typ
    book.typ
  scripts/
    sync-from-cog-land.py
    build-manifest.py
    generate-typst.py
    validate.py
  build/
    generated/
      book.generated.typ
      manifest.json
    pdf/
      poem-book.pdf
```

Notes:

- `src/` contains human-reviewable source.
- `assets/` is committed and contains generated illustrations, prompts, and notes.
- `build/generated/` can be regenerated; decide later whether to commit generated Typst. Prefer committing it while the pipeline stabilizes, then revisit.
- Final PDFs may be committed if desired, but this requires changing the current `.gitignore`, which ignores `*.pdf` and `main.typ`.

## Source Format

Poem Markdown should remain close to the current `cog-land/blogs/poems/*.md` schema:

```yaml
---
title: "泛舟"
original-written: "2020-09-18"
section: "云南丽江香格里拉之旅"
context: "泛舟泸沽湖所作。"
images:
  - "..."
pinyin:
  - {char: 笼, pinyin: long3, pos: 3}
---

> 泛舟泸沽湖所作。

云穹笼九岳，
湖面澈如窗。
风起银鱼跃，
桨落酒窝双。
```

Commentary Markdown should preserve current fields where possible:

```yaml
---
title: "《泛舟》赏析"
poem: "[[blogs/poems/泛舟]]"
section: "云南丽江香格里拉之旅"
commentary-status: human-revised
---
```

For the book repo, normalize paths and references to repo-local paths. Avoid hard dependencies on Obsidian wikilink resolution.

Only include commentaries that are marked as human reviewed. Treat both of these statuses as eligible:

```text
human-revised
reference-quality
```

Exclude these from the book's poem pages and from `src/commentaries/` unless the author explicitly upgrades them:

```text
ai-review-only
iterated
unclear
missing commentary-status
```

Poems without eligible commentary should still remain in the poem collection, but their illustrated page should omit the `【赏析】` section or use a clearly empty/commentary-pending state, depending on the final design choice. Do not silently include unreviewed AI commentary.

## Pinyin Policy

- Annotate every Han character in title and poem body.
- Use `auto-pinyin` for automatic pinyin lookup.
- Use the first reading by default for polyphonic characters.
- Apply poem frontmatter overrides after auto lookup.
- Frontmatter overrides are authoritative because they disambiguate rare or polyphonic characters.
- Final visual output uses tone marks, not tone numbers.
- Keep pinyin light gray and subtle.
- Use fixed character grids so pinyin and body characters share consistent widths.
- Punctuation needs special treatment: it should visually attach to the preceding character rather than being centered like a full Han character.
- Title visual centering should ignore punctuation mass where applicable.

Previously evaluated pinyin packages:

- `auto-pinyin`: chosen; returns per-character arrays and fits fixed-grid rendering.
- `auto-mando`: rejected for this use; useful ruby renderer, but owns segmentation/spacing.
- `typst-easy-pinyin`: rejected for this use; useful tone/ruby helper, but does not do automatic lookup.

## Page Layout Policy

Each poem should be rendered in the illustrated poem page style:

- Title and poem body in brush-like Chinese handwritten style.
- Context and commentary in smaller printed FangSong style.
- `【背景】` and `【赏析】` labels use same size, font, tracking, and weight.
- Eligible human-reviewed commentary is mixed with the poem page, not moved to a separate commentary appendix.
- One subtle foreground paper/container may hold the page content.
- Avoid separate visible cards for each block.
- Avoid decorative seals, waves, and unrelated ornaments.
- Full-page image tone can support atmosphere, but the illustration must not dominate the poem text.
- Visible image panel/vignette should be constrained by poem/body layout.
- For long poems or long commentaries, paginate rather than shrinking aggressively.
- If overflow is slight, a bounded small commentary font-size fallback is acceptable.
- Do not use paragraph spacing as the main overflow fix.

The existing skill template at `skills-land/ours/illustrated-poem-page/templates/poem-page.typ` is the prototype to refactor into the repo's `templates/illustrated-poem-page.typ`.

## Illustration And Asset Policy

- Generated illustrations are textless.
- Illustrations should be derived from poem/commentary content, not from generic ancient-China styling.
- If poem frontmatter has photos, use them only as reference material for palette, atmosphere, place, or composition unless explicitly choosing documentary layout.
- Every committed generated image must have a prompt sidecar:

```text
assets/poems/<slug>/illustration.prompt.md
```

- Keep rejected prompt/image notes when they contain useful negative learning:

```text
assets/poems/<slug>/illustration.notes.md
```

- Avoid generic names like `bg.png`.
- `泛舟` has a known hard prompt issue: generated images failed to depict the girl bowing backward correctly. Preserve the fallback asset and rejected notes from the existing handoff before retrying.

## Book Structure

Recommended front matter:

1. Cover/title page
2. 序, optional, human-authored
3. 凡例
4. Table of contents

Main body:

- One chapter per topic/section, following `main.tex`.
- Each poem appears as one or more illustrated poem pages.
- Eligible human-reviewed commentary appears on the poem's page sequence. Poems without eligible commentary remain in the collection but must not include unreviewed AI commentary.

Appendices:

1. 年谱
2. 代后记：在日常里写旧体诗的一点体会
3. LLM 辅助赏析写作说明

There should be no separate 诗词赏析 appendix, because eligible human-reviewed commentary is integrated into poem pages.

## 凡例 Requirements

The 凡例 should explain:

- The book is organized by topic chapters, with chapter order and poem order inherited from the original `冶文斋诗选`.
- Each poem page includes title, poem body, context/background, pinyin annotation, and illustration. It includes commentary only when the matching commentary is marked human reviewed.
- Pinyin annotation combines automatic lookup and human/frontmatter correction; manual correction wins.
- Context comes from poem frontmatter.
- Included commentary is LLM-assisted and author-reviewed, gated by `commentary-status: human-revised` or `commentary-status: reference-quality`; see the LLM appendix for method and caveats.
- Illustrations are generated literary interpretations based on the poem and commentary. They are not documentary evidence or exact reconstruction.
- Some poems lack precise chronology and may be omitted from 年谱.

## 年谱 Appendix

Add a new appendix: `年谱`.

Purpose:

- Provide a coarse chronological list of poems by year and quarter/season.
- Do not expose exact dates.
- Some poems remain undated and should be skipped.
- Examples of poems to skip if undated: `夜会`, `心印`.

Required display granularity:

```text
2026年春
  《诗题一》《诗题二》《诗题三》

2026年夏
  《诗题四》
```

Chronology should be in chronological order.

Recommended source file:

```text
src/chronology.yaml
```

Suggested schema:

```yaml
entries:
  - period: "2014年夏"
    sort: "2014-Q3"
    poems: ["心旗", "屡战", "喜临", "十月"]
  - period: "2020年秋"
    sort: "2020-Q3"
    poems: ["结游", "穿云", "盘山", "观湖", "湖畔", "泛舟", "途遇", "踏雪", "月谷", "回忆"]
undated-skipped:
  - 夜会
  - 心印
```

Use `original-written` from Markdown only to derive coarse period labels. Do not render the exact date.

Season/quarter mapping can be simple and explicit:

- Q1: 春
- Q2: 夏
- Q3: 秋
- Q4: 冬

If the author later wants traditional solar-season boundaries, update this rule explicitly before generating the appendix.

## Build Pipeline

Recommended build flow:

1. Create branch `typst` from `origin/master`.
2. Copy or sync Markdown poem sources and eligible human-reviewed commentary sources from `cog-land` into `poems/src/`.
3. Build `src/book.yaml` from `main.tex` order and review it manually.
4. Normalize poem/commentary Markdown schemas and paths, while excluding unreviewed commentary statuses.
5. Copy/refactor illustrated Typst template into `templates/`.
6. Add Python scripts:
   - `sync-from-cog-land.py`: optional source sync.
   - `build-manifest.py`: parse Markdown, commentary, chronology, assets, and emit `build/generated/manifest.json`.
   - `generate-typst.py`: emit `build/generated/book.generated.typ`.
   - `validate.py`: verify source completeness, pinyin overrides, assets, prompts, chronology, commentary status gating, and page build prerequisites.
7. Compile `book.typ` with Typst.
8. Add `just` commands for validation/build/open.

Possible `justfile` commands:

```just
validate:
    python3 scripts/validate.py

generate:
    python3 scripts/build-manifest.py
    python3 scripts/generate-typst.py

build: validate generate
    typst compile book.typ build/pdf/poem-book.pdf

open: build
    open -a "Google Chrome" build/pdf/poem-book.pdf
```

## Implementation Strategy

Start with a vertical slice before doing the full 77-poem build.

Recommended pilot poems:

- `泛舟`: travel/image nuance and known rejected-image notes.
- `疹热`: two-page behavior and family/privacy tone.
- `十月`: long poem/body pagination stress test.
- `夜会`: emotional short poem, but note chronology may be skipped if undated.
- `岩浆`: pressure/dark-tone image balance and commentary overflow risk.

Pilot completion should prove:

- Markdown parsing works.
- Eligible human-reviewed commentary joins poem pages.
- Full-title/full-body pinyin works.
- Frontmatter pinyin override wins.
- Assets and prompt sidecars are versioned.
- Typst PDF compiles.
- At least one long poem/commentary paginates correctly.

## Known Risks

- The real workload is full-corpus image generation and review.
- Many commentaries are `ai-review-only`; they must be excluded until explicitly upgraded to `human-revised` or `reference-quality`.
- Full pinyin for every title/body will surface polyphonic mistakes; overrides will need audit.
- The current illustrated-page template is a strong prototype but needs refactoring for book-wide use, global page numbering, chapter starts, and appendices.
- `utensil/poems` currently ignores `*.pdf` and `main.typ`; update `.gitignore` deliberately if PDFs/generated Typst are to be committed.
- Local `poems` checkout is detached and behind remote. Create the branch from `origin/master`, not the current detached HEAD.

## Directive For `/goal`

Create branch `typst` in `/Users/utensil/projects/poems` from `origin/master` and implement the Typst illustrated poem book pipeline described in this file. Keep poem sources and eligible human-reviewed commentary sources in Markdown, commit generated illustration assets and prompt sidecars, preserve canonical chapter/poem order from `main.tex`, integrate only `human-revised` or `reference-quality` commentary into illustrated poem pages, exclude unreviewed AI commentary, and add front matter plus appendices: 凡例, optional 序 placeholder, 年谱, 代后记, and LLM 辅助赏析写作说明.

### Verifiable Completion Criteria

1. `git -C /Users/utensil/projects/poems branch --show-current` prints `typst`.
2. `src/book.yaml` exists and lists all 77 poems in the canonical `main.tex` section order.
3. `src/poems/` contains 77 poem Markdown files with title, section, context, body, and pinyin overrides where available.
4. `src/commentaries/` contains only repo-local commentary Markdown files whose `commentary-status` is `human-revised` or `reference-quality`, linked or matched to poems.
5. `src/fanli.md`, `src/postscript.md`, `src/llm-commentary-note.md`, and `src/chronology.yaml` exist.
6. `src/chronology.yaml` renders a 年谱 by year + season/quarter only, not exact dates, and explicitly skips undated poems such as `夜会` and `心印`.
7. `templates/illustrated-poem-page.typ` exists and supports full title/body pinyin, frontmatter override pinyin, image asset rendering, context, commentary, and pagination for long commentary.
8. `assets/poems/<slug>/illustration.png` and `assets/poems/<slug>/illustration.prompt.md` exist for every poem included in the compiled pilot or final book.
9. `just validate` fails if any commentary with `ai-review-only`, `iterated`, `unclear`, or missing `commentary-status` is included in `src/commentaries/` or rendered into the book.
10. `just validate` passes.
11. `just build` produces `build/pdf/poem-book.pdf`.
12. The resulting PDF opens in Google Chrome with `just open`.
13. A pilot build includes at least `泛舟`, `疹热`, `十月`, `夜会`, and `岩浆`, proving short, long, paginated, emotional, travel, and dark-tone cases before expanding to all poems.
