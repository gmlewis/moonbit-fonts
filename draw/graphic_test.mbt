///|
test "@draw.Graphic::bounding_box/empty_array" {
  let items = @draw.Group::new(items=[]).as_graphic()
  let result = items.bounding_box()
  inspect(result, content="None")
}

///|
test "@draw.Graphic::bounding_box/single_path" {
  let v1 = @draw.vec2(1.0, 1.0)
  let v2 = @draw.vec2(2.0, 2.0)
  let path = @draw.Path::from_points([v1, v2], closed=true)
  let graphic = @draw.Graphic::Path(path)
  let items = @draw.Group::new(items=[graphic]).as_graphic()
  let result = items.bounding_box()
  inspect(result, content="Some({min: {x: 1, y: 1}, max: {x: 2, y: 2}})")
}

///|
test "@draw.Graphic::bounding_box/multiple_items" {
  let items = test_triangles()
  let result = items.bounding_box()
  inspect(result, content="Some({min: {x: 1, y: 1}, max: {x: 5, y: 5}})")
}

///|
fn test_triangles() -> @draw.Graphic {
  let v1 = @draw.vec2(1.0, 1.0)
  let v2 = @draw.vec2(2.0, 2.0)
  let v3 = @draw.vec2(1.0, 3.0)
  let path1 = @draw.Path::from_points([v1, v2, v3], closed=true)
  let v4 = @draw.vec2(4.0, 4.0)
  let v5 = @draw.vec2(5.0, 5.0)
  let path2 = @draw.Path::from_points([v3, v4, v5], closed=true)
  let graphic1 = @draw.Graphic::Path(path1)
  let graphic2 = @draw.Graphic::Path(path2)
  @draw.Group::new(items=[graphic1, graphic2]).as_graphic()
}

///|
let bbox = @draw.bbox

///|
let unit_square : @draw.Graphic = @draw.unit_square().as_graphic()

///|
test "unit square fit_to handles translation and scaling" {
  let tests = [
    // (graphic, dst_bbox)
    (unit_square, bbox(0, 0, 300, 300)),
    (unit_square, bbox(-100, -100, 500, 500)),
    (test_triangles(), bbox(0, 0, 300, 300)),
    (test_triangles(), bbox(10, 10, 20, 20)),
    (test_triangles(), bbox(-10, -10, 0, 0)),
  ]
  for tt in tests {
    let got = tt.0.fit_to(tt.1).bounding_box().unwrap()
    let want = tt.1
    assert_eq(got, want)
  }
}

///|
test "@draw.Graphic::to_profiles/Path" {
  let points = [vec2(0, 0), vec2(1, 0), vec2(1, 1), vec2(0, 1)]
  let path = @draw.Path::from_points(points, closed=true)
  let graphic = @draw.Graphic::Path(path)
  let profiles = graphic.to_profiles(10)
  inspect(profiles.length(), content="1")
  inspect(profiles[0].0.length(), content="4")
  inspect(profiles[0].1.length(), content="0")
}

///|
test "@draw.Graphic::to_profiles/CompoundPath" {
  let outer_points = [vec2(0, 0), vec2(10, 0), vec2(10, 10), vec2(0, 10)]
  let hole_points = [vec2(2, 2), vec2(8, 2), vec2(8, 8), vec2(2, 8)]
  let outer_path = @draw.Path::from_points(outer_points, closed=true)
  let hole_path = @draw.Path::from_points(hole_points, closed=true)
  let compound_path = @draw.CompoundPath::new(paths=[outer_path, hole_path])
  let graphic = @draw.Graphic::CompoundPath(compound_path)
  let profiles = graphic.to_profiles(10)
  inspect(profiles.length(), content="1")
  inspect(profiles[0].0.length(), content="4")
  inspect(profiles[0].1.length(), content="1")
  inspect(profiles[0].1[0].length(), content="4")
}
