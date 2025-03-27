///|
test "@draw.Path::from_points/normal" {
  let points = [vec2(0, 0), vec2(1, 1), vec2(2, 0)]
  let path = @draw.Path::from_points(points, closed=true)
  inspect!(path.anchors.length(), content="3")
  inspect!(path.closed, content="true")
  inspect!(path.clear, content="false")
}

///|
test "@draw.Path::from_points/empty" {
  let points : Array[Vec2] = []
  let path = @draw.Path::from_points(points)
  inspect!(path.anchors.length(), content="0")
  inspect!(path.closed, content="false")
  inspect!(path.clear, content="false")
}

///|
test "@draw.Path::from_points/single-point" {
  let points = [vec2(1, 1)]
  let path = @draw.Path::from_points(points)
  inspect!(path.anchors.length(), content="1")
  inspect!(path.closed, content="false")
  inspect!(path.clear, content="false")
}

///|
test "@draw.Path::is_contained_by_bounding_box/empty_path" {
  let path = @draw.Path::new(anchors=[], closed=false, clear=false)
  let bbox = @draw.BoundingBox::new(
    min=@draw.vec2(0.0, 0.0),
    max=@draw.vec2(10.0, 10.0),
  )
  inspect!(
    @draw.Path::is_contained_by_bounding_box(path, bbox),
    content="false",
  )
}

///|
test "@draw.Path::is_contained_by_bounding_box/single_point_path_inside_bbox" {
  let anchor = @draw.Anchor::new(position=@draw.vec2(5.0, 5.0))
  let path = @draw.Path::new(anchors=[anchor], closed=false, clear=false)
  let bbox = @draw.BoundingBox::new(
    min=@draw.vec2(0.0, 0.0),
    max=@draw.vec2(10.0, 10.0),
  )
  inspect!(
    @draw.Path::is_contained_by_bounding_box(path, bbox),
    content="false",
  )
}

///|
test "@draw.Path::is_contained_by_bounding_box/multiple_points_path_partially_inside_bbox" {
  let anchor1 = @draw.Anchor::new(position=@draw.vec2(5.0, 5.0))
  let anchor2 = @draw.Anchor::new(position=@draw.vec2(15.0, 15.0))
  let path = @draw.Path::new(
    anchors=[anchor1, anchor2],
    closed=false,
    clear=false,
  )
  let bbox = @draw.BoundingBox::new(
    min=@draw.vec2(0.0, 0.0),
    max=@draw.vec2(10.0, 10.0),
  )
  inspect!(
    @draw.Path::is_contained_by_bounding_box(path, bbox),
    content="false",
  )
}
