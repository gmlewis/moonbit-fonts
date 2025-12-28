///|
test "to_graphic and text SVG renders" {
  let font = nullpointer
  let text_str = "A"

  // 1. to_graphic, y_up=false - "A" will appear upside-down
  let g1 = @draw.to_graphic(font, text_str, y_up=false) catch {
    _ => abort("g1 failed")
  }
  inspect(
    from_graphic(g1),
    content=(
      #|<svg xmlns="http://www.w3.org/2000/svg" viewBox="0.048 0.723 0.459 0.699">
      #|  <path d="M0.507 0.723L0.048 0.723L0.048 1.229L0.395 1.229L0.395 1.3239999999999998L0.048 1.3239999999999998L0.048 1.422L0.507 1.422L0.507 0.723ZM0.395 0.968L0.395 1.132L0.138 1.132L0.138 0.968L0.395 0.968Z" stroke="none" fill="#000000"/>
      #|</svg>
    ),
  )

  // 2. to_graphic, y_up=true - "A" will appear right-side-up
  let g2 = @draw.to_graphic(font, text_str, y_up=true) catch {
    _ => abort("g2 failed")
  }
  inspect(
    from_graphic(g2),
    content=(
      #|<svg xmlns="http://www.w3.org/2000/svg" viewBox="0.048 -0.024 0.459 0.699">
      #|  <path d="M0.507 0.675L0.048 0.6749999999999999L0.048 0.16899999999999993L0.395 0.16899999999999993L0.395 0.07399999999999995L0.048 0.07399999999999995L0.048 -0.02400000000000002L0.507 -0.02400000000000002L0.507 0.6749999999999999ZM0.395 0.43L0.395 0.26599999999999996L0.138 0.26599999999999996L0.138 0.42999999999999994L0.395 0.42999999999999994Z" stroke="none" fill="#000000"/>
      #|</svg>
    ),
  )

  // 3. text, y_up=false - "A" will appear upside-down
  let g3 = @draw.text(font, text_str, y_up=false) catch {
    _ => abort("g3 failed")
  }
  inspect(
    from_graphic(g3),
    content=(
      #|<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0.723 0.459 0.699">
      #|  <path d="M0.459 0.723L0 0.723L0 1.229L0.34700000000000003 1.229L0.34700000000000003 1.3239999999999998L0 1.3239999999999998L0 1.422L0.459 1.422L0.459 0.723ZM0.347 0.968L0.34700000000000003 1.132L0.09 1.132L0.09 0.968L0.34700000000000003 0.968Z" stroke="none" fill="#000000"/>
      #|</svg>
    ),
  )

  // 4. text, y_up=true - "A" will appear right-side-up
  let g4 = @draw.text(font, text_str, y_up=true) catch {
    _ => abort("g4 failed")
  }
  inspect(
    from_graphic(g4),
    content=(
      #|<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 -0.024 0.459 0.699">
      #|  <path d="M0.459 0.675L0 0.6749999999999999L0 0.16899999999999993L0.34700000000000003 0.16899999999999993L0.34700000000000003 0.07399999999999995L0 0.07399999999999995L0 -0.02400000000000002L0.459 -0.02400000000000002L0.459 0.6749999999999999ZM0.347 0.43L0.34700000000000003 0.26599999999999996L0.09 0.26599999999999996L0.09 0.42999999999999994L0.34700000000000003 0.42999999999999994Z" stroke="none" fill="#000000"/>
      #|</svg>
    ),
  )
}

///|
let glyphs : Map[String, @fonts.Glyph] = {
  "A": {
    char: "A",
    horiz_adv_x: 0.0,
    gerber_lp: "dc",
    d: "M507 24L48 24L48 530L395 530L395 625L48 625L48 723L507 723L507 24ZM395 269L395 433L138 433L138 269L395 269Z",
    xmin: 48.0,
    ymin: 24.0,
    xmax: 507.0,
    ymax: 723.0,
  },
  "B": {
    char: "B",
    horiz_adv_x: 0.0,
    gerber_lp: "dc",
    d: "M507 21L48 21L48 723L160 723L160 530L507 530L507 21ZM417 269L417 433L160 433L160 269L417 269Z",
    xmin: 48.0,
    ymin: 21.0,
    xmax: 507.0,
    ymax: 723.0,
  },
  "C": {
    char: "C",
    horiz_adv_x: 0.0,
    gerber_lp: "d",
    d: "M507 21L48 21L48 723L507 723L507 625L160 625L160 269L507 269L507 21Z",
    xmin: 48.0,
    ymin: 21.0,
    xmax: 507.0,
    ymax: 723.0,
  },
}

///|
let nullpointer : @fonts.Font = {
  id: "nullpointer",
  horiz_adv_x: 540.0,
  units_per_em: 1000.0,
  ascent: 800.0,
  descent: -200.0,
  glyphs,
}
