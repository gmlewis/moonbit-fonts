test "@draw.Stroke::new" {
  // Test default values (black color with full opacity)
  let default_stroke = @draw.Stroke::new()
  inspect!(default_stroke.color.r, content="0")
  inspect!(default_stroke.color.g, content="0")
  inspect!(default_stroke.color.b, content="0")
  inspect!(default_stroke.color.a, content="1")

  // Test with custom color (red with half opacity)
  let custom_stroke = @draw.Stroke::new(color=@draw.rgba(1, 0, 0, 0.5))
  inspect!(custom_stroke.color.r, content="1")
  inspect!(custom_stroke.color.g, content="0")
  inspect!(custom_stroke.color.b, content="0")
  inspect!(custom_stroke.color.a, content="0.5")
}

test "@draw.Stroke::new/edge_cases" {
  // Test with extreme values (all components set to maximum)
  let max_stroke = @draw.Stroke::new(color=@draw.rgba(1, 1, 1, 1))
  inspect!(max_stroke.color.r, content="1")
  inspect!(max_stroke.color.g, content="1")
  inspect!(max_stroke.color.b, content="1")
  inspect!(max_stroke.color.a, content="1")

  // Test with zero values (transparent black)
  let zero_stroke = @draw.Stroke::new(color=@draw.rgba(0, 0, 0, 0))
  inspect!(zero_stroke.color.r, content="0")
  inspect!(zero_stroke.color.g, content="0")
  inspect!(zero_stroke.color.b, content="0")
  inspect!(zero_stroke.color.a, content="0")
}

test "@draw.Stroke::new" {
  let color1 = @draw.rgba(0.5, 0.4, 0.3, 1)
  let stroke1 = @draw.Stroke::new(color=color1)
  inspect!(stroke1.color, content="{r: 0.5, g: 0.4, b: 0.3, a: 1}")
  let color2 = @draw.rgba(0.1, 0.2, 0.3, 0.4)
  let stroke2 = @draw.Stroke::new(color=color2)
  inspect!(stroke2.color, content="{r: 0.1, g: 0.2, b: 0.3, a: 0.4}")
  let color3 = @draw.rgba(1, 1, 1, 1)
  let stroke3 = @draw.Stroke::new(color=color3)
  inspect!(stroke3.color, content="{r: 1, g: 1, b: 1, a: 1}")
}

test "@draw.Stroke::new/boundary" {
  let color1 = @draw.rgba(0, 0, 0, 0)
  let stroke1 = @draw.Stroke::new(color=color1)
  inspect!(stroke1.color, content="{r: 0, g: 0, b: 0, a: 0}")
  let color2 = @draw.rgba(0, 0, 0, 1)
  let stroke2 = @draw.Stroke::new(color=color2)
  inspect!(stroke2.color, content="{r: 0, g: 0, b: 0, a: 1}")
  let color3 = @draw.rgba(1, 0, 0, 1)
  let stroke3 = @draw.Stroke::new(color=color3)
  inspect!(stroke3.color, content="{r: 1, g: 0, b: 0, a: 1}")
}

test "@draw.Stroke::new" {
  let color = @draw.rgba(-1, 2, -3, 4) // Invalid color values
  inspect!(
    @draw.Stroke::new(color~),
    content="{color: {r: -1, g: 2, b: -3, a: 4}, hairline: true, width: 0.1, alignment: Centered, cap: Butt, join: Miter, miter_limit: 4}",
  )
}

test "@draw.stroke/basic" {
  let black = @draw.rgba(0, 0, 0, 1)
  let stroke = @draw.stroke(black)
  inspect!(
    stroke,
    content="{color: {r: 0, g: 0, b: 0, a: 1}, hairline: true, width: 0.1, alignment: Centered, cap: Butt, join: Miter, miter_limit: 4}",
  )
}

test "@draw.stroke/transparent" {
  let transparent = @draw.rgba(1, 1, 1, 0)
  let stroke = @draw.stroke(transparent)
  inspect!(
    stroke,
    content="{color: {r: 1, g: 1, b: 1, a: 0}, hairline: true, width: 0.1, alignment: Centered, cap: Butt, join: Miter, miter_limit: 4}",
  )
}

test "@draw.stroke/partial-transparent" {
  let semi_transparent = @draw.rgba(0.5, 0.5, 0.5, 0.5)
  let stroke = @draw.stroke(semi_transparent)
  inspect!(
    stroke,
    content="{color: {r: 0.5, g: 0.5, b: 0.5, a: 0.5}, hairline: true, width: 0.1, alignment: Centered, cap: Butt, join: Miter, miter_limit: 4}",
  )
}

test "@draw.clone/stroke-equality" {
  let original = @draw.Stroke::new(color=@draw.rgba(1, 0, 0, 1))
  let cloned = original.clone()
  inspect!(cloned, content=original.to_string())
}

test "@draw.clone/stroke-independence" {
  let original = @draw.Stroke::new(color=@draw.rgba(1, 0, 0, 1))
  let cloned = original.clone()
  let _ = cloned.color.set(0, 1, 0, 1)
  // Original should remain unchanged
  inspect!(original.color, content="{r: 1, g: 0, b: 0, a: 1}")
}

test "@draw.clone/zero-opacity" {
  let original = @draw.Stroke::new(color=@draw.rgba(1, 1, 1, 0))
  let cloned = original.clone()
  inspect!(cloned, content=original.to_string())
}
