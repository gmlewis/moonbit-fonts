///|
/// Stroke defines a stroke style.
pub(all) struct Stroke {
  mut color : Color
  mut width : Double
  mut alignment : StrokeAlignment
  mut cap : StrokeCap
  mut join : StrokeJoin
  mut miter_limit : Double
} derive(Show, Eq, FromJson, ToJson)

///|
pub(all) enum StrokeAlignment {
  Centered
  Inner
  Outer
} derive(Show, Eq, FromJson(style="flat"), ToJson(style="flat"))

///|
pub(all) enum StrokeCap {
  Butt
  Round
  Square
} derive(Show, Eq, FromJson(style="flat"), ToJson(style="flat"))

///|
pub(all) enum StrokeJoin {
  Miter
  Round
  Bevel
} derive(Show, Eq, FromJson(style="flat"), ToJson(style="flat"))

///|
/// Stroke::new returns a new stroke style.
pub fn Stroke::new(
  color~ : Color = rgba(0, 0, 0, 1),
  width~ : Double = 0.1,
  alignment~ : StrokeAlignment = Centered,
  cap~ : StrokeCap = Butt,
  join~ : StrokeJoin = Miter,
  miter_limit~ : Double = 4,
) -> Stroke {
  { color, width, alignment, cap, join, miter_limit }
}

///|
/// stroke is a helper function.
pub fn stroke(color : Color) -> Stroke {
  Stroke::new(color~)
}

///|
/// clone returns a new copy of this Stroke.
pub impl Clonable for Stroke with clone(self) {
  Stroke::new(
    color=self.color.clone(),
    width=self.width,
    alignment=self.alignment,
    cap=self.cap,
    join=self.join,
    miter_limit=self.miter_limit,
  )
}
