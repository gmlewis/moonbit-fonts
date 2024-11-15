/// `gen_path` "renders" the provided text string into an SVG path
/// using the provided font information. It performs the necessary
/// path translations in order to combine the individual glyphs into
/// a "super glyph" that can be rendered as a whole.
///
/// Note that `gen_path` operates on the string as a left-justified whole
/// and anchors the entire path relative to `anchor` accordingly.
///
/// If you want multiple lines centered horizontally, use `gen_paths` instead.
///
/// Note that the SVG standard states that positive-Y is "down" with origin
/// coordinates in the upper-left, however, all SVG fonts appear to have their
/// origin in the lower left with positive-Y moving "up". This package
/// attempts to convert the SVG paths such that the font is equally readable
/// in both the "y_up=false" SVG canvas environment or in a 3D "y_up=true"
/// rendering environment.
pub fn gen_path(
  self : Font,
  text : String,
  anchor~ : Anchor = Unchanged,
  y_up~ : Bool = false
) -> Glyph!Error {
  let mut xmin = 0.0
  let mut ymin = 0.0
  let mut xmax = 0.0
  let mut ymax = 0.0
  let mut x = 0.0
  let mut y = 0.0
  let y_scale = if y_up { 1.0 } else { -1.0 }
  let char = @buffer.new()
  let gerber_lp = @buffer.new()
  let d = @buffer.new()
  //
  let mut first = true
  for c in text {
    match self.glyphs.get(c.to_string()) {
      Some(glyph) => {
        char.write_string(glyph.char)
        gerber_lp.write_string(glyph.gerber_lp)
        let (glyph_ymin, glyph_ymax) = if y_scale < 0 {
          (-glyph.ymax, -glyph.ymin)
        } else {
          (glyph.ymin, glyph.ymax)
        }
        if first {
          xmin = glyph.xmin
          xmax = glyph.xmax
          ymin = glyph_ymin
          ymax = glyph_ymax
          first = false
        } else {
          if x + glyph.xmin < xmin {
            xmin = x + glyph.xmin
          }
          if x + glyph.xmax > xmax {
            xmax = x + glyph.xmax
          }
          if y + glyph_ymin < ymin {
            ymin = y + glyph_ymin
          }
          if y + glyph_ymax > ymax {
            ymax = y + glyph_ymax
          }
        }
        d.write_string(translate_path!(glyph.d, x, y, invert_y=not(y_up)))
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
            y = y - y_scale * (self.units_per_em - self.descent)
          }
          '\x0d' => // \r - advance line only
            y = y - y_scale * (self.units_per_em - self.descent)
          // anything else - advance to the right by default width
          _ => x = x + self.horiz_adv_x
        }
      }
    }
  }
  let char = char.to_unchecked_string()
  let gerber_lp = gerber_lp.to_unchecked_string()
  let mut d = d.to_unchecked_string()
  let topy = if y_up { ymax } else { ymin }
  let boty = if y_up { ymin } else { ymax }
  let (dx, dy) = match anchor {
    Unchanged => (0.0, 0.0)
    TopLeft => (-xmin, -topy)
    TopCenter => (-(xmin + xmax) / 2, -topy)
    TopRight => (-xmax, -topy)
    CenterLeft => (-xmin, 0)
    Center => (-(xmin + xmax) / 2, 0)
    CenterRight => (-xmax, 0)
    BaselineLeft => (-xmin, 0)
    BaselineCenter => (-(xmin + xmax) / 2, 0)
    BaselineRight => (-xmax, 0)
    BottomLeft => (-xmin, -boty)
    BottomCenter => (-(xmin + xmax) / 2, -boty)
    BottomRight => (-xmax, -boty)
    RatioXY(rx, ry) => (-mix(xmin, xmax, rx), -mix(ymin, ymax, ry))
  }
  if anchor != Unchanged {
    d = translate_path!(d, dx, dy)
    xmin += dx
    ymin += dy
    xmax += dx
    ymax += dy
  }
  { char, horiz_adv_x: 0, gerber_lp, d, xmin, ymin, xmax, ymax }
}

fn mix(a : Double, b : Double, t : Double) -> Double {
  (1.0 - t) * a + t * b
}

/// `gen_paths` handles multiple strings independently.
pub fn gen_paths(
  self : Font,
  lines : Array[String],
  anchor~ : Anchor = BaselineLeft,
  y_up~ : Bool = false
) -> Array[Glyph]!Error {
  let glyphs = Array::new(capacity=lines.length())
  for line in lines {
    glyphs.push(self.gen_path!(line, anchor~, y_up~))
  }
  glyphs
}
