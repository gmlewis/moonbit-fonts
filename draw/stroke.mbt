/// Stroke defines a stroke style.
pub(all) struct Stroke {
  mut color : Color
  mut hairline : Bool
  mut width : Double
  mut alignment : StrokeAlignment
  mut cap : StrokeCap
  mut join : StrokeJoin
  mut miter_limit : Int
} derive(Show, Eq)

pub(all) enum StrokeAlignment {
  Centered
  Inner
  Outer
} derive(Show, Eq)

pub(all) enum StrokeCap {
  Butt
  Round
  Square
} derive(Show, Eq)

pub(all) enum StrokeJoin {
  Miter
  Round
  Bevel
} derive(Show, Eq)

/// Stroke::new returns a new stroke style.
pub fn Stroke::new(
  color~ : Color = color(0, 0, 0, 1),
  hairline~ : Bool = true,
  width~ : Double = 0.1,
  alignment~ : StrokeAlignment = Centered,
  cap~ : StrokeCap = Butt,
  join~ : StrokeJoin = Miter,
  miter_limit~ : Int = 4
) -> Stroke {
  { color, hairline, width, alignment, cap, join, miter_limit }
}

/// stroke is a helper function.
pub fn stroke(color : Color) -> Stroke {
  Stroke::new(color~)
}

/// clone returns a new copy of this Stroke.
pub fn clone(self : Stroke) -> Stroke {
  Stroke::new(
    color=self.color.clone(),
    hairline=self.hairline,
    width=self.width,
    alignment=self.alignment,
    cap=self.cap,
    join=self.join,
    miter_limit=self.miter_limit,
  )
}
