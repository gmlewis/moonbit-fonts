///|
test "Group::bounding_box/empty" {
  let empty_group = Group::new()
  inspect(empty_group.bounding_box(), content="None")
}

///|
test "Group::bounding_box/single_item" {
  let path = Path::from_points([vec2(0, 0), vec2(1, 1)], closed=true)
  let group = Group::new(items=[Graphic::Path(path)])
  let bbox = BoundingBox::new(min=vec2(0, 0), max=vec2(1, 1))
  inspect(group.bounding_box(), content="Some(\{bbox})")
}

///|
test "Group::bounding_box/multiple_items" {
  let path1 = Path::from_points([vec2(-1, -1), vec2(0, 0)], closed=true)
  let path2 = Path::from_points([vec2(1, 1), vec2(2, 2)], closed=true)
  let group = Group::new(items=[Graphic::Path(path1), Graphic::Path(path2)])
  let bbox = BoundingBox::new(min=vec2(-1, -1), max=vec2(2, 2))
  inspect(group.bounding_box(), content="Some(\{bbox})")
}
