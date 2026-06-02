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

## Current Accepted State

As of commit:

```text
b140449 Revert "fix: double prose and commentary paragraph gaps again [AGENT: peri]"
```

The accepted post-pass2 state is:

- role-page backgrounds centered again;
- `自然` and `启步` regenerated as selected spot-check samples;
- paragraph spacing increased to the moderate accepted values;
- over-large paragraph spacing reverted;
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
