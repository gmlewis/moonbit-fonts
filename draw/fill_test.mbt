///|
test "@draw.Fill::new" {
  // Test default value (black color)
  let fill = @draw.Fill::new()
  inspect(fill, content="{color: {r: 0, g: 0, b: 0, a: 1}}")

  // Test with custom color (red)
  let red_fill = @draw.Fill::new(color=@draw.rgba(1, 0, 0, 1))
  inspect(red_fill, content="{color: {r: 1, g: 0, b: 0, a: 1}}")

  // Test with transparent color
  let transparent_fill = @draw.Fill::new(color=@draw.rgba(0, 0, 0, 0))
  inspect(transparent_fill, content="{color: {r: 0, g: 0, b: 0, a: 0}}")
}

///|
test "@draw.Fill::new/default-color" {
  inspect(@draw.Fill::new(), content="{color: {r: 0, g: 0, b: 0, a: 1}}")
}

///|
test "@draw.Fill::new/custom-color" {
  let custom_color = @draw.rgba(255.0 / 255, 100.0 / 255, 50.0 / 255, 1)
  inspect(
    @draw.Fill::new(color=custom_color),
    content="{color: {r: 1, g: 0.39215686274509803, b: 0.19607843137254902, a: 1}}",
  )
}

///|
test "@draw.Fill::new/boundary-tests" {
  let transparent_color = @draw.rgba(0, 0, 0, 0)
  let opaque_color = @draw.rgba(1, 1, 1, 1)
  inspect(
    @draw.Fill::new(color=transparent_color),
    content="{color: {r: 0, g: 0, b: 0, a: 0}}",
  )
  inspect(
    @draw.Fill::new(color=opaque_color),
    content="{color: {r: 1, g: 1, b: 1, a: 1}}",
  )
}

///|
test "@draw.fill/black" {
  let black = @draw.rgba(0, 0, 0, 1)
  let fill = @draw.fill(black)
  inspect(fill.color, content="{r: 0, g: 0, b: 0, a: 1}")
}

///|
test "@draw.fill/transparent" {
  let transparent = @draw.rgba(1, 1, 1, 0)
  let fill = @draw.fill(transparent)
  inspect(fill.color, content="{r: 1, g: 1, b: 1, a: 0}")
}

///|
test "@draw.fill/partial-transparent" {
  let semi_transparent = @draw.rgba(0.5, 0.5, 0.5, 0.5)
  let fill = @draw.fill(semi_transparent)
  inspect(fill.color, content="{r: 0.5, g: 0.5, b: 0.5, a: 0.5}")
}
