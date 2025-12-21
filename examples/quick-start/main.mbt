///|
fn main {
  // Use the font to create a graphic
  let font = @aaarghnormal.font
  let text = "Hello MoonBit!"
  let graphic = @draw.to_graphic(font, text, size=72.0) catch { _ => return }

  // Render the graphic to an SVG string
  let svg_str = @svg.from_graphic(graphic)
  println(svg_str)
}
