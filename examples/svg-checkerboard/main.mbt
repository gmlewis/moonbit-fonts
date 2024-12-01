fn main {
  let b = @checkerboard.checkerboard()
  let s = @svg.from_graphics(b)
  println(s)
}
