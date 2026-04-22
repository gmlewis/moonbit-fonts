///|
/// `Font` represents an entire font.
pub(all) struct Font {
  id : String
  horiz_adv_x : Double
  units_per_em : Double
  ascent : Double
  descent : Double
  glyphs : Map[String, Glyph]
} derive(Eq, FromJson, ToJson)

///|
pub impl Show for Font with output(self, logger) {
  let { id, horiz_adv_x, units_per_em, ascent, descent, glyphs } = self
  logger.write_string(
    (
      $|{id: \{id.escape(quote=true)}, horiz_adv_x: \{horiz_adv_x}, units_per_em: \{units_per_em}, ascent: \{ascent}, descent: \{descent}, glyphs: \{glyphs}}
    ),
  )
}

///|
test "Font show interface" {
  let font = {
    id: "test-font",
    horiz_adv_x: 1000.0,
    units_per_em: 1000.0,
    ascent: 800.0,
    descent: -200.0,
    glyphs: {
      "A": {
        char: "A",
        horiz_adv_x: 500.0,
        gerber_lp: "d",
        d: "M0 0L100 0L100 100Z",
        xmin: 0.0,
        ymin: 0.0,
        xmax: 100.0,
        ymax: 100.0,
      },
    },
  }
  inspect(
    font,
    content=(
      #|{id: "test-font", horiz_adv_x: 1000, units_per_em: 1000, ascent: 800, descent: -200, glyphs: {"A": {char: "A", horiz_adv_x: 500, gerber_lp: "d", d: "M0 0L100 0L100 100Z", xmin: 0, ymin: 0, xmax: 100, ymax: 100}}}
    ),
  )
}

///|
/// `FontError` represents an error that occurred during font processing.
pub(all) suberror FontError {
  FontError(String)
} derive(Eq)

///|
pub impl Show for FontError with output(self, logger) {
  let FontError(err) = self
  logger.write_string(
    (
      $|FontError(\{err.escape(quote=true)})
    ),
  )
}
