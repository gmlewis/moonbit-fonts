///|
fn main {
  let font = @aaarghnormal.font

  // Use the new, unified `text` API and common color constants
  let hello = @draw.text(font~, text="Hello MoonBit!").with_style(
    fill=@draw.Color::blue().as_fill(),
  ) catch {
    _ => return
  }
  let sub = @draw.text(font~, text="Beautiful API", size=0.5)
    .with_style(fill=@draw.Color::red().as_fill())
    .translate(@geom.vec2(0, -0.6)) catch {
      _ => return
    }

  // Compose graphics using the new `+` operator!
  let graphic = hello + sub

  // Render the graphic to an SVG string
  let svg_str = @svg.from_graphic(graphic)
  println(svg_str)
}
