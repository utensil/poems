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
#let wash = rgb("#fff8e9")
#let role-panel = wash.transparentize(30%)
#let role-paper = rgb("#f3e7d3")
#let prose-paragraph-gap = 20pt
#let prose-quote-gap = 18pt
#let role-panel-margin = 11.2mm
#let role-frame-margin = 16.8mm
#let poem-role-panel-margin = 5.6mm
#let poem-role-frame-margin = 8mm
#let title-rule-gap = 1.25pt
#let cover-title-rule-gap = 1.7pt
#let toc-entry-row-gap = 16pt

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

#let role-ground(frame: true, panel-margin: role-panel-margin, frame-margin: role-frame-margin) = {
  place(top + left, dx: 0pt, dy: 0pt)[
    #rect(width: 210mm, height: 297mm, fill: role-paper)
  ]
  place(top + left, dx: panel-margin, dy: panel-margin)[
    #rect(width: 210mm - panel-margin * 2, height: 297mm - panel-margin * 2, radius: 5pt, fill: role-panel)
  ]
  if frame {
    place(top + left, dx: frame-margin, dy: frame-margin)[
      #rect(width: 210mm - frame-margin * 2, height: 297mm - frame-margin * 2, radius: 2pt, stroke: (paint: faint-rule, thickness: 0.5pt))
    ]
  }
}

#let title-line(text-value, font: prose-heading-font, size: 26pt) = {
  align(center)[#text(font: font, size: size, weight: "bold", tracking: 1pt)[#text-value]]
}

#let measured-title-rule(title-content, line-length: 34mm, gap: title-rule-gap, thickness: 0.5pt) = context {
  let title-size = measure(title-content)
  box(width: 100%, height: title-size.height + gap + thickness)[
    #place(top + center, dy: 0pt)[#title-content]
    #place(top + center, dy: title-size.height + gap)[
      #line(length: line-length, stroke: (paint: faint-rule, thickness: thickness))
    ]
  ]
}

#let cover-page(title, author, subtitle: none) = {
  set page(width: 210mm, height: 297mm, margin: 0pt, fill: role-paper)
  set text(lang: "zh", region: "cn", fill: ink)
  role-ground(panel-margin: poem-role-panel-margin, frame-margin: poem-role-frame-margin)
  align(center + horizon)[
    #measured-title-rule(book-title-style(title), line-length: 38mm, gap: cover-title-rule-gap, thickness: 0.6pt)
    #v(18pt)
    #book-author-style(author)
    #if subtitle != none [
      #v(11pt)
      #text(font: cover-subtitle-font, size: 12pt, fill: muted)[#subtitle]
    ]
  ]
}

#let prose-page(title, paragraphs, placeholder: false) = {
  set page(
    width: 210mm,
    height: 297mm,
    margin: 0pt,
    fill: paper,
    background: role-ground(panel-margin: poem-role-panel-margin, frame-margin: poem-role-frame-margin),
  )
  set text(lang: "zh", region: "cn", fill: ink)
  pad(x: 28mm, y: 25mm)[
    #measured-title-rule(prose-title-style(title, size: if title.clusters().len() > 16 { 22pt } else { 26pt }), line-length: 34mm)
    #v(15pt)
    #set text(font: prose-body-font, size: 11.6pt)
    #set par(first-line-indent: 2em, leading: 0.66em, justify: true)
    #{
      if placeholder {
        align(center)[
          #block(width: 110mm)[
            #text(font: prose-body-font, size: 12pt, fill: muted)[（待补）]
          ]
        ]
      } else {
        for p in paragraphs {
          if p.kind == "quote" {
            block(
              inset: (left: 7mm, right: 6mm, y: 3mm),
              above: 3pt,
            below: prose-quote-gap,
              stroke: (left: (paint: faint-rule, thickness: 1pt)),
            )[
              #set par(first-line-indent: 0pt, leading: 0.62em, justify: true)
              #prose-quote-style(p.text)
            ]
          } else {
            block(above: 0pt, below: prose-paragraph-gap)[#h(2em)#prose-body-style(p.text)]
          }
        }
      }
    }
  ]
}

#let toc-page(entries) = {
  set page(
    width: 210mm,
    height: 297mm,
    margin: 0pt,
    fill: paper,
    background: role-ground(panel-margin: poem-role-panel-margin, frame-margin: poem-role-frame-margin),
  )
  set text(lang: "zh", region: "cn", fill: ink)
  pad(x: 30mm, y: 26mm)[
    #measured-title-rule(toc-title-style[目录], line-length: 32mm)
    #v(18pt)
    #set text(font: toc-font, size: 13.2pt)
    #set par(leading: 0.55em, justify: false)
    #align(center)[
      #grid(
        columns: (1fr, 1fr),
        column-gutter: 18mm,
        row-gutter: toc-entry-row-gap,
        ..entries.map(entry => block(width: 54mm)[
          #toc-entry-style(entry)
          #v(4pt)
          #line(length: 100%, stroke: (paint: faint-rule, thickness: 0.35pt))
        ]),
      )
    ]
  ]
}

#let chapter-divider(title-lines, count) = {
  set page(width: 210mm, height: 297mm, margin: 0pt, fill: role-paper)
  set text(lang: "zh", region: "cn", fill: ink)
  role-ground(panel-margin: poem-role-panel-margin, frame-margin: poem-role-frame-margin)
  align(center + horizon)[
    #block(width: 126mm)[
      #for (i, line) in title-lines.enumerate() [
        #align(center)[#chapter-divider-style(line)]
        #if i < title-lines.len() - 1 { v(8pt) }
      ]
    ]
  ]
}

#let chronology-page(entries) = {
  set page(
    width: 210mm,
    height: 297mm,
    margin: 0pt,
    fill: paper,
    background: role-ground(panel-margin: poem-role-panel-margin, frame-margin: poem-role-frame-margin),
  )
  set text(lang: "zh", region: "cn", fill: ink)
  pad(x: 27mm, y: 25mm)[
    #measured-title-rule(prose-title-style[年谱], line-length: 30mm)
    #v(16pt)
    #set text(font: chronology-font, size: 11pt)
    #set par(leading: 0.58em, justify: false)
    #for entry in entries [
      #grid(
        columns: (31mm, 1fr),
        column-gutter: 8mm,
        align: top,
        text(fill: muted)[#entry.period],
        text[#entry.poems],
      )
      #v(7pt)
    ]
  ]
}

#let appendix-article(title, paragraphs) = {
  prose-page(title, paragraphs)
}
