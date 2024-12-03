///|
fn main {
  let b = @checkerboard.checkerboard()
  let s = @svg.from_graphic(b)
  println(s)
}
