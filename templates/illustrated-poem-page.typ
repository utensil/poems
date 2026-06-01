// Reusable illustrated poem page renderer.
//
// Expected inputs:
// - `poem-lines`: array of equal-length arrays, one string per character cell.
// - `pinyin`: array of dictionaries: `(line: 2, cell: 4, text: "cháng")`.
//   Both `line` and `cell` are zero-based.
// - `commentary`: array of paragraph content/strings. The function adds
//   the bold `【赏析】` prefix to the first paragraph.

#let illustrated-poem-page(
  title,
  poem-lines,
  background-note,
  commentary,
  render-image,
  pinyin: (),
  title-cells: (),
  title-pinyin: (),
  page-w: 210mm,
  page-h: 297mm,
  fg-x: 10mm,
  fg-y: 7mm,
  fg-bottom: 8mm,
  pad-x: 8mm,
  pad-top: 11mm,
  bg-bleed-x: 14mm,
  bg-bleed-y: 20mm,
  image-aspect: 2 / 3,
  image-max-poem-ratio: 1.2,
  kait: "STKaiti",
  fsong: "STFangsong",
  pinyin-font: "Kaiti SC",
  title-size: 36pt,
  poem-size: 24pt,
  pinyin-size: 8pt,
  title-pinyin-size: 8pt,
  context-size: 11pt,
  commentary-size: 11pt,
  commentary-fit-size: 10pt,
  commentary-fit-overflow: 56pt,
  char-w: 24pt,
  poem-line-h: 31pt,
  annotated-line-h: 42pt,
  title-gap: none,
  after-poem-gap: none,
  poem-line-gap: 2pt,
  paragraph-gap: 14pt,
  context-commentary-gap: 31pt,
  commentary-break-after: none,
  ink-absorb-edge: 2pt,
) = {
  let fg-w = page-w - fg-x * 2
  let fg-h = page-h - fg-y - fg-bottom
  let content-x = fg-x + pad-x
  let content-y = fg-y + pad-top
  let content-w = fg-w - pad-x * 2
  let poem-cells = poem-lines.first().len()
  let poem-w = char-w * poem-cells
  let punct-visual-w = char-w / 3
  let title-visual-shift = -(char-w - punct-visual-w) / 2
  let resolved-title-gap = if title-gap == none {
    if title-pinyin.len() > 0 { annotated-line-h * 0.75 } else { annotated-line-h * 1.35 }
  } else { title-gap }
  let resolved-after-poem-gap = if after-poem-gap == none { resolved-title-gap } else { after-poem-gap }
  let title-pinyin-row-h = title-pinyin-size + 1pt
  let title-block-h = if title-pinyin.len() > 0 { title-size + title-pinyin-row-h + 1pt } else { title-size }
  let ink-absorb-wash = rgb("#fff8e9").transparentize(96%)

  let columns = ()
  for _ in range(poem-cells) {
    columns.push(char-w)
  }

  let annotation-for(line-index, cell-index) = {
    let found = none
    for ann in pinyin {
      if ann.line == line-index and ann.cell == cell-index {
        found = ann.text
      }
    }
    found
  }

  let poem-line(line-cells) = block(width: poem-w, height: poem-line-h)[
    #{
      let body = ()
      for (i, cell) in line-cells.enumerate() {
        let glyph = text(font: kait, size: poem-size)[#cell]
        if i == line-cells.len() - 1 {
          body.push(align(left + horizon, glyph))
        } else {
          body.push(glyph)
        }
      }
      grid(columns: columns, rows: (poem-size,), align: center + horizon, ..body)
    }
  ]

  let annotated-line(line-index, line-cells) = block(width: poem-w, height: annotated-line-h)[
    #{
      let py-row = ()
      let text-row = ()
      for (i, cell) in line-cells.enumerate() {
        let ann = annotation-for(line-index, i)
        if ann == none {
          py-row.push([])
        } else {
          py-row.push(text(font: pinyin-font, size: pinyin-size, fill: rgb("#8d8077"))[#ann])
        }

        let glyph = text(font: kait, size: poem-size)[#cell]
        if i == line-cells.len() - 1 {
          text-row.push(align(left + horizon, glyph))
        } else {
          text-row.push(glyph)
        }
      }
      grid(
        columns: columns,
        rows: (9pt, poem-size),
        row-gutter: 1pt,
        align: center + horizon,
        ..py-row,
        ..text-row,
      )
    }
  ]

  let title-block = if title-cells.len() > 0 and title-pinyin.len() == title-cells.len() {
    let title-cell-w = title-size * 0.9
    let title-columns = ()
    for _ in title-cells {
      title-columns.push(title-cell-w)
    }
    let py-row = title-pinyin.map(py => if py == none or py == "" { [] } else {
      text(font: pinyin-font, size: title-pinyin-size, fill: rgb("#8d8077"))[#py]
    })
    let text-row = title-cells.map(cell => text(font: kait, size: title-size, tracking: 3pt, fill: rgb("#2b1c18"))[#cell])
    box(width: poem-w, height: title-block-h)[
      #place(top + left, dx: title-visual-shift, dy: 0pt)[
        #box(width: poem-w)[
          #align(center)[
            #grid(
              columns: title-columns,
              rows: (title-pinyin-row-h, title-size),
              row-gutter: 1pt,
              align: center + horizon,
              ..py-row,
              ..text-row,
            )
          ]
        ]
      ]
    ]
  } else {
    box(width: poem-w, height: title-block-h)[
      #place(top + left, dx: title-visual-shift, dy: 0pt)[
        #box(width: poem-w)[
          #align(center, text(font: kait, size: title-size, tracking: 3pt, fill: rgb("#2b1c18"))[#title])
        ]
      ]
    ]
  }

  let poem-block = box(width: poem-w)[
    #title-block
    #v(resolved-title-gap)
    #for (line-index, line-cells) in poem-lines.enumerate() [
      #if pinyin.any(ann => ann.line == line-index) {
        annotated-line(line-index, line-cells)
      } else {
        poem-line(line-cells)
      }
      #if line-index < poem-lines.len() - 1 {
        v(poem-line-gap)
      }
    ]
  ]

  let para(body) = block(above: 0pt, below: paragraph-gap)[#body]
  let context-block = box(width: content-w)[
    #text(font: fsong, size: context-size, tracking: 0.3pt, fill: rgb("#60463b"))[
      #strong[【背景】]#background-note
    ]
  ]

  let page-background() = {
    place(top + left, dx: 0pt, dy: 0pt)[
      #render-image(page-w + bg-bleed-x * 2, page-h + bg-bleed-y * 2, "cover")
    ]
    place(top + left, dx: 0pt, dy: 0pt)[
      #rect(width: page-w, height: page-h, fill: rgb("#f3e7d3").transparentize(68%))
    ]
    place(top + left, dx: 0pt, dy: 0pt)[
      #rect(width: page-w, height: page-h, fill: rgb("#fff8e8").transparentize(32%))
    ]
    place(top + left, dx: fg-x, dy: fg-y)[
      #rect(width: fg-w, height: fg-h, radius: 6pt, fill: rgb("#fff8e9").transparentize(42%))
    ]
  }

  let commentary-block(start, stop: none, continued: false, size: commentary-size) = box(width: content-w)[
    #set text(font: fsong, size: size, tracking: 0.3pt, fill: rgb("#2f231f"))
    #set par(leading: 0.58em, justify: false)
    #if continued {
      block(above: 0pt, below: paragraph-gap)[#strong[【赏析】续]]
    }
    #for (i, p) in commentary.enumerate() [
      #if i >= start and (stop == none or i < stop) {
        if i == 0 {
          para[#strong[【赏析】]#p]
        } else {
          para[#p]
        }
      }
    ]
  ]

  set page(width: page-w, height: page-h, margin: 0pt, fill: rgb("#f3e7d3"))
  set text(lang: "zh", region: "cn", fill: rgb("#2f231f"))

  page-background()

  context {
    let poem-size-measured = measure(poem-block)
    let image-h-from-poem = poem-size-measured.height
    let image-w-from-poem = image-h-from-poem * image-aspect
    let image-w = calc.min(image-w-from-poem, poem-w * image-max-poem-ratio)
    let image-h = image-w / image-aspect
    let image-y = (poem-size-measured.height - image-h) / 2
    let top-row-gap = (content-w - poem-w - image-w) / 3
    let top-row = grid(
      columns: (top-row-gap, poem-w, top-row-gap, image-w, top-row-gap),
      rows: (poem-size-measured.height,),
      column-gutter: 0pt,
      [],
      poem-block,
      [],
      box(width: image-w, height: poem-size-measured.height)[
        #place(top + left, dx: 0pt, dy: image-y)[
          #box(width: image-w, height: image-h, clip: true)[
            #render-image(image-w, image-h, "cover")
          ]
        ]
        #place(top + left, dx: 0pt, dy: image-y)[
          #rect(width: image-w, height: ink-absorb-edge, fill: ink-absorb-wash)
        ]
        #place(top + left, dx: 0pt, dy: image-y + image-h - ink-absorb-edge)[
          #rect(width: image-w, height: ink-absorb-edge, fill: ink-absorb-wash)
        ]
        #place(top + left, dx: 0pt, dy: image-y)[
          #rect(width: ink-absorb-edge, height: image-h, fill: ink-absorb-wash)
        ]
        #place(top + right, dx: 0pt, dy: image-y)[
          #rect(width: ink-absorb-edge, height: image-h, fill: ink-absorb-wash)
        ]
      ],
      [],
    )

    let context-y = poem-size-measured.height + resolved-after-poem-gap
    let context-size-measured = measure(context-block)
    let commentary-y = context-y + context-size-measured.height + context-commentary-gap
    let rule-y = context-y + context-size-measured.height + context-commentary-gap / 2
    let available-h = fg-y + fg-h - (content-y + commentary-y)
    let full-commentary-h = measure(commentary-block(0)).height
    let fit-commentary-h = measure(commentary-block(0, size: commentary-fit-size)).height
    let commentary-overflow = full-commentary-h - available-h
    let can-fit-by-shrinking = commentary-break-after == none and commentary-overflow > 0pt and commentary-overflow <= commentary-fit-overflow and fit-commentary-h <= available-h
    let first-page-commentary-size = if can-fit-by-shrinking {
      commentary-fit-size
    } else {
      commentary-size
    }
    let first-commentary-count = if commentary-break-after == none {
      commentary.len()
    } else if commentary-break-after == "auto" {
      let count = 0
      for i in range(commentary.len()) {
        if measure(commentary-block(0, stop: i + 1)).height <= available-h {
          count = i + 1
        }
      }
      calc.max(count, 1)
    } else {
      commentary-break-after
    }

    place(top + left, dx: content-x, dy: content-y)[
      #top-row
    ]
    place(top + left, dx: content-x, dy: content-y + context-y)[
      #context-block
    ]
    place(top + left, dx: content-x, dy: content-y + rule-y)[
      #line(length: content-w, stroke: (paint: rgb("#7d5b4f").transparentize(76%), thickness: 0.5pt))
    ]
    place(top + left, dx: content-x, dy: content-y + commentary-y)[
      #commentary-block(0, stop: first-commentary-count, size: first-page-commentary-size)
    ]

    if first-commentary-count < commentary.len() {
      pagebreak()
      page-background()
      place(top + left, dx: content-x, dy: content-y)[
        #commentary-block(first-commentary-count, continued: true)
      ]
    }
  }
}
