test "@draw.Graphic::bounding_box/empty_array" {
  let items = @draw.Group::new(items=[]).as_graphic()
  let result = items.bounding_box()
  inspect!(result, content="None")
}

test "@draw.Graphic::bounding_box/single_path" {
  let v1 = @draw.vec2(1.0, 1.0)
  let v2 = @draw.vec2(2.0, 2.0)
  let path = @draw.Path::from_points([v1, v2], closed=true)
  let graphic = @draw.Graphic::Path(path)
  let items = @draw.Group::new(items=[graphic]).as_graphic()
  let result = items.bounding_box()
  inspect!(result, content="Some({min: {x: 1, y: 1}, max: {x: 2, y: 2}})")
}

test "@draw.Graphic::bounding_box/multiple_items" {
  let v1 = @draw.vec2(1.0, 1.0)
  let v2 = @draw.vec2(2.0, 2.0)
  let path1 = @draw.Path::from_points([v1, v2], closed=true)
  let v3 = @draw.vec2(3.0, 3.0)
  let v4 = @draw.vec2(4.0, 4.0)
  let path2 = @draw.Path::from_points([v3, v4], closed=true)
  let graphic1 = @draw.Graphic::Path(path1)
  let graphic2 = @draw.Graphic::Path(path2)
  let items = @draw.Group::new(items=[graphic1, graphic2]).as_graphic()
  let result = items.bounding_box()
  inspect!(result, content="Some({min: {x: 1, y: 1}, max: {x: 4, y: 4}})")
}

///|
let bbox = @draw.bbox

///|
let unit_square = @draw.unit_square

test "unit square fit_to handles translation and scaling" {
  let tests = [
    // (graphic, dst_bbox)
    (unit_square(), bbox(0, 0, 300, 300)),
    (unit_square(), bbox(-100, -100, 500, 500)),
  ]
  for tt in tests {
    let got = tt.0.as_graphic().fit_to(tt.1).bounding_box().unwrap()
    let want = tt.1
    assert_eq!(got, want)
  }
}
