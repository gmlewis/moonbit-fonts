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
  let bbox = scene.bounding_box().unwrap()
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
  println(@svg.from_graphic(background + scene, y_up=false))
}
