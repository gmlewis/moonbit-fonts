///|
/// `Glyph` represents a single glyph within each `Font` and also represents
/// multiple glyphs combined together (for example after using `Font.gen_path`
/// and switching back and forth between `Glyph`s which are optimized for storage,
/// and `Path`s which are optimized for processing).
pub(all) struct Glyph {
  /// `char` is this glyph. (For "super-glyphs" this could be a long string.)
  char : String
  /// `horiz_adv_x` is the number of font units to advance for this glyph.
  /// Note that this field doesn't have any meaning when this struct represents
  /// multiple glyphs (a "super-glyph").
  horiz_adv_x : Double
  /// `gerber_lp` is a string of "d" (for "dark") and "c" (for "clear")
  /// representing the nature of each subsequent font curve subpath
  /// contained within `d`. Its length matches the number of
  /// subpaths in `d` (starting from each `M` path command).
  gerber_lp : String
  /// `d` is the SVG path in absolute coordinates for this glyph.
  /// It contains one or more subpaths (starting from `M` path commands).
  d : String
  /// These values represent the minimum bounding box of the glyph in native units.
  xmin : Double
  ymin : Double
  xmax : Double
  ymax : Double
} derive(Eq, FromJson, ToJson)

///|
pub impl Show for Glyph with output(self, logger) {
  let { char, horiz_adv_x, gerber_lp, d, xmin, ymin, xmax, ymax } = self
  logger.write_string(
    (
      $|{char: \{char.escape(quote=true)}, horiz_adv_x: \{horiz_adv_x}, gerber_lp: \{gerber_lp.escape(quote=true)}, d: \{d.escape(quote=true)}, xmin: \{xmin}, ymin: \{ymin}, xmax: \{xmax}, ymax: \{ymax}}
    ),
  )
}

///|
test "Glyph show interface" {
  let glyph = {
    char: "A",
    horiz_adv_x: 500.0,
    gerber_lp: "d",
    d: "M0 0L100 0L100 100Z",
    xmin: 0.0,
    ymin: 0.0,
    xmax: 100.0,
    ymax: 100.0,
  }
  inspect(
    glyph,
    content=(
      #|{char: "A", horiz_adv_x: 500, gerber_lp: "d", d: "M0 0L100 0L100 100Z", xmin: 0, ymin: 0, xmax: 100, ymax: 100}
    ),
  )
}
