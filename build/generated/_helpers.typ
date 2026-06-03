#import "../../templates/book-style.typ": *
#import "../../templates/illustrated-poem-page.typ": illustrated-poem-page
#import "../../templates/auto-pinyin/lib.typ": to-pinyin

#let txt(value) = text(value)
#let pinyin-annotations(lines, override) = {
  let annotations = ()
  for (line-index, line) in lines.enumerate() {
    let chars = line.clusters()
    let pinyins = to-pinyin(line, style: "tone", override: override)
    for (cell-index, cell) in chars.enumerate() {
      let py = pinyins.at(cell-index)
      if py != cell {
        annotations.push((line: line-index, cell: cell-index, text: py))
      }
    }
  }
  annotations
}

#let title-pinyin(title, override) = {
  to-pinyin(title, style: "tone", override: override).zip(title.clusters()).map(pair => if pair.first() == pair.last() { none } else { pair.first() })
}

#let render-poem(title, poem-lines, context-note, commentary, asset, override) = {
  let render-image = (w, h, fit) => image("../../" + asset, width: w, height: h, fit: fit)
  illustrated-poem-page(
    title,
    poem-lines.map(line => line.clusters()),
    context-note,
    commentary,
    render-image,
    pinyin: pinyin-annotations(poem-lines, override),
    title-cells: title.clusters(),
    title-pinyin: title-pinyin(title, override),
  )
}

