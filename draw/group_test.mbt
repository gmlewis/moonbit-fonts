///|
test "Group::bounding_box/empty" {
  let empty_group = Group::new()
  inspect(Group::bounding_box(empty_group), content="None")
}

///|
test "Group::bounding_box/single_item" {
  let path = Path::from_points([vec2(0, 0), vec2(1, 1)], closed=true)
  let group = Group::new(items=[Graphic::Path(path)])
  let bbox = BoundingBox::new(min=vec2(0, 0), max=vec2(1, 1))
  inspect(Group::bounding_box(group), content="Some(\{bbox})")
}

///|
test "Group::bounding_box/multiple_items" {
  let path1 = Path::from_points([vec2(-1, -1), vec2(0, 0)], closed=true)
  let path2 = Path::from_points([vec2(1, 1), vec2(2, 2)], closed=true)
  let group = Group::new(items=[Graphic::Path(path1), Graphic::Path(path2)])
  let bbox = BoundingBox::new(min=vec2(-1, -1), max=vec2(2, 2))
  inspect(Group::bounding_box(group), content="Some(\{bbox})")
}

///|
test "Group::to_json" {
  let path1 = Path::from_points([vec2(-1, -1), vec2(0, 0)], closed=true)
  let path2 = Path::from_points([vec2(1, 1), vec2(2, 2)], closed=true)
  let group = Group::new(items=[Graphic::Path(path1), Graphic::Path(path2)])
  let got = group.to_json().stringify()
  inspect(
    got,
    content=(
      #|{"items":[{"anchors":[{"position":{"x":-1,"y":-1},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}},{"position":{"x":0,"y":0},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}}],"closed":true,"clear":false},{"anchors":[{"position":{"x":1,"y":1},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}},{"position":{"x":2,"y":2},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}}],"closed":true,"clear":false}]}
    ),
  )
}

// test "Group::from_json" {
//   let json_str =
//     #|{"items":[{"anchors":[{"position":{"x":-1,"y":-1},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}},{"position":{"x":0,"y":0},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}}],"closed":true,"clear":false},{"anchors":[{"position":{"x":1,"y":1},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}},{"position":{"x":2,"y":2},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}}],"closed":true,"clear":false}]}
//   let json = @json.parse!(json_str)
//   let got : Group = @json.from_json!(json)
//   inspect!(got, content="{x: 1, y: 2}")
// }
