///|
test "@draw.Group::bounding_box/empty" {
  let empty_group = @draw.Group::new()
  inspect(@draw.Group::bounding_box(empty_group), content="None")
}

///|
test "@draw.Group::bounding_box/single_item" {
  let path = @draw.Path::from_points(
    [@draw.vec2(0, 0), @draw.vec2(1, 1)],
    closed=true,
  )
  let group = @draw.Group::new(items=[@draw.Graphic::Path(path)])
  let bbox = @draw.BoundingBox::new(min=@draw.vec2(0, 0), max=@draw.vec2(1, 1))
  inspect(@draw.Group::bounding_box(group), content="Some(\{bbox})")
}

///|
test "@draw.Group::bounding_box/multiple_items" {
  let path1 = @draw.Path::from_points(
    [@draw.vec2(-1, -1), @draw.vec2(0, 0)],
    closed=true,
  )
  let path2 = @draw.Path::from_points(
    [@draw.vec2(1, 1), @draw.vec2(2, 2)],
    closed=true,
  )
  let group = @draw.Group::new(items=[
    @draw.Graphic::Path(path1),
    @draw.Graphic::Path(path2),
  ])
  let bbox = @draw.BoundingBox::new(
    min=@draw.vec2(-1, -1),
    max=@draw.vec2(2, 2),
  )
  inspect(@draw.Group::bounding_box(group), content="Some(\{bbox})")
}

///|
test "@draw.Group::to_json" {
  let path1 = @draw.Path::from_points(
    [@draw.vec2(-1, -1), @draw.vec2(0, 0)],
    closed=true,
  )
  let path2 = @draw.Path::from_points(
    [@draw.vec2(1, 1), @draw.vec2(2, 2)],
    closed=true,
  )
  let group = @draw.Group::new(items=[
    @draw.Graphic::Path(path1),
    @draw.Graphic::Path(path2),
  ])
  let got = group.to_json().stringify()
  inspect(
    got,
    content=
      #|{"items":[{"anchors":[{"position":{"x":-1,"y":-1},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}},{"position":{"x":0,"y":0},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}}],"closed":true,"clear":false},{"anchors":[{"position":{"x":1,"y":1},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}},{"position":{"x":2,"y":2},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}}],"closed":true,"clear":false}]}
    ,
  )
}

// test "@draw.Group::from_json" {
//   let json_str =
//     #|{"items":[{"anchors":[{"position":{"x":-1,"y":-1},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}},{"position":{"x":0,"y":0},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}}],"closed":true,"clear":false},{"anchors":[{"position":{"x":1,"y":1},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}},{"position":{"x":2,"y":2},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}}],"closed":true,"clear":false}]}
//   let json = @json.parse!(json_str)
//   let got : @draw.Group = @json.from_json!(json)
//   inspect!(got, content="{x: 1, y: 2}")
// }
