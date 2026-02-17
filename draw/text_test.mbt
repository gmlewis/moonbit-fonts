///|
let text_test_font_glyphs : Map[String, @fonts.Glyph] = {
  "*": {
    char: "*",
    horiz_adv_x: 120.0,
    gerber_lp: "d",
    d: "M0 0L50 0L50 100L0 100Z",
    xmin: 0.0,
    ymin: 0.0,
    xmax: 50.0,
    ymax: 100.0,
  },
  "A": {
    char: "A",
    horiz_adv_x: 120.0,
    gerber_lp: "d",
    d: "M0 0L80 0L80 100L0 100Z",
    xmin: 0.0,
    ymin: 0.0,
    xmax: 80.0,
    ymax: 100.0,
  },
}

///|
let text_test_font : @fonts.Font = {
  id: "text-test-font",
  horiz_adv_x: 120.0,
  units_per_em: 1000.0,
  ascent: 800.0,
  descent: -200.0,
  glyphs: text_test_font_glyphs,
}

///|
test "text_with/Override by grapheme_index" {
  let red_fill = fill(rgba(1, 0, 0, 1))
  let black_fill = fill(rgba(0, 0, 0, 1))
  let graphic = text_with(
    text_test_font,
    "*A",
    size=100,
    style_fn=text_with_style_fn(fn(ctx) {
      if ctx.grapheme_index == 0 {
        glyph_style_override(fill=red_fill)
      } else {
        glyph_style_override(fill=black_fill)
      }
    }),
  )
  let paths = graphic.all_compound_paths()
  inspect(paths.length(), content="2")
  inspect(paths[0].fill.unwrap().color.to_css_string(), content="#FF0000")
  inspect(paths[1].fill.unwrap().color.to_css_string(), content="#000000")
}

///|
test "text_with/Skip marker then Override next" {
  let red_fill = fill(rgba(1, 0, 0, 1))
  let black_fill = fill(rgba(0, 0, 0, 1))
  let graphic = text_with(
    text_test_font,
    "*A",
    size=100,
    style_fn=text_with_style_fn(fn(ctx) {
      if ctx.grapheme == "*" {
        glyph_style_skip()
      } else if ctx.grapheme_index == 1 {
        glyph_style_override(fill=red_fill)
      } else {
        glyph_style_override(fill=black_fill)
      }
    }),
  )
  let paths = graphic.all_compound_paths()
  inspect(paths.length(), content="1")
  inspect(paths[0].fill.unwrap().color.to_css_string(), content="#FF0000")
}

///|
test "text_with/UseDefault and Override stroke" {
  let green_stroke = stroke(rgba(0, 1, 0, 1), width=2)
  let graphic = text_with(
    text_test_font,
    "AA",
    size=100,
    style_fn=text_with_style_fn(fn(ctx) {
      if ctx.grapheme_index == 0 {
        glyph_style_override(stroke=green_stroke)
      } else {
        glyph_style_use_default()
      }
    }),
  )
  let paths = graphic.all_compound_paths()
  inspect(paths.length(), content="2")
  inspect(paths[0].stroke.unwrap().color.to_css_string(), content="#00FF00")
  inspect(paths[0].fill.unwrap().color.to_css_string(), content="#000000")
  inspect(paths[1].stroke, content="None")
  inspect(paths[1].fill.unwrap().color.to_css_string(), content="#000000")
}

///|
test "text_with_tuple/compatibility helper" {
  let red_fill = fill(rgba(1, 0, 0, 1))
  let black_fill = fill(rgba(0, 0, 0, 1))
  let graphic = text_with_tuple(
    text_test_font,
    "A*",
    size=100,
    style_fn=text_with_tuple_style_fn(fn(_pos, glyph) {
      if glyph == "*" {
        (None, Some(red_fill))
      } else {
        (None, Some(black_fill))
      }
    }),
  )
  let paths = graphic.all_compound_paths()
  inspect(paths.length(), content="2")
  inspect(paths[0].fill.unwrap().color.to_css_string(), content="#000000")
  inspect(paths[1].fill.unwrap().color.to_css_string(), content="#FF0000")
}

///|
test "text_with/context line_index across newline" {
  let red_fill = fill(rgba(1, 0, 0, 1))
  let black_fill = fill(rgba(0, 0, 0, 1))
  let graphic = text_with(
    text_test_font,
    "A\nA",
    size=100,
    style_fn=text_with_style_fn(fn(ctx) {
      if ctx.line_index == 0 {
        glyph_style_override(fill=black_fill)
      } else {
        glyph_style_override(fill=red_fill)
      }
    }),
  )
  let paths = graphic.all_compound_paths()
  inspect(paths.length(), content="2")
  inspect(paths[0].fill.unwrap().color.to_css_string(), content="#000000")
  inspect(paths[1].fill.unwrap().color.to_css_string(), content="#FF0000")
}

///|
test "text_with/context grapheme_index_in_line resets" {
  let red_fill = fill(rgba(1, 0, 0, 1))
  let black_fill = fill(rgba(0, 0, 0, 1))
  let graphic = text_with(
    text_test_font,
    "AA\nA",
    size=100,
    style_fn=text_with_style_fn(fn(ctx) {
      if ctx.grapheme_index_in_line == 0 {
        glyph_style_override(fill=red_fill)
      } else {
        glyph_style_override(fill=black_fill)
      }
    }),
  )
  let paths = graphic.all_compound_paths()
  inspect(paths.length(), content="3")
  inspect(paths[0].fill.unwrap().color.to_css_string(), content="#FF0000")
  inspect(paths[1].fill.unwrap().color.to_css_string(), content="#000000")
  inspect(paths[2].fill.unwrap().color.to_css_string(), content="#FF0000")
}

///|
test "text_with/alignment Left Center Right" {
  let left = text_with(text_test_font, "AA", size=100, align=Left)
  let center = text_with(text_test_font, "AA", size=100, align=Center)
  let right = text_with(text_test_font, "AA", size=100, align=Right)

  let left_bbox = left.bounding_box().unwrap()
  let center_bbox = center.bounding_box().unwrap()
  let right_bbox = right.bounding_box().unwrap()

  // Our test glyph width is 80 units at size=100 => 8.0 width each.
  // Two glyphs with advance 120 units => total span from 0 to 20.
  inspect(left_bbox.min.x, content="0")
  inspect(left_bbox.max.x, content="20")

  // Center alignment shifts by -(0+20)/2 = -10 => span [-10, 10].
  inspect(center_bbox.min.x, content="-10")
  inspect(center_bbox.max.x, content="10")

  // Right alignment shifts by -20 => span [-20, 0].
  inspect(right_bbox.min.x, content="-20")
  inspect(right_bbox.max.x, content="0")
}

///|
test "text_with/alignment with Skip marker" {
  let left = text_with(
    text_test_font,
    "*AA",
    size=100,
    align=Left,
    style_fn=text_with_style_fn(fn(ctx) {
      if ctx.grapheme == "*" {
        glyph_style_skip()
      } else {
        glyph_style_use_default()
      }
    }),
  )
  let center = text_with(
    text_test_font,
    "*AA",
    size=100,
    align=Center,
    style_fn=text_with_style_fn(fn(ctx) {
      if ctx.grapheme == "*" {
        glyph_style_skip()
      } else {
        glyph_style_use_default()
      }
    }),
  )
  let right = text_with(
    text_test_font,
    "*AA",
    size=100,
    align=Right,
    style_fn=text_with_style_fn(fn(ctx) {
      if ctx.grapheme == "*" {
        glyph_style_skip()
      } else {
        glyph_style_use_default()
      }
    }),
  )

  let left_bbox = left.bounding_box().unwrap()
  let center_bbox = center.bounding_box().unwrap()
  let right_bbox = right.bounding_box().unwrap()

  // Skipping '*' still advances by one horiz_adv_x (12.0 at size=100),
  // so rendered 'AA' spans [12, 32].
  inspect(left_bbox.min.x, content="12")
  inspect(left_bbox.max.x, content="32")

  // Center shift by -(12+32)/2 = -22 => span [-10, 10].
  inspect(center_bbox.min.x, content="-10")
  inspect(center_bbox.max.x, content="10")

  // Right shift by -32 => span [-20, 0].
  inspect(right_bbox.min.x, content="-20")
  inspect(right_bbox.max.x, content="0")
}

///|
test "text_with/context pen_position_scaled can drive translation" {
  let graphic = text_with(
    text_test_font,
    "AA",
    size=100,
    style_fn=text_with_style_fn(fn(ctx) {
      if ctx.grapheme_index == 1 {
        glyph_style_use_default(
          transform=glyph_transform(position=ctx.pen_position_scaled),
        )
      } else {
        glyph_style_use_default()
      }
    }),
  )
  let bbox = graphic.bounding_box().unwrap()
  inspect(bbox.min.x, content="0")
  inspect(bbox.max.x, content="32")
}

///|
test "text_with/glyph_transform scale" {
  let graphic = text_with(
    text_test_font,
    "A",
    size=100,
    style_fn=text_with_style_fn(fn(_ctx) {
      glyph_style_use_default(transform=glyph_transform(scale=vec2(2, 1)))
    }),
  )
  let bbox = graphic.bounding_box().unwrap()
  inspect(bbox.min.x, content="0")
  inspect(bbox.max.x, content="16")
}

///|
test "text_with/glyph_transform rotation" {
  let graphic = text_with(
    text_test_font,
    "A",
    size=100,
    style_fn=text_with_style_fn(fn(_ctx) {
      glyph_style_use_default(transform=glyph_transform(rotation=90))
    }),
  )
  let bbox = graphic.bounding_box().unwrap()
  let width = bbox.max.x - bbox.min.x
  let height = bbox.max.y - bbox.min.y
  inspect(width > 9.99 && width < 10.01, content="true")
  inspect(height > 7.99 && height < 8.01, content="true")
}

///|
test "text_with/glyph_transform affine_matrix" {
  let graphic = text_with(
    text_test_font,
    "A",
    size=100,
    style_fn=text_with_style_fn(fn(_ctx) {
      glyph_style_use_default(
        transform=glyph_transform(
          affine_matrix=AffineMatrix::new(a=1, d=1, tx=3, ty=4),
        ),
      )
    }),
  )
  let bbox = graphic.bounding_box().unwrap()
  inspect(bbox.min.x, content="3")
  inspect(bbox.max.x, content="11")
}
