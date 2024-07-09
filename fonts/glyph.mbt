/// `Glyph` represents a single glyph.
pub struct Glyph {
  char : String
  horiz_adv_x : Double
  d : String
  xmin : Double
  ymin : Double
  xmax : Double
  ymax : Double
}

/// `translate` translates (moves) a glyph path by the provided offsets.
pub fn translate(self : Glyph, x : Double, y : Double) -> String {
  ""
}
