///|
/// `Stroke` defines a stroke style.
pub(all) struct Stroke {
  mut color : Color
  mut width : Double
  mut alignment : StrokeAlignment
  mut cap : StrokeCap
  mut join : StrokeJoin
  mut miter_limit : Double
} derive(Eq, FromJson, ToJson)

///|
pub impl Show for Stroke with output(self, logger) {
  let { color, width, alignment, cap, join, miter_limit } = self
  logger.write_string(
    (
      $|{color: \{color}, width: \{width}, alignment: \{alignment}, cap: \{cap}, join: \{join}, miter_limit: \{miter_limit}}
    ),
  )
}

///|
test "Stroke show interface" {
  let stroke = Stroke::new(color=rgba(0, 1, 0, 1), width=2.0)
  inspect(
    stroke,
    content=(
      #|{color: {r: 0, g: 1, b: 0, a: 1}, width: 2, alignment: Centered, cap: Butt, join: Miter, miter_limit: 4}
    ),
  )
}

///|
/// `StrokeAlignment` defines where the stroke is placed relative to the path.
pub(all) enum StrokeAlignment {
  /// `Centered` places the stroke centered on the path.
  Centered
  /// `Inner` places the stroke inside the path.
  Inner
  /// `Outer` places the stroke outside the path.
  Outer
} derive(Eq, FromJson, ToJson)

///|
pub impl Show for StrokeAlignment with output(self, logger) {
  match self {
    Centered =>
      logger.write_string(
        (
          $|Centered
        ),
      )
    Inner =>
      logger.write_string(
        (
          $|Inner
        ),
      )
    Outer =>
      logger.write_string(
        (
          $|Outer
        ),
      )
  }
}

///|
test "StrokeAlignment show interface" {
  inspect(
    Centered,
    content=(
      #|Centered
    ),
  )
  inspect(
    Inner,
    content=(
      #|Inner
    ),
  )
  inspect(
    Outer,
    content=(
      #|Outer
    ),
  )
}

///|
/// `StrokeCap` defines the shape used at the end of open paths.
pub(all) enum StrokeCap {
  /// `Butt` ends the stroke exactly at the path end.
  Butt
  /// `Round` adds a semi-circle at the path end.
  Round
  /// `Square` adds a square at the path end.
  Square
} derive(Eq, FromJson, ToJson)

///|
pub impl Show for StrokeCap with output(self, logger) {
  match self {
    Butt =>
      logger.write_string(
        (
          $|Butt
        ),
      )
    Round =>
      logger.write_string(
        (
          $|Round
        ),
      )
    Square =>
      logger.write_string(
        (
          $|Square
        ),
      )
  }
}

///|
test "StrokeCap show interface" {
  inspect(
    Butt,
    content=(
      #|Butt
    ),
  )
  inspect(
    StrokeCap::Round,
    content=(
      #|Round
    ),
  )
  inspect(
    Square,
    content=(
      #|Square
    ),
  )
}

///|
/// `StrokeJoin` defines the shape used at the corners of paths.
pub(all) enum StrokeJoin {
  /// `Miter` creates a sharp corner.
  Miter
  /// `Round` creates a rounded corner.
  Round
  /// `Bevel` creates a flattened corner.
  Bevel
} derive(Eq, FromJson, ToJson)

///|
pub impl Show for StrokeJoin with output(self, logger) {
  match self {
    Miter =>
      logger.write_string(
        (
          $|Miter
        ),
      )
    Round =>
      logger.write_string(
        (
          $|Round
        ),
      )
    Bevel =>
      logger.write_string(
        (
          $|Bevel
        ),
      )
  }
}

///|
test "StrokeJoin show interface" {
  inspect(
    Miter,
    content=(
      #|Miter
    ),
  )
  inspect(
    StrokeJoin::Round,
    content=(
      #|Round
    ),
  )
  inspect(
    Bevel,
    content=(
      #|Bevel
    ),
  )
}

///|
/// `Stroke::new` returns a new stroke style.
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
/// `stroke` is a helper function.
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
/// `clone` returns a new copy of this `Stroke`.
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
