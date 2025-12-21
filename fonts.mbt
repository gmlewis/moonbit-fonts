///|
/// `Font` represents an entire font.
pub(all) struct Font {
  id : String
  horiz_adv_x : Double
  units_per_em : Double
  ascent : Double
  descent : Double
  glyphs : Map[String, Glyph]
} derive(Show, Eq, FromJson, ToJson)

///|
/// `FontError` represents an error that occured during font processing.
pub(all) suberror FontError String derive(Show, Eq)
