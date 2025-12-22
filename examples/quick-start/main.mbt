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

  // Render the final graphic to an SVG string with padding and a background

  let svg_str = @svg.from_graphic(
    graphic
    .with_margin(top=0.1, right=0.1, bottom=0.1, left=0.1)
    .with_background(@draw.Color::white()),
    y_up=false,
  )
  println(svg_str)
}
