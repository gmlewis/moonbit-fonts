///|
test "checkerboard" {
  let got = @gmlewis/fonts/examples/checkerboard.checkerboard()
  inspect!(
    got.bounding_box(),
    content="Some({min: {x: 0, y: 0}, max: {x: 8, y: 8}})",
  )
}
