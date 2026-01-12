///|
async test "load_font success" {
  let font = @fonts.Font::load_font("baloo")
  inspect(font.id, content="baloo")
}

///|
async test "load_font failure" {
  try {
    let _ = @fonts.Font::load_font("nonexistent_font")
    fail("Should have failed")
  } catch {
    @fonts.FontError(msg) => {
      assert_true(msg.contains("Font 'nonexistent_font' not found"))
      assert_true(msg.contains("python3 scripts/compress-all-fonts.py"))
    }
    e => fail("Unexpected error: \{e}")
  }
}
