///|
test "Graphic::to_json of group" {
  let group = unit_square()
  let got = group.to_json().stringify()
  inspect(
    got,
    content=(
      #|{"items":[{"anchors":[{"position":{"x":-0.5,"y":-0.5},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}},{"position":{"x":0.5,"y":-0.5},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}},{"position":{"x":0.5,"y":0.5},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}},{"position":{"x":-0.5,"y":0.5},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}}],"closed":true,"clear":false}]}
    ),
  )
}

///|
test "Graphic::to_json of path" {
  let path = Path::from_points([vec2(0, 0), vec2(1, 1)])
  let got = path.to_json().stringify()
  inspect(
    got,
    content=(
      #|{"anchors":[{"position":{"x":0,"y":0},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}},{"position":{"x":1,"y":1},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}}],"closed":false,"clear":false}
    ),
  )
}
