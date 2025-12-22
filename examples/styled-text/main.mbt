///|
fn main {
  let font = @baloo.font
  let t1 = @draw.text(font, "Filled Only").with_style(
    fill=@draw.Fill::from_string("blue"),
  ) catch {
    _ => return
  }
  let t2 = @draw.text(font, "Stroked Only")
    .translate(@geom.vec2(0, 1.2))
    .with_style(stroke=@draw.Stroke::new(color=@draw.Color::red(), width=0.05)) catch {
      _ => return
    }
  let t3 = @draw.text(font, "Both")
    .translate(@geom.vec2(0, 2.4))
    .with_style(
      fill=@draw.Color::green().as_fill(),
      stroke=@draw.Stroke::new(color=@draw.Color::black(), width=0.02),
    ) catch {
      _ => return
    }
  let scene = t1 + t2 + t3
  println(
    @svg.from_graphic(
      scene
      .with_margin(top=0.1, right=0.1, bottom=0.1, left=0.1)
      .with_background(@draw.Color::white()),
      y_up=false,
    ),
  )
}
