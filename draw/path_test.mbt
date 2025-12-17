///|
test "@draw.Path::from_points/normal" {
  let points = [vec2(0, 0), vec2(1, 1), vec2(2, 0)]
  let path = @draw.Path::from_points(points, closed=true)
  inspect(path.anchors.length(), content="3")
  inspect(path.closed, content="true")
  inspect(path.clear, content="false")
}

///|
test "@draw.Path::from_points/empty" {
  let points : Array[Vec2] = []
  let path = @draw.Path::from_points(points)
  inspect(path.anchors.length(), content="0")
  inspect(path.closed, content="false")
  inspect(path.clear, content="false")
}

///|
test "@draw.Path::from_points/single-point" {
  let points = [vec2(1, 1)]
  let path = @draw.Path::from_points(points)
  inspect(path.anchors.length(), content="1")
  inspect(path.closed, content="false")
  inspect(path.clear, content="false")
}

///|
test "@draw.Path::is_contained_by_bounding_box/empty_path" {
  let path = @draw.Path::new(anchors=[], closed=false, clear=false)
  let bbox = @draw.BoundingBox::new(
    min=@draw.vec2(0.0, 0.0),
    max=@draw.vec2(10.0, 10.0),
  )
  inspect(@draw.Path::is_contained_by_bounding_box(path, bbox), content="false")
}

///|
test "@draw.Path::is_contained_by_bounding_box/single_point_path_inside_bbox" {
  let anchor = @draw.Anchor::new(position=@draw.vec2(5.0, 5.0))
  let path = @draw.Path::new(anchors=[anchor], closed=false, clear=false)
  let bbox = @draw.BoundingBox::new(
    min=@draw.vec2(0.0, 0.0),
    max=@draw.vec2(10.0, 10.0),
  )
  inspect(@draw.Path::is_contained_by_bounding_box(path, bbox), content="false")
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
  inspect(@draw.Path::is_contained_by_bounding_box(path, bbox), content="false")
}

///|
test "@draw.Path::to_polygon/open_path" {
  let points = [vec2(0, 0), vec2(1, 0), vec2(1, 1), vec2(0, 1)]
  let path = @draw.Path::from_points(points, closed=false)
  let polygon = path.to_polygon(10)
  inspect(polygon.length(), content="0")
}

///|
test "@draw.Path::to_polygon/simple_square" {
  let points = [vec2(0, 0), vec2(1, 0), vec2(1, 1), vec2(0, 1)]
  let path = @draw.Path::from_points(points, closed=true)
  let polygon = path.to_polygon(10)
  inspect(polygon.length(), content="4")
  inspect(polygon[0], content="{x: 0, y: 0}")
  inspect(polygon[1], content="{x: 1, y: 0}")
  inspect(polygon[2], content="{x: 1, y: 1}")
  inspect(polygon[3], content="{x: 0, y: 1}")
}

///|
test "@draw.Path::to_polygon/with_curves" {
  // Create a path with a curve
  let a1 = @draw.Anchor::new(position=vec2(0, 0), handle_out=vec2(0.5, 0))
  let a2 = @draw.Anchor::new(position=vec2(1, 1), handle_in=vec2(-0.5, 0))
  let path = @draw.Path::new(anchors=[a1, a2], closed=true)
  let polygon = path.to_polygon(5)
  inspect(polygon.length(), content="5") // 5 segments, but deduped
}
