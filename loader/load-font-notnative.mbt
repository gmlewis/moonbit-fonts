///|
pub fn Font::load_font(_font_name : String) -> Font raise FontError {
  raise FontError("Font loading is only supported with --target native.")
}
