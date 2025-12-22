///|
fn main {
  let font = @aaarghnormal.font

  // Use the new, unified `text` API and common color constants
  let hello = @draw.text(font, "Hello MoonBit!").with_style(
    fill=@draw.Color::blue().as_fill(),
  ) catch {
    _ => return
  }
  let sub = @draw.text(font, "Composable Vector Graphics", size=0.5)
    .with_style(fill=@draw.Color::red().as_fill())
    .translate(@geom.vec2(0, 0.8)) catch {
      _ => return
    }

  // Compose graphics using the new `+` operator!
  let graphic = hello + sub

  // Add a white background
  let bbox = graphic.bounding_box().unwrap()
  bbox.expand_scalar(0.1)
  let background = @draw.Path::from_points(
      [
        @geom.vec2(bbox.min.x, bbox.min.y),
        @geom.vec2(bbox.max.x, bbox.min.y),
        @geom.vec2(bbox.max.x, bbox.max.y),
        @geom.vec2(bbox.min.x, bbox.max.y),
      ],
      closed=true,
    )
    .as_graphic()
    .with_style(fill=@draw.Color::white().as_fill())

  // Render the final graphic to an SVG string
  let svg_str = @svg.from_graphic(background + graphic, y_up=false)
  println(svg_str)
}
