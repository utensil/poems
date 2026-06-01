// Central book design system for the Typst illustrated edition.

#let poem-title-font = "STKaiti"
#let poem-body-font = "STKaiti"
#let cover-title-font = poem-title-font
#let cover-subtitle-font = "STFangsong"
#let author-font = "STFangsong"
#let chapter-title-font = poem-title-font
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

#let book-title-style(body) = text(font: poem-title-font, size: 36pt, weight: "bold", tracking: 2pt)[#body]
#let book-author-style(body) = text(font: author-font, size: 17pt)[#body]
#let toc-title-style(body) = text(font: prose-heading-font, size: 26pt, weight: "bold")[#body]
#let toc-entry-style(body) = text(font: toc-font, size: 12pt)[#body]
#let chapter-divider-style(body) = text(font: chapter-title-font, size: 34pt, weight: "bold", tracking: 2pt)[#body]
#let prose-title-style(body, size: 26pt) = text(font: prose-heading-font, size: size, weight: "bold", tracking: 0.6pt)[#body]
#let prose-body-style(body) = text(font: prose-body-font, size: 11.6pt)[#body]
#let prose-quote-style(body) = text(font: prose-body-font, size: 10.8pt, fill: muted)[#body]
#let poem-title-style(body) = text(font: poem-title-font)[#body]
#let poem-body-style(body) = text(font: poem-body-font)[#body]
#let commentary-style(body) = text(font: commentary-font)[#body]
#let context-style(body) = text(font: context-font)[#body]
#let chronology-style(body) = text(font: chronology-font)[#body]

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
    #book-title-style(title)
    #v(22pt)
    #book-author-style(author)
    #if subtitle != none [
      #v(11pt)
      #text(font: cover-subtitle-font, size: 12pt, fill: muted)[#subtitle]
    ]
  ]
}

#let prose-page(title, paragraphs, placeholder: false) = {
  base-page()
  align(center)[#prose-title-style(title, size: if title.clusters().len() > 16 { 22pt } else { 26pt })]
  v(18pt)
  set text(font: prose-body-font, size: 11.6pt)
  set par(first-line-indent: 2em, leading: 0.78em, justify: true)
  if placeholder {
    align(center)[#text(font: prose-body-font, size: 12pt, fill: muted)[（待补）]]
  } else {
    for p in paragraphs [
      #if p.kind == "quote" {
        block(
          inset: (left: 8mm, right: 6mm, y: 3mm),
          above: 2pt,
          below: 8pt,
          stroke: (left: (paint: faint-rule, thickness: 1pt)),
        )[
          #set par(first-line-indent: 0pt, leading: 0.72em, justify: true)
          #prose-quote-style(p.text)
        ]
      } else {
        block(above: 0pt, below: 7pt)[#prose-body-style(p.text)]
      }
    ]
  }
}

#let toc-page(entries) = {
  base-page()
  align(center)[#toc-title-style[目录]]
  v(16pt)
  set text(font: toc-font, size: 12pt)
  for entry in entries [
    #block(above: 0pt, below: 7pt)[
      #toc-entry-style(entry)
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
      #chapter-divider-style(line)
      #v(6pt)
    ]
  ]
}

#let chronology-page(entries) = {
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
}

#let appendix-article(title, paragraphs) = {
  prose-page(title, paragraphs)
}
