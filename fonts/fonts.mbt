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

/// `Font` represents an entire font.
pub struct Font {
  id : String
  horiz_adv_x : Double
  units_per_em : Double
  ascent : Double
  descent : Double
  glyphs : Map[String, Glyph]
}
