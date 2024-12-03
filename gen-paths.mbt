///| `gen_paths` handles multiple strings independently so that they
/// can be aligned and distributed more flexibly.
pub fn gen_paths(
  self : Font,
  lines : Array[String],
  anchor~ : Anchor = BaselineLeft,
  y_up~ : Bool = false
) -> Array[Glyph]!FontError {
  let glyphs = Array::new(capacity=lines.length())
  for line in lines {
    glyphs.push(self.gen_path!(line, anchor~, y_up~))
  }
  glyphs
}
