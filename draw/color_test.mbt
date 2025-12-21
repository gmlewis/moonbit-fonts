///|
test "Color::new/default-values" {
  let color = Color::new()
  inspect(color, content="{r: 0, g: 0, b: 0, a: 1}")
}

///|
test "Color::new/custom-values" {
  let color = Color::new(r=0.5, g=0.7, b=0.9, a=0.3)
  inspect(color, content="{r: 0.5, g: 0.7, b: 0.9, a: 0.3}")
}

///|
test "Color::new/boundary-values" {
  let min = Color::new(r=0, g=0, b=0, a=0)
  inspect(min, content="{r: 0, g: 0, b: 0, a: 0}")
  let max = Color::new(r=1, g=1, b=1, a=1)
  inspect(max, content="{r: 1, g: 1, b: 1, a: 1}")
}

///|
test "rgba/standard" {
  let c1 = rgba(1.0, 0.0, 0.0, 1.0) // red
  let c2 = rgba(0.0, 1.0, 0.0, 0.5) // semi-transparent green
  let c3 = rgba(0.0, 0.0, 1.0, 0.0) // transparent blue
  inspect(c1, content="{r: 1, g: 0, b: 0, a: 1}")
  inspect(c2, content="{r: 0, g: 1, b: 0, a: 0.5}")
  inspect(c3, content="{r: 0, g: 0, b: 1, a: 0}")
}

///|
test "rgba/edge-cases" {
  let c1 = rgba(0.0, 0.0, 0.0, 0.0) // fully transparent black
  let c2 = rgba(1.0, 1.0, 1.0, 1.0) // fully opaque white
  inspect(c1, content="{r: 0, g: 0, b: 0, a: 0}")
  inspect(c2, content="{r: 1, g: 1, b: 1, a: 1}")
}

///|
test "rgba/out-of-range" {
  let c1 = rgba(-1.0, 2.0, 1.5, -0.5) // values outside normal 0-1 range
  inspect(c1, content="{r: -1, g: 2, b: 1.5, a: -0.5}")
}

///|
test "rgba/basic_functionality" {
  inspect(rgba(1.0, 0.0, 0.0, 1.0), content="{r: 1, g: 0, b: 0, a: 1}")
  inspect(rgba(0.0, 1.0, 0.0, 1.0), content="{r: 0, g: 1, b: 0, a: 1}")
  inspect(rgba(0.0, 0.0, 1.0, 1.0), content="{r: 0, g: 0, b: 1, a: 1}")
}

///|
test "rgba/boundaries" {
  inspect(rgba(0.0, 0.0, 0.0, 0.0), content="{r: 0, g: 0, b: 0, a: 0}")
  inspect(rgba(1.0, 1.0, 1.0, 1.0), content="{r: 1, g: 1, b: 1, a: 1}")
  inspect(rgba(1.0, 0.5, 0.0, 0.5), content="{r: 1, g: 0.5, b: 0, a: 0.5}")
}

///|
test "panic rgba/invalid_values" {
  inspect(rgba(-0.1, -0.1, -0.1, -0.1), content="")
}

///|
test "Color::from_hsva/basic_functionality" {
  let color1 = Color::from_hsva(0.0, 1.0, 1.0, 1.0)
  let color2 = Color::from_hsva(0.5, 1.0, 1.0, 1.0)
  let color3 = Color::from_hsva(1.0, 1.0, 1.0, 1.0)
  inspect(color1, content="{r: 1, g: 0, b: 0, a: 1}")
  inspect(color2, content="{r: 0, g: 1, b: 1, a: 1}")
  inspect(color3, content="{r: 1, g: 0, b: 1, a: 1}")
}

///|
test "Color::from_hsva/boundary_values" {
  let color1 = Color::from_hsva(1.0, 0.0, 0.0, 0.0)
  let color2 = Color::from_hsva(0.0, 0.0, 0.0, 0.0)
  let color3 = Color::from_hsva(1.0, 1.0, 1.0, 1.0)
  inspect(color1, content="{r: 0, g: 0, b: 0, a: 0}")
  inspect(color2, content="{r: 0, g: 0, b: 0, a: 0}")
  inspect(color3, content="{r: 1, g: 0, b: 1, a: 1}")
}

///|
test "panic Color::from_hsva/invalid_hue" {
  inspect(Color::from_hsva(-0.1, 0.5, 0.5, 0.5), content="")
}

///|
test "Color::from_rgb8_number/black 1" {
  let black = Color::from_rgb8_number(0U)
  inspect(black.r, content="0")
  inspect(black.g, content="0")
  inspect(black.b, content="0")
  inspect(black.a, content="1")
}

///|
test "Color::from_rgb8_number/white 1" {
  let white = Color::from_rgb8_number(0xffffffU)
  inspect(white.r, content="1")
  inspect(white.g, content="1")
  inspect(white.b, content="1")
  inspect(white.a, content="1")
}

///|
test "Color::from_rgb8_number/primary_colors" {
  let red = Color::from_rgb8_number(0xff0000U)
  inspect(red.r, content="1")
  inspect(red.g, content="0")
  inspect(red.b, content="0")
  inspect(red.a, content="1")
  let green = Color::from_rgb8_number(0x00ff00U)
  inspect(green.r, content="0")
  inspect(green.g, content="1")
  inspect(green.b, content="0")
  inspect(green.a, content="1")
  let blue = Color::from_rgb8_number(0x0000ffU)
  inspect(blue.r, content="0")
  inspect(blue.g, content="0")
  inspect(blue.b, content="1")
  inspect(blue.a, content="1")
}

///|
test "Color::from_rgb8_number/black 2" {
  let color = Color::from_rgb8_number(0x000000)
  inspect(color, content="{r: 0, g: 0, b: 0, a: 1}")
}

///|
test "Color::from_rgb8_number/white 2" {
  let color = Color::from_rgb8_number(0xFFFFFF)
  inspect(color, content="{r: 1, g: 1, b: 1, a: 1}")
}

///|
test "Color::from_rgb8_number/red" {
  let color = Color::from_rgb8_number(0xFF0000)
  inspect(color, content="{r: 1, g: 0, b: 0, a: 1}")
}

///|
test "Color::from_rgb8_number/green" {
  let color = Color::from_rgb8_number(0x00FF00)
  inspect(color, content="{r: 0, g: 1, b: 0, a: 1}")
}

///|
test "Color::from_rgb8_number/blue" {
  let color = Color::from_rgb8_number(0x0000FF)
  inspect(color, content="{r: 0, g: 0, b: 1, a: 1}")
} // Test basic color mixing with t=0.5

///|
test "Color::mix" {
  let c1 = Color::new(r=0.0, g=0.0, b=0.0, a=1.0)
  let c2 = Color::new(r=1.0, g=1.0, b=1.0, a=1.0)
  let result = c1.mix(c2, 0.5)
  inspect(result.r, content="0.5")
  inspect(result.g, content="0.5")
  inspect(result.b, content="0.5")
  inspect(result.a, content="1")
}

// Test mixing with t=0 (should return the first color)

///|
test "Color::mix/t_zero" {
  let c1 = Color::new(r=0.2, g=0.3, b=0.4, a=0.5)
  let c2 = Color::new(r=0.6, g=0.7, b=0.8, a=0.9)
  let result = c1.mix(c2, 0.0)
  inspect(result.r, content="0.2")
  inspect(result.g, content="0.3")
  inspect(result.b, content="0.4")
  inspect(result.a, content="0.5")
}

// Test mixing with t=1 (should return the second color)

///|
test "Color::mix/t_one" {
  let c1 = Color::new(r=0.2, g=0.3, b=0.4, a=0.5)
  let c2 = Color::new(r=0.6, g=0.7, b=0.8, a=0.9)
  let result = c1.mix(c2, 1.0)
  inspect(result.r, content="0.6")
  inspect(result.g, content="0.7")
  inspect(result.b, content="0.8")
  inspect(result.a, content="0.9")
}

///|
test "luminance/zero_color" {
  let color = rgba(0.0, 0.0, 0.0, 1.0)
  inspect(color.luminance(), content="0")
}

///|
test "luminance/one_color" {
  let color = rgba(1.0, 1.0, 1.0, 1.0)
  inspect(color.luminance(), content="1")
}

///|
test "luminance/mixed_color" {
  let color = rgba(0.5, 0.2, 0.7, 1.0)
  inspect(color.luminance(), content="0.29988")
}

///|
test "Color::to_css_string/opaque" {
  let color = Color::new(r=1.0, g=0.0, b=0.0, a=1.0)
  inspect(color.to_css_string(), content="#FF0000")
}

///|
test "Color::to_css_string/transparent" {
  let color = Color::new(r=0.0, g=1.0, b=0.0, a=0.5)
  inspect(color.to_css_string(), content="rgba(0,255,0,0.5)")
}

///|
test "Color::to_css_string/fully-transparent" {
  let color = Color::new(r=0.0, g=0.0, b=1.0, a=0.0)
  inspect(color.to_css_string(), content="rgba(0,0,255,0)")
}

///|
test "to_css_string/hex_color" {
  let color = Color::new(r=1.0, g=0.0, b=0.0, a=1.0)
  inspect(color.to_css_string(), content="#FF0000")
}

///|
test "to_css_string/rgba_color" {
  let color = Color::new(r=0.5, g=0.5, b=0.5, a=0.5)
  let got = color.to_css_string()
  inspect(got, content="rgba(128,128,128,0.5)")
}

///|
test "to_css_string/transparent_color" {
  let color = Color::new(r=0.0, g=0.0, b=0.0, a=0.0)
  inspect(color.to_css_string(), content="rgba(0,0,0,0)")
}

///|
test "Color::to_css_hex_string" {
  // Test basic color conversion
  let color1 = Color::new(r=0.5, g=0.25, b=0.75)
  inspect(color1.to_css_hex_string(), content="#8040BF")

  // Test black color (all components at 0)
  let color2 = Color::new(r=0.0, g=0.0, b=0.0)
  inspect(color2.to_css_hex_string(), content="#000000")

  // Test white color (all components at 1.0)
  let color3 = Color::new(r=1.0, g=1.0, b=1.0)
  inspect(color3.to_css_hex_string(), content="#FFFFFF")
} // Test case for pure white color

///|
test "Color::to_css_hex_string/white_color" {
  let white_color = Color::new(r=1.0, g=1.0, b=1.0, a=1.0)
  inspect(white_color.to_css_hex_string(), content="#FFFFFF")
}

// Test case for pure black color

///|
test "Color::to_css_hex_string/black_color" {
  let black_color = Color::new(r=0.0, g=0.0, b=0.0, a=1.0)
  inspect(black_color.to_css_hex_string(), content="#000000")
}

// Test case for color with mixed components

///|
test "Color::to_css_hex_string/mixed_color" {
  let mixed_color = Color::new(r=0.5, g=0.25, b=0.75, a=1.0)
  let got = mixed_color.to_css_hex_string()
  inspect(got, content="#8040BF")
}

///|
test "Color::to_css_rgba_string" {
  // Test normal RGB values with full opacity
  let c1 = Color::new(r=1.0, g=0.0, b=0.0, a=1.0)
  inspect(c1.to_css_rgba_string(), content="rgba(255,0,0,1)")

  // Test normal RGB values with partial opacity
  let c2 = Color::new(r=0.5, g=0.5, b=0.5, a=0.5)
  inspect(c2.to_css_rgba_string(), content="rgba(128,128,128,0.5)")
}

///|
test "Color::to_css_rgba_string/boundary" {
  // Test boundary values (0.0 and 1.0)
  let c1 = Color::new(r=0.0, g=0.0, b=0.0, a=0.0)
  inspect(c1.to_css_rgba_string(), content="rgba(0,0,0,0)")
  let c2 = Color::new(r=1.0, g=1.0, b=1.0, a=1.0)
  inspect(c2.to_css_rgba_string(), content="rgba(255,255,255,1)")
}

///|
test "Color::to_css_rgba_string/out-of-range" {
  // Test values outside the normal range
  let c1 = Color::new(r=2.0, g=-1.0, b=1.5, a=3.0)
  inspect(c1.to_css_rgba_string(), content="rgba(255,0,255,1)")
}

///|
test "Color::to_rgb8_number/black" {
  let black = Color::new(r=0.0, g=0.0, b=0.0)
  inspect(black.to_rgb8_number(), content="0")
}

///|
test "Color::to_rgb8_number/white" {
  let white = Color::new(r=1.0, g=1.0, b=1.0)
  inspect(white.to_rgb8_number(), content="16777215") // 0xFFFFFF
}

///|
test "Color::to_rgb8_number/primary-colors" {
  let red = Color::new(r=1.0, g=0.0, b=0.0)
  let green = Color::new(r=0.0, g=1.0, b=0.0)
  let blue = Color::new(r=0.0, g=0.0, b=1.0)
  inspect(red.to_rgb8_number(), content="16711680") // 0xFF0000
  inspect(green.to_rgb8_number(), content="65280") // 0x00FF00
  inspect(blue.to_rgb8_number(), content="255") // 0x0000FF
}

///|
test "to_rgb8_number/basic_case" {
  let result = rgba(1.0, 0.5, 0.0, 1.0).to_rgb8_number()
  inspect(result, content="16744448") // Expected: 0xff7f00 which is 16744192 in decimal
}

///|
test "to_rgb8_number/lower_boundaries" {
  let result = rgba(0.0, 0.0, 0.0, 1.0).to_rgb8_number()
  inspect(result, content="0") // Expected: 0x000000 which is 0 in decimal
}

///|
test "to_rgb8_number/upper_boundaries" {
  let result = rgba(1.0, 1.0, 1.0, 1.0).to_rgb8_number()
  inspect(result, content="16777215") // Expected: 0xffffff which is 16777215 in decimal
}

///|
test "Color::to_hsva/primary-secondary" {
  // Red (1,0,0,1) should convert to (0,1,1,1)
  let red = Color::new(r=1.0, g=0.0, b=0.0, a=1.0)
  inspect(red.to_hsva(), content="[0, 1, 1, 1]")

  // Green (0,1,0,1) should convert to (1/3,1,1,1)
  let green = Color::new(r=0.0, g=1.0, b=0.0, a=1.0)
  inspect(green.to_hsva(), content="[0.3333333333333333, 1, 1, 1]")

  // Blue (0,0,1,1) should convert to (2/3,1,1,1)
  let blue = Color::new(r=0.0, g=0.0, b=1.0, a=1.0)
  inspect(blue.to_hsva(), content="[0.6666666666666666, 1, 1, 1]")
}

///|
test "Color::to_hsva/black 1" {
  let black = Color::new(r=0.0, g=0.0, b=0.0, a=1.0)
  // Black should have 0 saturation and value
  inspect(black.to_hsva(), content="[0, 0, 0, 1]")
}

///|
test "Color::to_hsva/white 1" {
  let white = Color::new(r=1.0, g=1.0, b=1.0, a=1.0)
  // White should have 0 saturation but maximum value
  inspect(white.to_hsva(), content="[0, 0, 1, 1]")
}

///|
test "Color::to_hsva/black 2" {
  let color = Color::new(r=0, g=0, b=0, a=1)
  let hsva = color.to_hsva()
  inspect(hsva, content="[0, 0, 0, 1]")
}

///|
test "Color::to_hsva/white 2" {
  let color = Color::new(r=1, g=1, b=1, a=1)
  let hsva = color.to_hsva()
  inspect(hsva, content="[0, 0, 1, 1]")
}

///|
test "Color::to_hsva/red" {
  let color = Color::new(r=1, g=0, b=0, a=1)
  let hsva = color.to_hsva()
  inspect(hsva, content="[0, 1, 1, 1]")
}
