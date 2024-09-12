/// `gen_path` "renders" the provided text string into an SVG path
/// using the provided font information. It performs the necessary
/// path translations in order to combine the individual glyphs into
/// a "super glyph" that can be rendered as a whole.
/// Note that center_x and center_y operate on the string as a
/// left-justified whole.
/// If you want multiple lines centered horizontally, first break them
/// up into separate lines and center them individually, then combine
/// the results.
pub fn gen_path(
  self : Font,
  text : String,
  ~center_x : Bool = false,
  ~center_y : Bool = false
) -> Glyph!Error {
  let mut xmin = 0.0
  let mut ymin = 0.0
  let mut xmax = 0.0
  let mut ymax = 0.0
  let mut x = 0.0
  let mut y = 0.0
  let char = Buffer::new()
  let gerber_lp = Buffer::new()
  let d = Buffer::new()
  //
  let mut first = true
  for c in text {
    match self.glyphs.get(c.to_string()) {
      Some(glyph) => {
        char.write_string(glyph.char)
        gerber_lp.write_string(glyph.gerber_lp)
        if first {
          xmin = glyph.xmin
          xmax = glyph.xmax
          ymin = glyph.ymin
          ymax = glyph.ymax
          first = false
        } else {
          if x + glyph.xmin < xmin {
            xmin = x + glyph.xmin
          }
          if x + glyph.xmax > xmax {
            xmax = x + glyph.xmax
          }
          if y + glyph.ymin < ymin {
            ymin = y + glyph.ymin
          }
          if y + glyph.ymax > ymax {
            ymax = y + glyph.ymax
          }
        }
        d.write_string(translate_path!(glyph.d, x, y))
        if glyph.horiz_adv_x > 0.0 {
          x = x + glyph.horiz_adv_x
        } else {
          x = x + self.horiz_adv_x
        }
      }
      None => {
        char.write_char(c)
        match c {
          '\x0a' => { // \n - advance line and return to far left
            x = 0.0
            y = y - self.units_per_em + self.descent
          }
          '\x0d' => // \r - advance line only
            y = y - self.units_per_em + self.descent
          // anything else - advance to the right by default width
          _ => x = x + self.horiz_adv_x
        }
      }
    }
  }
  let char = char.to_string()
  let gerber_lp = gerber_lp.to_string()
  let mut d = d.to_string()
  if center_x {
    let cx = (xmin + xmax) / 2
    d = translate_path!(d, -cx, 0)
    xmin -= cx
    xmax -= cx
  }
  if center_y {
    let cy = (ymin + ymax) / 2
    d = translate_path!(d, 0, -cy)
    ymin -= cy
    ymax -= cy
  }
  { char, horiz_adv_x: 0, gerber_lp, d, xmin, ymin, xmax, ymax }
}
