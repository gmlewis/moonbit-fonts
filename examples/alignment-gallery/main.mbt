///|
fn main {
  let font = @aaarghnormal.font
  let text = "Align"
  let size = 1.0
  let alignments = [
    @geom.TopLeft,
    @geom.TopCenter,
    @geom.TopRight,
    @geom.CenterLeft,
    @geom.Center,
    @geom.CenterRight,
    @geom.BaselineLeft,
    @geom.BaselineCenter,
    @geom.BaselineRight,
    @geom.BottomLeft,
    @geom.BottomCenter,
    @geom.BottomRight,
  ]
  let mut scene = @draw.Graphic::Group(@draw.Group::new())
  for i, align in alignments {
    let x = (i % 3).to_double() * 4.0
    let y = (i / 3).to_double() * -2.0

    // Draw a small cross at the origin point for reference
    let cross = @draw.Path::from_points([
        @geom.vec2(x - 0.1, y),
        @geom.vec2(x + 0.1, y),
        @geom.vec2(x, y - 0.1),
        @geom.vec2(x, y + 0.1),
      ])
      .as_graphic()
      .with_style(
        stroke=@draw.Stroke::new(color=@draw.Color::red(), width=0.02),
      )
    let label = @draw.to_graphic(font, text, size~, alignment=align)
      .translate(@geom.vec2(x, y))
      .with_style(fill=@draw.Color::black().as_fill()) catch {
        _ => continue
      }
    let desc = @draw.text(font, "\{align}", size=0.2, align=Center).translate(
      @geom.vec2(x, y - 0.8),
    ) catch {
      _ => continue
    }
    scene = scene + cross + label + desc
  }
  println(@svg.from_graphic(scene))
}
