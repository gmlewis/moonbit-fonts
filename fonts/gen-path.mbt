/// `gen_path` renders the provided text string into an SVG path
/// using the provided font information.
pub fn gen_path(self: Font, text: String) -> String {
  let mut x = 0.0
  let mut y = 0.0
  let d = Buffer::new()
  text.iter().each(
    fn(c) {
      match self.glyphs.get(c) {
        Some(glyph) = {
          d.write_string(glyph.translate(x, y))
          if glyph.horiz_adv_x > 0.0 {
            x = x + glyph.horiz_adv_x
          } else {
            x = x + self.horiz_adv_x
          }
        }
        None => {
          match c {
            "\x0a" => {  // \n
              x = 0
              y = y - self.units_per_em + self.descent
            }
            "\x0d" => {  // \r
              y = y - self.units_per_em + self.descent
            }
            _ => {
              x = x + self.horiz_adv_x
            }
          }
        }
      }
    }
  )
  d.to_string()
}