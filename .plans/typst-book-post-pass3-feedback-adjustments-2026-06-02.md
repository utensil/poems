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

Future feedback should be appended here with:

- user quote;
- required behavior;
- implementation status;
- commits;
- validation/build/audit results;
- visual spot-check pages or contact sheet;
- iCloud PDF delivery status when the PDF changes.
