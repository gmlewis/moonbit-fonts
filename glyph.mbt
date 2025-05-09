///|
/// `Glyph` represents a single glyph within each `Font` and also represents
/// multiple glyphs combined together (for example after using `Font.gen_path`
/// and switching back and forth between `Glyphs` which are optimized for storage,
/// and `Paths` which are optimized for processing).
pub(all) struct Glyph {
  /// `char` is this glyph. (For "super-glpyhs" this could be a long string.)
  char : String
  /// `horiz_adv_x` is the number of font units to advance for this glyph.
  /// Note that this field doesn't have any meaning when this struct represents
  /// multiple glyphs (a "super-glyph").
  horiz_adv_x : Double
  /// `gerber_lp` is a string of "d" (for "dark") and "c" (for "clear")
  /// representing the nature of each subsequent font curve subpath
  /// contained within `d`. Its length matches the number of
  /// subpaths in `d` (starting from each 'M' path command).
  gerber_lp : String
  /// `d` is the SVG path in absolute coordinates for this glyph.
  /// It contains one or more subpaths (starting from 'M' path commands).
  d : String
  /// These values represent the minimum bounding box of the glyph in native units.
  xmin : Double
  ymin : Double
  xmax : Double
  ymax : Double
} derive(Show, Eq, FromJson, ToJson)
