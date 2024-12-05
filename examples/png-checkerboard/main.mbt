///|
fn main {
  let width = 900
  let height = 900
  let b = @checkerboard.checkerboard()

  //
  try {
    let content = @png.from_graphic(b, width, height)
    @fs.write_bytes_to_file(path="checkerboard.png", content~)
  } catch {
    _ => println("error writing checkerboard.png")
  }
}
