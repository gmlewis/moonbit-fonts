/// `Font` represents an entire font.
pub struct Font {
  id : String
  horiz_adv_x : Double
  units_per_em : Double
  ascent : Double
  descent : Double
  glyphs : Map[String, Glyph]
} derive(Show, Eq)
