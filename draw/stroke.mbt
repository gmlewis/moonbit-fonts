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
/// `StrokeAlignment` defines where the stroke is placed relative to the path.
pub(all) enum StrokeAlignment {
  /// `Centered` places the stroke centered on the path.
  Centered
  /// `Inner` places the stroke inside the path.
  Inner
  /// `Outer` places the stroke outside the path.
  Outer
} derive(Show, Eq, FromJson, ToJson)

///|
/// `StrokeCap` defines the shape used at the end of open paths.
pub(all) enum StrokeCap {
  /// `Butt` ends the stroke exactly at the path end.
  Butt
  /// `Round` adds a semi-circle at the path end.
  Round
  /// `Square` adds a square at the path end.
  Square
} derive(Show, Eq, FromJson, ToJson)

///|
/// `StrokeJoin` defines the shape used at the corners of paths.
pub(all) enum StrokeJoin {
  /// `Miter` creates a sharp corner.
  Miter
  /// `Round` creates a rounded corner.
  Round
  /// `Bevel` creates a flattened corner.
  Bevel
} derive(Show, Eq, FromJson, ToJson)

///|
/// Stroke::new returns a new stroke style.
pub fn Stroke::new(
  color? : Color = rgba(0, 0, 0, 1),
  width? : Double = 0.1,
  alignment? : StrokeAlignment = Centered,
  cap? : StrokeCap = Butt,
  join? : StrokeJoin = Miter,
  miter_limit? : Double = 4,
) -> Stroke {
  { color, width, alignment, cap, join, miter_limit }
}

///|
/// stroke is a helper function.
pub fn stroke(
  color : Color,
  width? : Double = 0.1,
  alignment? : StrokeAlignment = Centered,
  cap? : StrokeCap = Butt,
  join? : StrokeJoin = Miter,
  miter_limit? : Double = 4,
) -> Stroke {
  Stroke::new(color~, width~, alignment~, cap~, join~, miter_limit~)
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
