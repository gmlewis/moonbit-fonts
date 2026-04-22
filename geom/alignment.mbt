///|
/// `Alignment` represents where to place the origin (0,0) of the glyph relative
/// to its minimum bounding box.
pub(all) enum Alignment {
  /// `Unchanged` means that the SVG path will not be translated.
  Unchanged
  TopLeft
  TopCenter
  TopRight
  CenterLeft
  Center
  CenterRight
  BaselineLeft
  BaselineCenter
  BaselineRight
  BottomLeft
  BottomCenter
  BottomRight
  /// `RatioXY(x,y)` places the origin a fraction (0..1) of the distance
  /// of the glyph's minimum bounding box along the x- and y-axes.
  /// Even though the other `Alignment` names describe the Y value first (e.g. "TopLeft"),
  /// note that X is first parameter since (x,y) is much easier to remember.
  ///
  /// For example, `TopRight` is identical to `RatioXY(1,0)`.
  RatioXY(Double, Double)
} derive(Eq)

///|
pub impl Show for Alignment with output(self, logger) {
  match self {
    Unchanged =>
      logger.write_string(
        (
          $|Unchanged
        ),
      )
    TopLeft =>
      logger.write_string(
        (
          $|TopLeft
        ),
      )
    TopCenter =>
      logger.write_string(
        (
          $|TopCenter
        ),
      )
    TopRight =>
      logger.write_string(
        (
          $|TopRight
        ),
      )
    CenterLeft =>
      logger.write_string(
        (
          $|CenterLeft
        ),
      )
    Center =>
      logger.write_string(
        (
          $|Center
        ),
      )
    CenterRight =>
      logger.write_string(
        (
          $|CenterRight
        ),
      )
    BaselineLeft =>
      logger.write_string(
        (
          $|BaselineLeft
        ),
      )
    BaselineCenter =>
      logger.write_string(
        (
          $|BaselineCenter
        ),
      )
    BaselineRight =>
      logger.write_string(
        (
          $|BaselineRight
        ),
      )
    BottomLeft =>
      logger.write_string(
        (
          $|BottomLeft
        ),
      )
    BottomCenter =>
      logger.write_string(
        (
          $|BottomCenter
        ),
      )
    BottomRight =>
      logger.write_string(
        (
          $|BottomRight
        ),
      )
    RatioXY(x, y) =>
      logger.write_string(
        (
          $|RatioXY(\{x}, \{y})
        ),
      )
  }
}

///|
test "Alignment show interface" {
  inspect(
    Unchanged,
    content=(
      #|Unchanged
    ),
  )
  inspect(
    TopLeft,
    content=(
      #|TopLeft
    ),
  )
  inspect(
    Center,
    content=(
      #|Center
    ),
  )
  inspect(
    RatioXY(0.5, 0.5),
    content=(
      #|RatioXY(0.5, 0.5)
    ),
  )
}
