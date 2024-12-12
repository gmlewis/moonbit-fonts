test "@draw.Group::bounding_box/empty" {
  let empty_group = @draw.Group::new()
  inspect!(@draw.Group::bounding_box(empty_group), content="None")
}

test "@draw.Group::bounding_box/single_item" {
  let path = @draw.Path::from_points(
    [@draw.vec2(0, 0), @draw.vec2(1, 1)],
    closed=true,
  )
  let group = @draw.Group::new(items=[@draw.Graphic::Path(path)])
  let bbox = @draw.BoundingBox::new(min=@draw.vec2(0, 0), max=@draw.vec2(1, 1))
  inspect!(@draw.Group::bounding_box(group), content="Some(\{bbox})")
}

test "@draw.Group::bounding_box/multiple_items" {
  let path1 = @draw.Path::from_points(
    [@draw.vec2(-1, -1), @draw.vec2(0, 0)],
    closed=true,
  )
  let path2 = @draw.Path::from_points(
    [@draw.vec2(1, 1), @draw.vec2(2, 2)],
    closed=true,
  )
  let group = @draw.Group::new(
    items=[@draw.Graphic::Path(path1), @draw.Graphic::Path(path2)],
  )
  let bbox = @draw.BoundingBox::new(
    min=@draw.vec2(-1, -1),
    max=@draw.vec2(2, 2),
  )
  inspect!(@draw.Group::bounding_box(group), content="Some(\{bbox})")
}
