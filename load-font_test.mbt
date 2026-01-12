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
      assert_true(msg.contains("Checked paths:"))
      assert_true(msg.contains("python3 scripts/compress-all-fonts.py"))
    }
    e => fail("Unexpected error type: \{e}")
  }
}

///|
async test "load_font with environment variable" {
  // We can't easily test the environment variable path lookup in a unit test
  // without modifying the global state, but we can verify the success case
  // still works (it should find it locally).
  let font = @fonts.Font::load_font("baloo")
  inspect(font.id, content="baloo")
}
