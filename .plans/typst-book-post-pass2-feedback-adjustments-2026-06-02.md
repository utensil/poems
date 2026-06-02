# Typst Poem Book Post-Pass2 Feedback Adjustments - 2026-06-02

This file logs additional user feedback and adjustment requirements after:

```text
/Users/utensil/.illustrated-poem-page/typst-book-remediation-plan-2026-06-01-pass2.md
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

Pass2 was treated as incomplete until visual feedback identified issues that the automated gates either missed or did not encode strongly enough. These adjustments should be considered part of the pass2 follow-up record, not a replacement for the original pass2 plan.

## Feedback Items

### 1. Role Page Background Offset

User feedback:

```text
preface fanli and index got its background broken by offset to right and down quite a bit
```

Cause:

- `prose-page`, `toc-page`, and `chronology-page` set nonzero page margins before drawing `role-ground()`.
- The background panels were therefore placed relative to the content area, not the physical page.

Required behavior:

- Role-page backgrounds must be centered on the physical A4 page.
- Page content may use internal padding, but background drawing must not inherit page margins.

Implemented in:

```text
d38ff89 fix: center role backgrounds and regenerate pass2 samples [AGENT: peri]
```

### 2. Selected Placeholder Image Regeneration

User feedback:

```text
images still not regen
```

Clarification:

- The pass2 plan allowed existing accepted generated images to remain.
- It also allowed placeholders during layout remediation.
- User expectation after visual review was that visible spot-check placeholder samples should be regenerated, not only have prompt sidecars improved.

Required behavior:

- Regenerate selected visible placeholder samples that are part of spot-check pages.
- Update `illustration.png`, `illustration.notes.md`, and `illustration.prompt.md`.
- Preserve generated source paths in metadata.

Implemented samples:

```text
自然
启步
```

Implemented in:

```text
d38ff89 fix: center role backgrounds and regenerate pass2 samples [AGENT: peri]
```

### 3. Paragraph Spacing For Prose And Commentary

User feedback:

```text
inter paragraph needs consistent distance at least double current
for commentary and prefact fanli and appendix
```

Required behavior:

- Paragraph spacing must be controlled centrally.
- Applies to:
  - preface
  - 凡例
  - appendix prose
  - poem commentary
- Avoid per-page or per-poem spacing edits.

Implemented central values:

```text
prose-paragraph-gap = 20pt
prose-quote-gap = 18pt
commentary-paragraph-gap = 18pt
```

Implemented in:

```text
ac8cb07 fix: increase prose and commentary paragraph spacing [AGENT: peri]
```

### 4. Over-Spaced Revert

User feedback:

```text
revert to last version; maybe it's because i was seeing unsynced version, now too much
```

Action:

- Reverted the later over-large spacing change.
- Restored the prior accepted spacing values:

```text
prose-paragraph-gap = 20pt
prose-quote-gap = 18pt
commentary-paragraph-gap = 18pt
```

Implemented in:

```text
b140449 Revert "fix: double prose and commentary paragraph gaps again [AGENT: peri]"
```

### 5. iCloud Delivery Requirement

User feedback:

```text
always also copy to icloud download dir again and ensure it syncs
```

Required behavior after every PDF-affecting build/change:

1. Copy the latest PDF to:

```text
~/Library/Mobile Documents/com~apple~CloudDocs/Downloads/冶文斋诗选-typst-pass2.pdf
~/Library/Mobile Documents/com~apple~CloudDocs/Downloads/poem-book-typst-pass2.pdf
```

2. Force a visible CloudDocs metadata/timestamp update.

3. Poll `brctl status com.apple.CloudDocs` until no `needs-upload` / `upload{` entries remain.

4. Report whether the CloudDocs upload queue cleared.

### 6. Frame Margin, Top Gap, And Bottom Text Guard

User feedback:

```text
1. make top frame to poem title gap = title-body gap = 0.8x current for each page;
2. make frame margin = 0.8x current
3. ensure there is minimal normal line gap distance between text (be it body or commentary) and bottom frame;
```

Required behavior:

- Poem page frame margins and top-title spacing must be controlled centrally.
- Top frame-to-title gap and title-body gap must both be reduced to 0.8x the prior accepted values.
- Text must not visually run into the bottom frame.
- Long poems, especially `启步`, must still fit the poem body before commentary.

Implemented central values:

```text
fg-x = 8mm
fg-y = 5.6mm
fg-bottom = 6.4mm
pad-top = 8.8mm
title-body-gap-factor = 0.4
bottom-frame-text-gap = 18pt
```

Audit behavior:

- The poem template includes a Typst panic guard if the poem block reaches the bottom frame.
- `启步` long-poem compact mode was tightened so the poem body clears the bottom frame.

Implemented in:

```text
c0d69dc fix: tighten frame margins and guard bottom text gap [AGENT: peri]
```

### 7. Cover, Chapter Divider, Title Rule, TOC, And Context Rule Tuning

User feedback:

```text
1. cover and chapter divider pages should adjust frame margin like poem pages, to be consistent;
2. i don't know the exact cause, but in order to visually make title-body gap = body-context gap, we need to double body-context gap and keep the former still;
3. you have consistently used a design pattern for a horizontal line under book title, preface title, fanli title, index titles, but the text-hr gap is too much, and significantly larger than text top margin; so we need the gap to be a third of current; and for index chapter titles, we need to double the text top margin.
4. for the hr between context and commentary, we need margin above and below, equal to a normal line gap in commentary
```

Required behavior:

- Cover and chapter divider pages should use poem-like frame margins, not the wider prose/TOC role frame.
- Keep title-body gap unchanged from the prior accepted value.
- Double the body-context gap so it visually balances title-body spacing.
- Reduce title-to-horizontal-rule gaps to one third of the prior values.
- Increase TOC/index entry top spacing by doubling the row gap.
- Give the rule between `【背景】` and `【赏析】` symmetric top/bottom spacing equal to a normal commentary line gap.

Implemented central values:

```text
poem-role-panel-margin = 5.6mm
poem-role-frame-margin = 8mm
title-rule-gap = 5pt
cover-title-rule-gap = 6.7pt
toc-entry-row-gap = 16pt
context-commentary-rule-gap = 7pt
```

Implementation details:

- `role-ground()` now accepts panel/frame margin parameters.
- Cover and chapter divider pages call `role-ground(panel-margin: poem-role-panel-margin, frame-margin: poem-role-frame-margin)`.
- Poem body-context gap is computed as `resolved-title-gap * 2`.
- The context/commentary rule is placed with `context-commentary-rule-gap` above and below.

Implemented in:

```text
a3d2913 fix: tune title rules and poem context spacing [AGENT: peri]
```

### 8. Plan And Goal File Archival

User feedback:

```text
then commit all plan md files to .plans/ in repo
alongside add an additional goal.md file, matching their plan file prefix
```

Required behavior:

- Keep repo-local copies of the planning files under `.plans/`.
- Add a goal record file matching the `typst-book` prefix.
- Record the Discord `/goal` directives that drove the work.

Implemented files:

```text
.plans/typst-book-design-and-goal.md
.plans/typst-book-remediation-plan-2026-06-01.md
.plans/typst-book-remediation-plan-2026-06-01-pass2.md
.plans/typst-book-post-pass2-feedback-adjustments-2026-06-02.md
.plans/typst-book-image-prompt-pass3-plan-2026-06-02.md
.plans/typst-book-goal.md
```

Implemented in:

```text
29aedc2 docs: add typst book plan files [AGENT: peri]
848b90a docs: add typst book goal record [AGENT: peri]
```

## Current Accepted State

As of commit:

```text
a3d2913 fix: tune title rules and poem context spacing [AGENT: peri]
```

The accepted post-pass2 state is:

- role-page backgrounds centered again;
- `自然` and `启步` regenerated as selected spot-check samples;
- paragraph spacing increased to the moderate accepted values;
- over-large paragraph spacing reverted;
- poem page frame margins, top-title gap, title-body gap, and bottom text guard tuned centrally;
- cover and chapter divider frames use poem-like margins;
- body-context gap, title-rule gaps, TOC row spacing, and context/commentary rule spacing tuned centrally;
- plan and goal files archived under `.plans/`;
- latest PDF copied to iCloud Downloads and sync queue verified clear.

## Verification Expectations

For future post-pass2 adjustments:

- Run `just validate`.
- Run `just audit`.
- Run `just build`.
- Visually inspect affected pages with a PDF/contact sheet.
- Push to `origin/typst`.
- Copy the rebuilt PDF to iCloud Downloads.
- Confirm CloudDocs upload queue is clear.
- Report the commit, verification results, PDF path, and iCloud sync status.
