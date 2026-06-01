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
  title-size: 34pt,
  poem-size: 22pt,
  pinyin-size: 8pt,
  title-pinyin-size: 8pt,
  context-size: 11pt,
  commentary-size: 11pt,
  commentary-fit-size: 10pt,
  commentary-fit-overflow: 56pt,
  char-w: 22pt,
  poem-line-h: 27pt,
  annotated-line-h: 36pt,
  title-gap: none,
  title-body-gap-factor: 0.5,
  after-poem-gap: none,
  poem-line-gap: 1pt,
  paragraph-gap: 9pt,
  context-commentary-gap: 14pt,
  min-first-page-note-height: 88pt,
  commentary-break-after: "auto",
  ink-absorb-edge: 2pt,
) = {
  let fg-w = page-w - fg-x * 2
  let fg-h = page-h - fg-y - fg-bottom
  let content-x = fg-x + pad-x
  let content-y = fg-y + pad-top
  let content-w = fg-w - pad-x * 2
  let poem-cells = poem-lines.first().len()
  let long-poem = poem-lines.len() >= 14
  let actual-title-size = if long-poem { 30pt } else { title-size }
  let actual-poem-size = if long-poem { 19.5pt } else { poem-size }
  let actual-pinyin-size = if long-poem { 6.8pt } else { pinyin-size }
  let actual-title-pinyin-size = if long-poem { 7pt } else { title-pinyin-size }
  let actual-char-w = if long-poem { 20pt } else { char-w }
  let actual-poem-line-h = if long-poem { 24pt } else { poem-line-h }
  let actual-annotated-line-h = if long-poem { 31pt } else { annotated-line-h }
  let poem-w = actual-char-w * poem-cells
  let punct-visual-w = actual-char-w / 3
  let title-visual-shift = -(actual-char-w - punct-visual-w) / 2
  let resolved-title-gap = if title-gap == none {
    (if title-pinyin.len() > 0 { actual-annotated-line-h * 0.75 } else { actual-annotated-line-h * 1.35 }) * title-body-gap-factor
  } else { title-gap }
  let resolved-after-poem-gap = if after-poem-gap == none { resolved-title-gap } else { after-poem-gap }
  let title-pinyin-row-h = actual-title-pinyin-size + 1pt
  let title-block-h = if title-pinyin.len() > 0 { actual-title-size + title-pinyin-row-h + 1pt } else { actual-title-size }
  let ink-absorb-wash = rgb("#fff8e9").transparentize(96%)

  let columns = ()
  for _ in range(poem-cells) {
    columns.push(actual-char-w)
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

  let poem-line(line-cells) = block(width: poem-w, height: actual-poem-line-h)[
    #{
      let body = ()
      for (i, cell) in line-cells.enumerate() {
        let glyph = text(font: kait, size: actual-poem-size)[#cell]
        if i == line-cells.len() - 1 {
          body.push(align(left + horizon, glyph))
        } else {
          body.push(glyph)
        }
      }
      grid(columns: columns, rows: (actual-poem-size,), align: center + horizon, ..body)
    }
  ]

  let annotated-line(line-index, line-cells) = block(width: poem-w, height: actual-annotated-line-h)[
    #{
      let py-row = ()
      let text-row = ()
      for (i, cell) in line-cells.enumerate() {
        let ann = annotation-for(line-index, i)
        if ann == none {
          py-row.push([])
        } else {
          py-row.push(text(font: pinyin-font, size: actual-pinyin-size, fill: rgb("#8d8077"))[#ann])
        }

        let glyph = text(font: kait, size: actual-poem-size)[#cell]
        if i == line-cells.len() - 1 {
          text-row.push(align(left + horizon, glyph))
        } else {
          text-row.push(glyph)
        }
      }
      grid(
        columns: columns,
        rows: (actual-pinyin-size + 1pt, actual-poem-size),
        row-gutter: 1pt,
        align: center + horizon,
        ..py-row,
        ..text-row,
      )
    }
  ]

  let title-block = if title-cells.len() > 0 and title-pinyin.len() == title-cells.len() {
    let title-cell-w = actual-title-size * 0.9
    let title-columns = ()
    for _ in title-cells {
      title-columns.push(title-cell-w)
    }
    let py-row = title-pinyin.map(py => if py == none or py == "" { [] } else {
      text(font: pinyin-font, size: actual-title-pinyin-size, fill: rgb("#8d8077"))[#py]
    })
    let text-row = title-cells.map(cell => text(font: kait, size: actual-title-size, tracking: 3pt, fill: rgb("#2b1c18"))[#cell])
    box(width: poem-w, height: title-block-h)[
      #place(top + left, dx: title-visual-shift, dy: 0pt)[
        #box(width: poem-w)[
          #align(center)[
            #grid(
              columns: title-columns,
              rows: (title-pinyin-row-h, actual-title-size),
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
          #align(center, text(font: kait, size: actual-title-size, tracking: 3pt, fill: rgb("#2b1c18"))[#title])
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
    #set par(leading: 0.62em, justify: false)
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
    let max-image-w = calc.max(30mm, content-w - poem-w - 20mm)
    let image-w = calc.min(calc.min(image-w-from-poem, poem-w * image-max-poem-ratio), max-image-w)
    let image-h = image-w / image-aspect
    let image-y = (poem-size-measured.height - image-h) / 2
    let top-row-gap = (content-w - poem-w - image-w) / 3
    if top-row-gap < 0pt {
      panic("poem top row overflow: " + title)
    }
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

    let content-bottom = fg-y + fg-h
    let continuation-h = content-bottom - content-y
    let context-y = poem-size-measured.height + resolved-after-poem-gap
    let context-size-measured = measure(context-block)
    let commentary-y = context-y + context-size-measured.height + context-commentary-gap
    let rule-y = context-y + context-size-measured.height + context-commentary-gap / 2
    let available-h = content-bottom - (content-y + commentary-y)
    let full-commentary-h = measure(commentary-block(0)).height
    let fit-commentary-h = measure(commentary-block(0, size: commentary-fit-size)).height
    let commentary-overflow = full-commentary-h - available-h
    let can-fit-by-shrinking = commentary-break-after == none and commentary-overflow > 0pt and commentary-overflow <= commentary-fit-overflow and fit-commentary-h <= available-h
    let first-page-commentary-size = if can-fit-by-shrinking {
      commentary-fit-size
    } else {
      commentary-size
    }
    let has-room-for-notes = available-h >= min-first-page-note-height
    let first-commentary-count = if not has-room-for-notes {
      0
    } else if commentary-break-after == none {
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
    if has-room-for-notes {
      place(top + left, dx: content-x, dy: content-y + context-y)[
        #context-block
      ]
      place(top + left, dx: content-x, dy: content-y + rule-y)[
        #line(length: content-w, stroke: (paint: rgb("#7d5b4f").transparentize(76%), thickness: 0.5pt))
      ]
      place(top + left, dx: content-x, dy: content-y + commentary-y)[
        #commentary-block(0, stop: first-commentary-count, size: first-page-commentary-size)
      ]
    }

    let continuation-page(start, with-context: false) = {
      let y0 = if with-context { 0pt } else { 0pt }
      let start-y = y0
      let body-top = if with-context {
        let ctx-h = measure(context-block).height
        ctx-h + context-commentary-gap
      } else {
        0pt
      }
      let body-h = continuation-h - body-top
      let stop = start
      for i in range(start, commentary.len()) {
        let h = measure(commentary-block(start, stop: i + 1, continued: start > 0)).height
        if h <= body-h {
          stop = i + 1
        }
      }
      if stop <= start {
        stop = start + 1
      }
      pagebreak()
      page-background()
      if with-context {
        place(top + left, dx: content-x, dy: content-y + start-y)[
          #context-block
        ]
        place(top + left, dx: content-x, dy: content-y + start-y + measure(context-block).height + context-commentary-gap / 2)[
          #line(length: content-w, stroke: (paint: rgb("#7d5b4f").transparentize(76%), thickness: 0.5pt))
        ]
      }
      place(top + left, dx: content-x, dy: content-y)[
        #move(dy: body-top)[#commentary-block(start, stop: stop, continued: start > 0)]
      ]
      if stop < commentary.len() {
        continuation-page(stop)
      }
    }

    if first-commentary-count < commentary.len() {
      continuation-page(first-commentary-count, with-context: not has-room-for-notes)
    }
  }
}
