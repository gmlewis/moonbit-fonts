/// Anchor represents where to place the origin (0,0) of the glyph relative
/// to its minimum bounding box.
pub(all) enum Anchor {
  /// Unchanged means that the SVG path will not be translated.
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
  /// RatioXY(x,y) places the origin a fraction (0..1) of the distance
  /// of the glyph's minimum bounding box along the x- and y-axes.
  /// Even though the other Anchor names describe the Y value first (e.g. "TopLeft"),
  /// note that X is first parameter since (x,y) is much easier to remember.
  ///
  /// For example, `TopRight` is identical to `Ratio(1,0)`.
  RatioXY(Double, Double)
} derive(Show, Eq)
