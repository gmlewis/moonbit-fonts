///|
using @geom {type Alignment}

///|
/// `gen_paths` handles multiple strings independently so that they
/// can be aligned and distributed more flexibly.
pub fn Font::gen_paths(
  self : Font,
  lines : Array[String],
  alignment? : Alignment = BaselineLeft,
  y_up? : Bool = false,
) -> Array[Glyph] raise FontError {
  let glyphs = Array::new(capacity=lines.length())
  for line in lines {
    glyphs.push(self.gen_path(line, alignment~, y_up~))
  }
  glyphs
}
