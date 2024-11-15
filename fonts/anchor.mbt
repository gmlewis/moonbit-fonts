/// Anchor represents where to place the origin (0,0) of the glyph relative
/// to its minimum bounding box.
enum Anchor {
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
  RatioXY(Double, Double)
}
