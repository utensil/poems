// Central book design system for the Typst illustrated edition.

#let cover-title-font = "Zhuque Fangsong (technical preview)"
#let cover-subtitle-font = "STFangsong"
#let author-font = "STFangsong"
#let chapter-title-font = "STKaiti"
#let poem-title-font = "STKaiti"
#let poem-body-font = "STKaiti"
#let pinyin-font = "Kaiti SC"
#let context-font = "STFangsong"
#let commentary-font = "STFangsong"
#let prose-heading-font = "STKaiti"
#let prose-body-font = "Zhuque Fangsong (technical preview)"
#let chronology-font = "STFangsong"
#let toc-font = "STFangsong"

#let paper = rgb("#f8f1e6")
#let ink = rgb("#2f231f")
#let muted = rgb("#6f5a50")
#let faint-rule = rgb("#8c6e5d").transparentize(70%)

#let base-page() = {
  set page(width: 210mm, height: 297mm, margin: (x: 24mm, y: 24mm), fill: paper)
  set text(lang: "zh", region: "cn", fill: ink)
}

#let title-line(text-value, font: prose-heading-font, size: 26pt) = {
  align(center)[#text(font: font, size: size, weight: "bold", tracking: 1pt)[#text-value]]
}

#let cover-page(title, author, subtitle: none) = {
  base-page()
  align(center + horizon)[
    #text(font: cover-title-font, size: 36pt, weight: "bold", tracking: 2pt)[#title]
    #v(22pt)
    #text(font: author-font, size: 17pt)[#author]
    #if subtitle != none [
      #v(11pt)
      #text(font: cover-subtitle-font, size: 12pt, fill: muted)[#subtitle]
    ]
  ]
}

#let prose-page(title, paragraphs, placeholder: false) = {
  base-page()
  align(center)[#text(font: prose-heading-font, size: 26pt, weight: "bold", tracking: 1pt)[#title]]
  v(18pt)
  set text(font: prose-body-font, size: 11.6pt)
  set par(first-line-indent: 2em, leading: 0.86em, justify: true)
  if placeholder {
    align(center)[#text(font: prose-body-font, size: 12pt, fill: muted)[（待补）]]
  } else {
    for p in paragraphs [
      #block(above: 0pt, below: 10pt)[#p]
    ]
  }
}

#let toc-page(entries) = {
  base-page()
  align(center)[#text(font: prose-heading-font, size: 26pt, weight: "bold")[目录]]
  v(16pt)
  set text(font: toc-font, size: 12pt)
  for entry in entries [
    #block(above: 0pt, below: 7pt)[
      #text[#entry]
    ]
  ]
}

#let chapter-divider(title-lines, count) = {
  set page(width: 210mm, height: 297mm, margin: 0pt, fill: rgb("#f3e7d3"))
  set text(lang: "zh", region: "cn", fill: ink)
  place(top + left, dx: 12mm, dy: 10mm)[
    #rect(width: 186mm, height: 277mm, radius: 6pt, fill: rgb("#fff8e9").transparentize(36%))
  ]
  align(center + horizon)[
    #for line in title-lines [
      #text(font: chapter-title-font, size: 34pt, weight: "bold", tracking: 2pt)[#line]
      #v(6pt)
    ]
    #v(16pt)
    #text(font: chronology-font, size: 12pt, fill: muted)[本章收录 #str(count) 首]
  ]
}

#let chronology-page(entries, skipped) = {
  base-page()
  align(center)[#text(font: prose-heading-font, size: 26pt, weight: "bold")[年谱]]
  v(16pt)
  set text(font: chronology-font, size: 11.2pt)
  set par(leading: 0.72em, justify: false)
  for entry in entries [
    #grid(
      columns: (28mm, 1fr),
      column-gutter: 8mm,
      align: top,
      text(fill: muted)[#entry.period],
      text[#entry.poems],
    )
    #v(7pt)
  ]
  v(10pt)
  line(length: 100%, stroke: (paint: faint-rule, thickness: 0.5pt))
  v(6pt)
  text(size: 10pt, fill: muted)[未列入年谱：#skipped]
}

#let appendix-article(title, paragraphs) = {
  prose-page(title, paragraphs)
}
