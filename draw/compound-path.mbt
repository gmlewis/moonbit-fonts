/// CompoundPath represents one or more paths that typically make up a font glyph.
pub(all) struct CompoundPath {
  paths : Array[Path]
  stroke : Stroke?
  fill : Fill?
}
