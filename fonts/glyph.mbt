/// `Glyph` represents a single glyph.
pub struct Glyph {
  /// `char` is this glyph.
  char : String
  /// `horiz_adv_x` is the number of font units to advance for this glyph.
  horiz_adv_x : Double
  /// `gerber_lp` is a string of "d" (for "dark") and "c" (for "clear")
  /// representing the nature of each subsequent font curve subpath
  /// contained within `d`. Its length matches the number of
  /// subpaths in `d` (starting from 'M' path commands).
  gerber_lp : String
  /// `d` is the SVG path in absolute coordinates for this glyph.
  /// It contains one or more subpaths (starting from 'M' path commands).
  d : String
  /// These values represent the minimum bounding box of the glyph in native units.
  xmin : Double
  ymin : Double
  xmax : Double
  ymax : Double
} derive(Show, Eq)
