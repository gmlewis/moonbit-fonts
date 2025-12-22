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
  inspect(Path::is_contained_by_bounding_box(path, bbox), content="false")
}

///|
test "Path::is_contained_by_bounding_box/single_point_path_inside_bbox" {
  let anchor = Anchor::new(position=vec2(5.0, 5.0))
  let path = Path::new(anchors=[anchor], closed=false, clear=false)
  let bbox = BoundingBox::new(min=vec2(0.0, 0.0), max=vec2(10.0, 10.0))
  inspect(Path::is_contained_by_bounding_box(path, bbox), content="false")
}

///|
test "Path::is_contained_by_bounding_box/multiple_points_path_partially_inside_bbox" {
  let anchor1 = Anchor::new(position=vec2(5.0, 5.0))
  let anchor2 = Anchor::new(position=vec2(15.0, 15.0))
  let path = Path::new(anchors=[anchor1, anchor2], closed=false, clear=false)
  let bbox = BoundingBox::new(min=vec2(0.0, 0.0), max=vec2(10.0, 10.0))
  inspect(Path::is_contained_by_bounding_box(path, bbox), content="false")
}

///|
test "Path::to_polygon/open_path" {
  let points = [vec2(0, 0), vec2(1, 0), vec2(1, 1), vec2(0, 1)]
  let path = Path::from_points(points, closed=false)
  let polygon = path.to_polygon(10)
  inspect(polygon.length(), content="0")
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

///|
test "Path::to_polygon/epsilon_forwarded_to_dedupe" {
  // Make two consecutive points very close so dedupe can remove them with a larger epsilon
  let p1 = vec2(1, 0)
  let p1b = vec2(1 + 1.e-6, 0)
  let p3 = vec2(2, 0)
  let path = Path::from_points([p1, p1b, p3], closed=true)
  let poly_default = path.to_polygon(1)
  let poly_large_eps = Path::to_polygon(path, 1, epsilon=1.e-3)

  // With a large epsilon the near-duplicate should be removed
  inspect(poly_default.length(), content="3")
  inspect(poly_default[0], content="{x: 1, y: 0}")
  inspect(poly_default[1], content="{x: 1.000001, y: 0}")
  inspect(poly_default[2], content="{x: 2, y: 0}")
  inspect(poly_large_eps.length(), content="2")
  inspect(poly_large_eps[0], content="{x: 1, y: 0}")
  inspect(poly_large_eps[1], content="{x: 2, y: 0}")
  inspect(poly_large_eps.length() < poly_default.length(), content="true")
}

///|
test "Path::to_polygon/remove_final_duplicate" {
  // Two-anchor curve sampling with curve_segments=2 should produce a duplicated closing point
  let a1 = Anchor::new(position=vec2(0, 0), handle_out=vec2(0.5, 0))
  let a2 = Anchor::new(position=vec2(1, 0), handle_in=vec2(-0.5, 0))
  let path = Path::new(anchors=[a1, a2], closed=true)
  let poly = path.to_polygon(2)
  inspect(poly.length(), content="2")
  inspect(poly[0], content="{x: 0, y: 0}")
  inspect(poly[1], content="{x: 1, y: 0}")
}

///|
test "Path from_json/to_json roundtrip" {
  let json_str =
    #|{"anchors":[{"position":{"x":0,"y":0},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}},{"position":{"x":1,"y":1},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}}],"closed":true,"clear":false}
  let json = @json.parse(json_str)
  let path_from_json : Path = @json.from_json(json)
  let got_json = path_from_json.to_json().stringify()
  inspect(got_json, content=json_str)
}
