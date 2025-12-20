///|
test "Path::from_points/normal" {
  let points = [vec2(0, 0), vec2(1, 1), vec2(2, 0)]
  let path = Path::from_points(points, closed=true)
  inspect(path.anchors.length(), content="3")
  inspect(path.closed, content="true")
  inspect(path.clear, content="false")
}

///|
test "Path::from_points/empty" {
  let points : Array[Vec2] = []
  let path = Path::from_points(points)
  inspect(path.anchors.length(), content="0")
  inspect(path.closed, content="false")
  inspect(path.clear, content="false")
}

///|
test "Path::from_points/single-point" {
  let points = [vec2(1, 1)]
  let path = Path::from_points(points)
  inspect(path.anchors.length(), content="1")
  inspect(path.closed, content="false")
  inspect(path.clear, content="false")
}

///|
test "Path::is_contained_by_bounding_box/empty_path" {
  let path = Path::new(anchors=[], closed=false, clear=false)
  let bbox = BoundingBox::new(min=vec2(0.0, 0.0), max=vec2(10.0, 10.0))
  inspect(path.is_contained_by_bounding_box(bbox), content="false")
}

///|
test "Path::to_polygon/simple_square" {
  let points = [vec2(0, 0), vec2(1, 0), vec2(1, 1), vec2(0, 1)]
  let path = Path::from_points(points, closed=true)
  let polygon = path.to_polygon(10)
  inspect(polygon.length(), content="4")
  inspect(polygon[0], content="{x: 0, y: 0}")
  inspect(polygon[1], content="{x: 1, y: 0}")
  inspect(polygon[2], content="{x: 1, y: 1}")
  inspect(polygon[3], content="{x: 0, y: 1}")
}

///|
test "Path::to_polygon/with_curves" {
  // Create a path with a curve
  let a1 = Anchor::new(position=vec2(0, 0), handle_out=vec2(0.5, 0))
  let a2 = Anchor::new(position=vec2(1, 1), handle_in=vec2(-0.5, 0))
  let path = Path::new(anchors=[a1, a2], closed=true)
  let polygon = path.to_polygon(5)
  inspect(polygon.length(), content="5") // 5 segments, but deduped
}
