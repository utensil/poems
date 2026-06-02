# Typst Poem Book Post-Pass3 Feedback Adjustments - 2026-06-02

This file logs user feedback and adjustment requirements after:

```text
.plans/typst-book-image-prompt-pass3-plan-2026-06-02.md
```

Repo:

```text
/Users/utensil/projects/poems
```

Branch:

```text
typst
```

## Context

Pass3 focused on the illustrated poem image pipeline:

- explicit visual briefs before prompts;
- concrete image-model execution prompts;
- prompt/brief/notes audit gates;
- regeneration of the pass1/pass2 generated image scope;
- preservation of the original seven sample images.

Feedback after pass3 may still involve layout, prose styling, PDF delivery, prompt quality, image quality, or validation gates. This log records those follow-up items so they are not buried in Discord history or confused with the original pass3 scope.

## Feedback Items

### 1. Role Frames, Rule Spacing, Continuation Pages, And Paragraph Indent

User feedback:

```text
for typst-book-post-pass2-feedback-adjustments-2026-06-02.md

> frame margin / top gap / bottom text guard tuning
> cover/chapter divider frame margins
1. preface, fanli, index still have inconsistent frame margin with the rest (incl. cover, poem pages)
2. bottom text guard seems working

> body-context gap and context/commentary rule spacing

3. body-context gap seems ok
4. context/commentary rule spacing needs double again

> title-rule and TOC spacing
5. title-rule space need to be half the current

6. only the first page of e.g. appendix has framed design, the next pages lost it, most obvious is 代后记, all such non-poem pages would need to take care of this

7. for each chinese paragraps in commentary, or other non-poem pages, should indent 2 chinese chars, choose the typst tech to implement this wisely
```

Required behavior:

- Preface, 凡例, TOC/index, 年谱, appendix/prose pages, cover, chapter divider pages, and poem pages must use visually consistent frame margins.
- Bottom text guard behavior should remain.
- Current body-context gap should remain.
- Context/commentary rule spacing should be doubled from the previous value.
- Title-to-rule spacing should be halved from the previous value.
- Non-poem pages must keep the framed page design on continuation pages, not only on the first page.
- Chinese commentary and non-poem prose paragraphs must use a two-Chinese-character first-line indent.

Implementation:

- `templates/book-style.typ`
  - `title-rule-gap` changed from `5pt` to `2.5pt`.
  - `cover-title-rule-gap` changed from `6.7pt` to `3.35pt`.
  - `prose-page`, `toc-page`, and `chronology-page` now use `role-ground(panel-margin: poem-role-panel-margin, frame-margin: poem-role-frame-margin)` as a page background.
  - Prose paragraphs render with deterministic `#h(2em)` paragraph-start indent.
- `templates/illustrated-poem-page.typ`
  - `context-commentary-rule-gap` changed from `7pt` to `14pt`.
  - Commentary paragraphs render with deterministic `#h(2em)` paragraph-start indent.
  - Commentary continuation marker remains unindented.
- `scripts/audit.py`
  - Audits the new frame/background, spacing, and indent contracts.

Verification:

```text
just validate
just audit
just build
```

Additional visual verification:

```text
build/spotcheck/section9/contact-sheet.png
```

Spot-check coverage:

- 序
- 凡例
- 目录
- 年谱
- 代后记 first page
- 代后记 continuation pages
- 赏析编写说明
- 启步 poem/background/commentary page
- commentary continuation pages

Implemented in:

```text
e52ea9f fix: resolve post-pass2 layout feedback [AGENT: peri]
4359ea6 docs: mark post-pass2 layout feedback implemented [AGENT: peri]
```

PDF delivery:

```text
~/Library/Mobile Documents/com~apple~CloudDocs/Downloads/冶文斋诗选-typst-pass2.pdf
~/Library/Mobile Documents/com~apple~CloudDocs/Downloads/poem-book-typst-pass2.pdf
~/Library/Mobile Documents/com~apple~CloudDocs/Downloads/poem-book-post-pass2-section9-20260602-164334.pdf
```

CloudDocs upload queue was reported clear.

## Open Items

### 2. Title Rule Gap And Commentary Marker Alignment

User feedback:

```text
the text to hr distance is still too large, is there anything else in between?

the 2 chinese char indent looks ok, what tech did you use?

but the 【赏析】 line is not a normal paragram but a special marker, so it needs to have no indent, aligned with 【背景】, and to the left. The commentary could consistently begin in next line, with a real 2-char indented paragraph. the 【人工修订未完成，仅供参考】marker stays in the same line of 【赏析】
```

Source:

```text
https://discord.com/channels/1089537860106993716/1510954118691291206/1511291198755835974
```

Status:

- Implemented.

Required behavior:

- Title-to-horizontal-rule spacing needs another reduction from the current post-section-9 value.
- Keep two-Chinese-character indentation for normal commentary/prose paragraphs.
- `【赏析】` is a structural marker, not a normal commentary paragraph.
- `【赏析】` must be unindented and left-aligned with `【背景】`.
- The commentary body must begin on the next line as a real two-Chinese-character-indented paragraph.
- For unrevised commentary, `【人工修订未完成，仅供参考】` stays on the same line as `【赏析】`.
- The indent implementation used for the previous pass was Typst content-level `#h(2em)` at paragraph starts, because `set par(first-line-indent: 2em)` did not visibly apply inside the placed/boxed commentary flow.

Implementation notes:

- `templates/book-style.typ`
  - `title-rule-gap` changed from `2.5pt` to `1.25pt`.
  - `cover-title-rule-gap` changed from `3.35pt` to `1.7pt`.
- `templates/illustrated-poem-page.typ`
  - Added `review-marker` / `marker-inline` / `body-start` handling.
  - Renders `【赏析】` as a structural marker line with no paragraph indent.
  - Keeps `【人工修订未完成，仅供参考】` inline with `【赏析】` when present as the first commentary paragraph.
  - Starts actual commentary body on the next line with `#h(2em)` paragraph-start indent.
  - Adjusted commentary split measurement so marker-only handling does not drop the first body paragraph.
- `scripts/audit.py`
  - Audits the tighter title-rule gaps and marker/body split contract.

Verification:

```text
just validate
just audit
just build
```

Additional visual verification:

```text
build/spotcheck/commentary-marker/contact-sheet.png
```

Spot-check coverage:

- 序 title/rule spacing
- 凡例 title/rule spacing
- 目录 title/rule spacing
- 喜临 human-revised `【赏析】` marker/body split
- 启步 AI-review marker inline with `【赏析】`
- 途遇 continuation/commentary page

### 3. Title Rule Gap Root Cause

User feedback:

```text
title to hr gap still large

must be something else

investigate
```

Status:

- Implemented.

Investigation:

- Reducing `title-rule-gap` alone did not visually reduce the title-to-rule gap enough.
- Rendered pixel scans of pages 2, 3, and 4 showed the rule still landing roughly 28-30pt below the title glyph even when `title-rule-gap = 1.25pt`.
- Root cause: the old heading stack used separate block-level constructs:

```typst
#align(center)[title]
#v(title-rule-gap)
#align(center)[line]
```

- Typst's block/line layout around those separate `align` blocks added implicit vertical extent beyond the explicit `title-rule-gap`.

Required behavior:

- The horizontal rule must be positioned from the measured title box, not from adjacent block flow.
- Future changes must not restore the old separate title / `v(...)` / line stack for role-page headings.

Implementation:

- Added `measured-title-rule(...)` in `templates/book-style.typ`.
- The helper measures the title content and places the rule at:

```typst
title-size.height + gap
```

- Applied the helper to cover, prose pages, TOC, and 年谱 headings.
- Added audit checks for the measured helper.

Verification:

```text
just validate
just audit
just build
```

Pixel/render investigation:

```text
build/spotcheck/title-gap-investigation-after/contact-sheet.png
```

Result:

- The title/rule hidden block gap is removed.
- The rule is now placed directly from the measured title content.
- PDF text bounding boxes show the first body text on 凡例 moved from y=133.9pt to y=103.2pt after removing the implicit block spacing.

### 4. Title Rule Overlap And TOC Entry Rule Gap

User feedback:

```text
now hr is overlapping with title text  so we need to increase it to at least 1em or pt equivalent

but index page chapter title to hr still have big gap

is it still using the old layout? fix it too
```

Status:

- Implemented.

Required behavior:

- After removing implicit block spacing, the main title-to-rule gap must not overlap title glyphs.
- The title-to-rule gap should be at least a normal 1em-like point value.
- TOC/index entry titles must not use the old separate `entry` / `v(...)` / `line(...)` stack.
- TOC/index entry underlines should use the same measured-title-rule approach, with a smaller entry-specific gap.

Implementation:

- `title-rule-gap` changed to `12pt`.
- `cover-title-rule-gap` changed to `12pt`.
- Added `toc-entry-rule-gap = 6pt`.
- TOC/index entries now call `measured-title-rule(toc-entry-style(entry), line-length: 100%, gap: toc-entry-rule-gap, thickness: 0.35pt)`.
- Audit checks now require the measured TOC entry rule path.

Verification:

```text
just validate
just audit
just build
```

Visual verification:

```text
build/spotcheck/title-rule-1em/contact-sheet.png
```

Result:

- Main role-page title rules no longer overlap title text.
- TOC/index entry rules use the measured helper and no longer show the old large block-flow gap.

### 5. Double Measured Rule Gaps And Widen Cover Rule

User feedback:

```text
ok the layout mechanism is fixed

now we have to doublw the gap

also widen hr for book title to cover the title length and more
```

Status:

- Implemented.

Required behavior:

- Keep the measured title/rule layout mechanism.
- Double the current measured gaps.
- Widen the cover/book-title horizontal rule so it spans the book-title length and extra visual breathing room.

Implementation:

- `title-rule-gap` changed from `12pt` to `24pt`.
- `cover-title-rule-gap` changed from `12pt` to `24pt`.
- `toc-entry-rule-gap` changed from `6pt` to `12pt`.
- Cover title rule length changed from `38mm` to `82mm`.
- Audit checks updated for the doubled gaps and wider cover rule.

Verification:

```text
just validate
just audit
just build
```

Visual verification:

```text
build/spotcheck/double-rule-gap/contact-sheet.png
```

Result:

- Role-page title-to-rule gaps use the doubled measured value.
- TOC/index entry-to-rule gaps use the doubled measured entry value.
- Cover title rule spans wider than the book title.

### 6. TOC Two-Line Entry Measurement

User feedback:

```text
you new layout fail to accomodate for 2-line tiles such as the 代后记 in index page
```

Status:

- Implemented.

Root cause:

- The TOC entry renderer used the generic `measured-title-rule(toc-entry-style(entry), line-length: 100%, ...)`.
- That measured the raw entry content outside the actual fixed-width TOC entry block.
- Long entries such as `代后记：在日常里写旧体诗的一点体会` wrap to two lines inside the `54mm` TOC column, but the rule was positioned using a one-line measurement.

Required behavior:

- TOC/index entries must be measured in the same fixed width where they render.
- Two-line entries must reserve enough height before their underline.
- The following TOC row must not collide with or visually crowd a two-line entry.

Implementation:

- Added `toc-entry-rule(entry, width: 54mm)`.
- It wraps `toc-entry-style(entry)` in `block(width: width)` before measuring.
- The underline is placed at `entry-size.height + toc-entry-rule-gap`.
- TOC entries now call `#toc-entry-rule(entry)`.
- Audit checks require the width-aware TOC entry helper.

Verification:

```text
just validate
just audit
just build
```

Visual verification:

```text
build/spotcheck/toc-two-line/page-4-lower-crop.png
build/spotcheck/toc-two-line/page-4-toc-crop.png
```

Result:

- The `代后记：在日常里写旧体诗的一点体会` TOC entry reserves height for two lines.
- Its underline is placed below the second line, not from a one-line measurement.
- The following row no longer collides with the two-line entry.

### 7. Prose Quote Offset After Paragraph Indent

User feedback:

```text
after we indent every paragraph in 代后记 with 2 chinese chars, the markdown quote render would look too left (left aligned), best if we could move the quote 2 chinese char right altogether incl. the left border to make it as quote, any ideas how to implement this in typst?
```

Follow-up:

```text
good, implement it
```

Status:

- Implemented.

Required behavior:

- Normal prose paragraphs keep a two-Chinese-character paragraph start.
- Quote blocks in non-poem prose should shift right by the same two-character amount as a block-level quote.
- The quote left border must shift together with the quote text.
- Quote internal first-line indent remains `0pt`.
- The shifted quote block must reduce its width so it does not overflow the right edge.

Implementation:

- Added `prose-indent = 2em`.
- Added `prose-quote-offset = prose-indent`.
- Replaced hardcoded prose paragraph `#h(2em)` with `#h(prose-indent)`.
- Initial attempt using `#h(prose-quote-offset)` before a block had no visible effect because the horizontal space did not shift the following block-level quote.
- Wrapped quote rendering with `#pad(left: prose-quote-offset)` and an inner block:

```typst
width: 100% - prose-quote-offset
```

- The quote border and quote text now move right together.
- Audit checks the prose indent and quote offset contracts.

Verification:

```text
just validate
just audit
just build
```

Visual verification:

```text
build/spotcheck/prose-quote-offset/contact-sheet.png
build/spotcheck/prose-quote-offset/page-98-lower.png
build/spotcheck/prose-quote-offset/page-100-top.png
```

Result:

- Quote block left border moves right with the quote text.
- Normal prose paragraph starts retain the two-Chinese-character indent.
- Quote internal first-line indent remains unindented.

Follow-up correction:

- User reported no visible effect in the latest PDF.
- `pdftotext -bbox` confirmed the quote text still began at about `99.2pt`, so `#h(prose-quote-offset)` before a block did not shift the block-level quote.
- Replaced the ineffective inline horizontal space with:

```typst
#pad(left: prose-quote-offset)[...]
```

- After rebuilding, quote text xMin on the checked page moved from about `99.2pt` to `122.4pt`, confirming the quote block now visibly shifts right.

Future feedback should be appended here with:

- user quote;
- required behavior;
- implementation status;
- commits;
- validation/build/audit results;
- visual spot-check pages or contact sheet;
- iCloud PDF delivery status when the PDF changes.
