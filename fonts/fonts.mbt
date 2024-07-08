/// `Glyph` represents a single glyph.
pub struct Glyph {
  char : String
  horiz_adv_x : Int
  d : String
  xmin : Int
  ymin : Int
  xmax : Int
  ymax : Int
}

/// `Font` represents an entire font.
pub struct Font {
  id : String
  horiz_adv_x : Int
  units_per_em : Int
  ascent : Int
  descent : Int
  glyphs : Map[String, Glyph]
}
