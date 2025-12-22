///|
test "Graphic::bounding_box/empty_array" {
  let items = Group::new(items=[]).as_graphic()
  let result = items.bounding_box()
  inspect(result, content="None")
}

///|
test "Graphic::bounding_box/single_path" {
  let v1 = vec2(1.0, 1.0)
  let v2 = vec2(2.0, 2.0)
  let path = Path::from_points([v1, v2], closed=true)
  let graphic = Graphic::Path(path)
  let items = Group::new(items=[graphic]).as_graphic()
  let result = items.bounding_box()
  inspect(result, content="Some({min: {x: 1, y: 1}, max: {x: 2, y: 2}})")
}

///|
test "Graphic::bounding_box/multiple_items" {
  let items = test_triangles()
  let result = items.bounding_box()
  inspect(result, content="Some({min: {x: 1, y: 1}, max: {x: 5, y: 5}})")
}

///|
fn test_triangles() -> Graphic {
  let v1 = vec2(1.0, 1.0)
  let v2 = vec2(2.0, 2.0)
  let v3 = vec2(1.0, 3.0)
  let path1 = Path::from_points([v1, v2, v3], closed=true)
  let v4 = vec2(4.0, 4.0)
  let v5 = vec2(5.0, 5.0)
  let path2 = Path::from_points([v3, v4, v5], closed=true)
  let graphic1 = Graphic::Path(path1)
  let graphic2 = Graphic::Path(path2)
  Group::new(items=[graphic1, graphic2]).as_graphic()
}

///|
let unit_square : @draw.Graphic = @draw.unit_square().as_graphic()

///|
test "unit square fit_to handles translation and scaling with alignment" {
  // unit_square is 1x1, centered at (0,0), so bbox is min:(-0.5,-0.5), max:(0.5,0.5)
  let tests = [
    // (graphic, dst_bbox, anchor, expected_bbox)
    (unit_square, bbox(0, 0, 300, 300), Alignment::Center, bbox(0, 0, 300, 300)),
    (
      unit_square,
      bbox(-100, -100, 500, 500),
      Center,
      bbox(-100, -100, 500, 500),
    ),

    // Wide box (2x1), unit square (1x1) fits vertically, horizontal alignment varies
    (unit_square, bbox(0, 0, 2, 1), BottomLeft, bbox(0, 0, 1, 1)),
    (unit_square, bbox(0, 0, 2, 1), BottomCenter, bbox(0.5, 0, 1.5, 1)),
    (unit_square, bbox(0, 0, 2, 1), BottomRight, bbox(1, 0, 2, 1)),
    (unit_square, bbox(0, 0, 2, 1), CenterLeft, bbox(0, 0, 1, 1)),
    (unit_square, bbox(0, 0, 2, 1), Center, bbox(0.5, 0, 1.5, 1)),
    (unit_square, bbox(0, 0, 2, 1), CenterRight, bbox(1, 0, 2, 1)),
    (unit_square, bbox(0, 0, 2, 1), TopLeft, bbox(0, 0, 1, 1)),
    (unit_square, bbox(0, 0, 2, 1), TopCenter, bbox(0.5, 0, 1.5, 1)),
    (unit_square, bbox(0, 0, 2, 1), TopRight, bbox(1, 0, 2, 1)),
    (unit_square, bbox(0, 0, 2, 1), BaselineLeft, bbox(0, 0, 1, 1)),
    (unit_square, bbox(0, 0, 2, 1), BaselineCenter, bbox(0.5, 0, 1.5, 1)),
    (unit_square, bbox(0, 0, 2, 1), BaselineRight, bbox(1, 0, 2, 1)),
    (unit_square, bbox(0, 0, 2, 1), RatioXY(0.25, 0.5), bbox(0.25, 0, 1.25, 1)),

    // Tall box (1x2), unit square (1x1) fits horizontally, vertical alignment varies
    (unit_square, bbox(0, 0, 1, 2), BottomLeft, bbox(0, 0, 1, 1)),
    (unit_square, bbox(0, 0, 1, 2), CenterLeft, bbox(0, 0.5, 1, 1.5)),
    (unit_square, bbox(0, 0, 1, 2), TopLeft, bbox(0, 1, 1, 2)),
    (unit_square, bbox(0, 0, 1, 2), RatioXY(0.5, 0.75), bbox(0, 0.75, 1, 1.75)),

    // Complex triangles
    (test_triangles(), bbox(0, 0, 300, 300), Center, bbox(0, 0, 300, 300)),
    (test_triangles(), bbox(10, 10, 20, 20), Center, bbox(10, 10, 20, 20)),
  ]
  for tt in tests {
    let got = tt.0.fit_to(tt.1, anchor=tt.2).bounding_box().unwrap()
    let want = tt.3
    assert_eq(got, want)
  }
}

///|
test "Graphic::to_profiles/Path" {
  let points = [vec2(0, 0), vec2(1, 0), vec2(1, 1), vec2(0, 1)]
  let path = Path::from_points(points, closed=true)
  let graphic = Graphic::Path(path)
  let profiles = graphic.to_profiles(10)
  inspect(profiles.length(), content="1")
  inspect(profiles[0].0.length(), content="4")
  inspect(profiles[0].1.length(), content="0")
}

///|
test "Graphic::to_profiles/CompoundPath" {
  let outer_points = [vec2(0, 0), vec2(10, 0), vec2(10, 10), vec2(0, 10)]
  let hole_points = [vec2(2, 2), vec2(8, 2), vec2(8, 8), vec2(2, 8)]
  let outer_path = Path::from_points(outer_points, closed=true)
  let hole_path = Path::from_points(hole_points, closed=true)
  let compound_path = CompoundPath::new(paths=[outer_path, hole_path])
  let graphic = Graphic::CompoundPath(compound_path)
  let profiles = graphic.to_profiles(10)
  inspect(profiles.length(), content="1")
  inspect(profiles[0].0.length(), content="4")
  inspect(profiles[0].1.length(), content="1")
  inspect(profiles[0].1[0].length(), content="4")
}

///|
test "Graphic::to_profiles/Group" {
  let p_points = [vec2(0, 0), vec2(1, 0), vec2(1, 1), vec2(0, 1)]
  let p_path = Path::from_points(p_points, closed=true)
  let outer_points = [vec2(0, 0), vec2(10, 0), vec2(10, 10), vec2(0, 10)]
  let hole_points = [vec2(2, 2), vec2(8, 2), vec2(8, 8), vec2(2, 8)]
  let outer_path = Path::from_points(outer_points, closed=true)
  let hole_path = Path::from_points(hole_points, closed=true)
  let compound_path = CompoundPath::new(paths=[outer_path, hole_path])
  let grp = Group::new(items=[
    Graphic::Path(p_path),
    Graphic::CompoundPath(compound_path),
  ])
  let graphic = grp.as_graphic()
  let profiles = graphic.to_profiles(10)
  inspect(profiles.length(), content="2")
  inspect(profiles[0].0.length(), content="4")
  inspect(profiles[1].0.length(), content="4")
  inspect(profiles[1].1.length(), content="1")
}

///|
test "Graphic::to_profiles_tuples/Path" {
  let points = [vec2(0, 0), vec2(1, 0), vec2(1, 1), vec2(0, 1)]
  let path = Path::from_points(points, closed=true)
  let graphic = Graphic::Path(path)
  let profiles = graphic.to_profiles_tuples(10)
  inspect(profiles.length(), content="1")
  inspect(profiles[0].0.length(), content="4")
  inspect(profiles[0].1.length(), content="0")
  let first_tuple = profiles[0].0[0]
  let v = Vec2::from_tuple(first_tuple)
  inspect(v, content="{x: 0, y: 0}")
}

///|
test "Graphic::to_profiles_tuples/CompoundPath" {
  let outer_points = [vec2(0, 0), vec2(10, 0), vec2(10, 10), vec2(0, 10)]
  let hole_points = [vec2(2, 2), vec2(8, 2), vec2(8, 8), vec2(2, 8)]
  let outer_path = Path::from_points(outer_points, closed=true)
  let hole_path = Path::from_points(hole_points, closed=true)
  let compound_path = CompoundPath::new(paths=[outer_path, hole_path])
  let graphic = Graphic::CompoundPath(compound_path)
  let profiles = graphic.to_profiles_tuples(10)
  inspect(profiles.length(), content="1")
  inspect(profiles[0].0.length(), content="4")
  inspect(profiles[0].1.length(), content="1")
  let first_tuple = profiles[0].1[0][0]
  let v = Vec2::from_tuple(first_tuple)
  inspect(v, content="{x: 2, y: 2}")
}

///|
test "Graphic::with_margin" {
  let points = [vec2(0, 0), vec2(10, 10)]
  let path = Path::from_points(points, closed=true)
  let graphic = Graphic::Path(path)

  // Test adding margins
  let margined = graphic.with_margin(top=1.0, right=2.0, bottom=3.0, left=4.0)
  let result = margined.bounding_box()

  // Original bbox was min:(0,0), max:(10,10)
  // New bbox should be min:(-4, -3), max:(12, 11)
  inspect(result, content="Some({min: {x: -4, y: -3}, max: {x: 12, y: 11}})")
}

///|
test "Graphic from_json/to_json roundtrip" {
  let tests = [ // CompoundPath
    (
      #|{"paths":[{"anchors":[{"position":{"x":0,"y":0},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}},{"position":{"x":1,"y":1},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}}],"closed":true,"clear":false},{"anchors":[{"position":{"x":2,"y":2},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}},{"position":{"x":3,"y":3},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}}],"closed":false,"clear":false}],"fill":{"color":{"r":1,"g":0,"b":0,"a":1}}}
    ), // Group
    (
      #|{"items":[{"anchors":[{"position":{"x":-1,"y":-1},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}},{"position":{"x":0,"y":0},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}}],"closed":true,"clear":false},{"anchors":[{"position":{"x":1,"y":1},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}},{"position":{"x":2,"y":2},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}}],"closed":true,"clear":false}]}
    ), // Path
    (
      #|{"anchors":[{"position":{"x":0,"y":0},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}},{"position":{"x":1,"y":1},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}}],"closed":true,"clear":false}
    ),
  ]
  for tt in tests {
    let json_str = tt
    let json = @json.parse(json_str)
    let graphic : Graphic = @json.from_json(json)
    let got_json = graphic.to_json()
    let got_json_str = got_json.stringify()
    assert_eq(got_json_str, json_str)
  }
}
