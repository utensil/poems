# Typst Book Goals

This file records the Discord `/goal` directives that drove the Typst poem book work. It sits alongside the plan files under `.plans/` and uses the same `typst-book` prefix.

Source Discord messages:

```text
https://discord.com/channels/1089537860106993716/1510954118691291206/1510966162190762004
https://discord.com/channels/1089537860106993716/1510954118691291206/1510994302627610715
https://discord.com/channels/1089537860106993716/1510954118691291206/1511056093034582116
```

## Goal 1: Initial Typst Book Pipeline

Source message:

```text
1510966162190762004
```

Directive:

```text
Create branch `typst` in `/Users/utensil/projects/poems` from `origin/master` and implement the Typst illustrated poem book pipeline described in `/Users/utensil/.illustrated-poem-page/typst-book-design-and-goal.md`.

Key completion criteria are in the file, including: branch is typst, 77 poems in src/book.yaml, Markdown poem/commentary sources, 凡例/年谱/代后记/LLM说明, prompt/image assets, just validate, just build, and Chrome-openable PDF.

Report and push to origin after every phase complete. Ack the task after reading the file.
```

Related plan file:

```text
.plans/typst-book-design-and-goal.md
```

## Goal 2: Pass2 Remediation

Source message:

```text
1510994302627610715
```

Directive:

```text
Work in /Users/utensil/projects/poems on branch typst. Remediate the Typst poem book according to /Users/utensil/.illustrated-poem-page/typst-book-remediation-plan-2026-06-01-pass2.md.

Do not mark complete until just validate, just audit, and just build pass, the rebuilt PDF is opened in Chrome, and the listed spot-check pages prove the known failures are fixed.

Report to discord and push to origin after every phase complete. Ack the task after reading the file.
```

Related plan file:

```text
.plans/typst-book-remediation-plan-2026-06-01-pass2.md
```

## Goal 3: Finish Incomplete Pass2

Source message:

```text
1511056093034582116
```

Directive:

```text
Work in /Users/utensil/projects/poems on branch typst. Finish pass2 remediation against /Users/utensil/.illustrated-poem-page/typst-book-remediation-plan-2026-06-01-pass2.md. Treat the previous pass2 commits as incomplete.

Specifically fix: unified visual redesign for cover, TOC/index, preface, 凡例, 年谱, 代后记, 赏析编写说明, and chapter dividers; correct prose paragraph spacing and quote styling; deterministic poem spacing/split/preflight so 十月、疹热、自然、启步 have no overflow and no missing background/commentary; TOC/index visual quality and 年谱 child-entry behavior; prompt-sidecar quality and any required selected sample image regeneration.

Do not mark complete until just validate, just audit, and just build pass, Chrome visual spot-check proves the listed pages are fixed, and audit gates would fail on the old visual/source failures.

Report and push after each phase.
```

Related plan files:

```text
.plans/typst-book-remediation-plan-2026-06-01-pass2.md
.plans/typst-book-post-pass2-feedback-adjustments-2026-06-02.md
```

## Standing Completion Discipline

For goals derived from these plans:

- work on branch `typst`;
- keep verification stronger than Typst compilation alone;
- run the relevant `just` gates before completion;
- visually inspect the generated PDF when page layout is affected;
- report to Discord and push after each completed phase;
- for PDF-affecting changes after the iCloud feedback adjustment, copy the rebuilt PDF to iCloud Downloads and confirm CloudDocs upload queue clears.
