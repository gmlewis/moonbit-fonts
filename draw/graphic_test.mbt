test "@draw.Graphic::bounding_box/empty_array" {
  let items : Array[@draw.Graphic] = []
  let result = @draw.Graphic::bounding_box(items)
  inspect!(result, content="None")
}

test "@draw.Graphic::bounding_box/single_path" {
  let v1 = @draw.vec2(1.0, 1.0)
  let v2 = @draw.vec2(2.0, 2.0)
  let path = @draw.Path::from_points([v1, v2], true)
  let graphic = @draw.Graphic::Path(path)
  let items : Array[@draw.Graphic] = [graphic]
  let result = @draw.Graphic::bounding_box(items)
  inspect!(result, content="Some({min: {x: 1, y: 1}, max: {x: 2, y: 2}})")
}

test "@draw.Graphic::bounding_box/multiple_items" {
  let v1 = @draw.vec2(1.0, 1.0)
  let v2 = @draw.vec2(2.0, 2.0)
  let path1 = @draw.Path::from_points([v1, v2], true)
  let v3 = @draw.vec2(3.0, 3.0)
  let v4 = @draw.vec2(4.0, 4.0)
  let path2 = @draw.Path::from_points([v3, v4], true)
  let graphic1 = @draw.Graphic::Path(path1)
  let graphic2 = @draw.Graphic::Path(path2)
  let items : Array[@draw.Graphic] = [graphic1, graphic2]
  let result = @draw.Graphic::bounding_box(items)
  inspect!(result, content="Some({min: {x: 1, y: 1}, max: {x: 4, y: 4}})")
}
