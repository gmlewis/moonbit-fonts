test "@vec2.BoundingBox::new" {
  // Test default values (both min and max are zero vectors)
  let bb1 = @vec2.BoundingBox::new()
  inspect!(bb1.min.x, content="0")
  inspect!(bb1.min.y, content="0")
  inspect!(bb1.max.x, content="0")
  inspect!(bb1.max.y, content="0")

  // Test custom values
  let bb2 = @vec2.BoundingBox::new(min=@vec2.vec2(-1, -2), max=@vec2.vec2(3, 4))
  inspect!(bb2.min.x, content="-1")
  inspect!(bb2.min.y, content="-2")
  inspect!(bb2.max.x, content="3")
  inspect!(bb2.max.y, content="4")

  // Test zero-area bounding box
  let bb3 = @vec2.BoundingBox::new(min=@vec2.vec2(5, 5), max=@vec2.vec2(5, 5))
  inspect!(bb3.min.x, content="5")
  inspect!(bb3.min.y, content="5")
  inspect!(bb3.max.x, content="5")
  inspect!(bb3.max.y, content="5")
}

test "@vec2.BoundingBox::new/default_values" {
  let bounding_box = @vec2.BoundingBox::new()
  inspect!(bounding_box.min.x, content="0")
  inspect!(bounding_box.min.y, content="0")
  inspect!(bounding_box.max.x, content="0")
  inspect!(bounding_box.max.y, content="0")
}

test "@vec2.BoundingBox::new/positive_values" {
  let vec_min = @vec2.vec2(1.0, 1.0)
  let vec_max = @vec2.vec2(3.0, 4.0)
  let bounding_box = @vec2.BoundingBox::new(min=vec_min, max=vec_max)
  inspect!(bounding_box.min.x, content="1")
  inspect!(bounding_box.min.y, content="1")
  inspect!(bounding_box.max.x, content="3")
  inspect!(bounding_box.max.y, content="4")
}

test "@vec2.BoundingBox::new/negative_values" {
  let vec_min = @vec2.vec2(-5.0, -5.0)
  let vec_max = @vec2.vec2(-1.0, -2.0)
  let bounding_box = @vec2.BoundingBox::new(min=vec_min, max=vec_max)
  inspect!(bounding_box.min.x, content="-5")
  inspect!(bounding_box.min.y, content="-5")
  inspect!(bounding_box.max.x, content="-1")
  inspect!(bounding_box.max.y, content="-2")
}

test "@vec2.BoundingBox::from_points/normal" {
  let points = [
    @vec2.vec2(-1.0, -1.0),
    @vec2.vec2(1.0, -1.0),
    @vec2.vec2(1.0, 1.0),
    @vec2.vec2(-1.0, 1.0),
  ]
  let bbox = @vec2.BoundingBox::from_points(points)
  inspect!(bbox.min.x, content="-1")
  inspect!(bbox.min.y, content="-1")
  inspect!(bbox.max.x, content="1")
  inspect!(bbox.max.y, content="1")
}

test "@vec2.BoundingBox::from_points/single_point" {
  let points = [@vec2.vec2(3.0, 4.0)]
  let bbox = @vec2.BoundingBox::from_points(points)
  inspect!(bbox.min.x, content="3")
  inspect!(bbox.min.y, content="4")
  inspect!(bbox.max.x, content="3")
  inspect!(bbox.max.y, content="4")
}

test "panic @vec2.BoundingBox::from_points/empty" {
  let points : Array[Vec2] = []
  ignore(@vec2.BoundingBox::from_points(points))
}

test "@gmlewis/fonts/vec2.BoundingBox::from_points" {
  let point1 = @gmlewis/fonts/vec2.vec2(1.0, 2.0)
  let point2 = @gmlewis/fonts/vec2.vec2(3.0, 4.0)
  let points = [point1, point2]
  let bbox = @gmlewis/fonts/vec2.BoundingBox::from_points(points)
  inspect!(bbox.min, content="{x: 1, y: 2}")
  inspect!(bbox.max, content="{x: 3, y: 4}")
}

test "@gmlewis/fonts/vec2.BoundingBox::from_points/single_point" {
  let point = @gmlewis/fonts/vec2.vec2(5.0, 5.0)
  let points = [point]
  let bbox = @gmlewis/fonts/vec2.BoundingBox::from_points(points)
  inspect!(bbox.min, content="{x: 5, y: 5}")
  inspect!(bbox.max, content="{x: 5, y: 5}")
}

test "panic @gmlewis/fonts/vec2.BoundingBox::from_points/empty_array" {
  let points : Array[@gmlewis/fonts/vec2.Vec2] = []
  ignore(@gmlewis/fonts/vec2.BoundingBox::from_points(points))
}

test "@vec2.clone/basic" {
  let bbox = @vec2.BoundingBox::new(
    min=@vec2.vec2(1.0, 2.0),
    max=@vec2.vec2(3.0, 4.0),
  )
  let cloned = bbox.clone()
  inspect!(cloned.min.x, content="1")
  inspect!(cloned.min.y, content="2")
  inspect!(cloned.max.x, content="3")
  inspect!(cloned.max.y, content="4")
}

test "@vec2.clone/zero_size" {
  let bbox = @vec2.BoundingBox::new(
    min=@vec2.vec2(0.0, 0.0),
    max=@vec2.vec2(0.0, 0.0),
  )
  let cloned = bbox.clone()
  inspect!(cloned.min.x, content="0")
  inspect!(cloned.min.y, content="0")
  inspect!(cloned.max.x, content="0")
  inspect!(cloned.max.y, content="0")
}

test "@vec2.clone/negative_coords" {
  let bbox = @vec2.BoundingBox::new(
    min=@vec2.vec2(-2.0, -3.0),
    max=@vec2.vec2(-1.0, -1.0),
  )
  let cloned = bbox.clone()
  inspect!(cloned.min.x, content="-2")
  inspect!(cloned.min.y, content="-3")
  inspect!(cloned.max.x, content="-1")
  inspect!(cloned.max.y, content="-1")
}

test "@gmlewis/fonts/vec2.BoundingBox::center" {
  let bbox = @gmlewis/fonts/vec2.BoundingBox::new(
    min=@gmlewis/fonts/vec2.vec2(0.0, 0.0),
    max=@gmlewis/fonts/vec2.vec2(1.0, 1.0),
  )
  inspect!(bbox.center(), content="{x: 0.5, y: 0.5}")
}

test "@gmlewis/fonts/vec2.BoundingBox::center/negative-coordinates" {
  let bbox = @gmlewis/fonts/vec2.BoundingBox::new(
    min=@gmlewis/fonts/vec2.vec2(-1.0, -1.0),
    max=@gmlewis/fonts/vec2.vec2(1.0, 1.0),
  )
  inspect!(bbox.center(), content="{x: 0, y: 0}")
}

test "@gmlewis/fonts/vec2.BoundingBox::center/inf-values" {
  let bbox = @gmlewis/fonts/vec2.BoundingBox::new(
    min=@gmlewis/fonts/vec2.vec2(0.0, 0.0),
    max=@gmlewis/fonts/vec2.vec2(@double.infinity, @double.infinity),
  )
  inspect!(bbox.center(), content="{x: Infinity, y: Infinity}") // Expecting a panic due to invalid operations with infinity values.
}

test "@vec2.size" {
  // Test zero-sized bounding box
  let zero_box = @vec2.BoundingBox::new(
    min=@vec2.vec2(0, 0),
    max=@vec2.vec2(0, 0),
  )
  inspect!(zero_box.size(), content="{x: 0, y: 0}")

  // Test normal positive-sized bounding box
  let pos_box = @vec2.BoundingBox::new(
    min=@vec2.vec2(1, 2),
    max=@vec2.vec2(4, 6),
  )
  inspect!(pos_box.size(), content="{x: 3, y: 4}")

  // Test negative-sized bounding box
  let neg_box = @vec2.BoundingBox::new(
    min=@vec2.vec2(5, 5),
    max=@vec2.vec2(2, 3),
  )
  inspect!(neg_box.size(), content="{x: -3, y: -2}")
}

test "@vec2.width" {
  // Test normal case with positive coordinates
  let box1 = @vec2.BoundingBox::new(
    min=@vec2.vec2(1.0, 2.0),
    max=@vec2.vec2(4.0, 6.0),
  )
  inspect!(box1.width(), content="3")

  // Test case with zero width
  let box2 = @vec2.BoundingBox::new(
    min=@vec2.vec2(5.0, 1.0),
    max=@vec2.vec2(5.0, 10.0),
  )
  inspect!(box2.width(), content="0")

  // Test case with negative coordinates
  let box3 = @vec2.BoundingBox::new(
    min=@vec2.vec2(-3.0, -2.0),
    max=@vec2.vec2(2.0, 4.0),
  )
  inspect!(box3.width(), content="5")
}

test "@vec2.height" {
  let bbox = @vec2.BoundingBox::new(min=@vec2.vec2(0, 1), max=@vec2.vec2(10, 5))
  inspect!(bbox.height(), content="4")
  let zero_height = @vec2.BoundingBox::new(
    min=@vec2.vec2(0, 1),
    max=@vec2.vec2(10, 1),
  )
  inspect!(zero_height.height(), content="0")
  let negative_height = @vec2.BoundingBox::new(
    min=@vec2.vec2(0, 5),
    max=@vec2.vec2(10, 1),
  )
  inspect!(negative_height.height(), content="-4")
}

test "@vec2.area" {
  // Normal case: positive dimensions
  let box1 = @vec2.BoundingBox::new(min=@vec2.vec2(0, 0), max=@vec2.vec2(5, 4))
  inspect!(box1.area(), content="20")

  // Zero dimensions
  let box2 = @vec2.BoundingBox::new(min=@vec2.vec2(1, 1), max=@vec2.vec2(1, 1))
  inspect!(box2.area(), content="0")

  // Negative dimensions (min > max)
  let box3 = @vec2.BoundingBox::new(min=@vec2.vec2(5, 5), max=@vec2.vec2(2, 3))
  inspect!(box3.area(), content="6")
}

test "@gmlewis/fonts/vec2.BoundingBox::area/zero-width-and-height" {
  let bbox = @gmlewis/fonts/vec2.BoundingBox::new(
    min=@gmlewis/fonts/vec2.vec2(0.0, 0.0),
    max=@gmlewis/fonts/vec2.vec2(0.0, 0.0),
  )
  inspect!(bbox.area(), content="0")
}

test "@gmlewis/fonts/vec2.BoundingBox::area/positive-width-and-height-boundary" {
  let bbox = @gmlewis/fonts/vec2.BoundingBox::new(
    min=@gmlewis/fonts/vec2.vec2(0.0, 0.0),
    max=@gmlewis/fonts/vec2.vec2(1.0, 1.0),
  )
  inspect!(bbox.area(), content="1")
}

test "@gmlewis/fonts/vec2.BoundingBox::area/negative-width-and-height-boundary" {
  let bbox = @gmlewis/fonts/vec2.BoundingBox::new(
    min=@gmlewis/fonts/vec2.vec2(0.0, 0.0),
    max=@gmlewis/fonts/vec2.vec2(-1.0, -1.0),
  )
  inspect!(bbox.area(), content="1")
}

test "@vec2.BoundingBox::is_inf" {
  // Normal case - neither min nor max is infinite
  let bb1 = @vec2.BoundingBox::new(
    min=@vec2.vec2(1.0, 2.0),
    max=@vec2.vec2(3.0, 4.0),
  )
  inspect!(bb1.is_inf(), content="false")

  // Case where min has an infinite component
  let bb2 = @vec2.BoundingBox::new(
    min=@vec2.vec2(@double.infinity, 0.0),
    max=@vec2.vec2(3.0, 4.0),
  )
  inspect!(bb2.is_inf(), content="true")

  // Case where max has an infinite component
  let bb3 = @vec2.BoundingBox::new(
    min=@vec2.vec2(1.0, 2.0),
    max=@vec2.vec2(3.0, @double.infinity),
  )
  inspect!(bb3.is_inf(), content="true")
}

test "@vec2.BoundingBox::is_nan/both-normal" {
  let bbox = @vec2.BoundingBox::new(
    min=@vec2.vec2(1.0, 2.0),
    max=@vec2.vec2(3.0, 4.0),
  )
  inspect!(bbox.is_nan(), content="false")
}

test "@vec2.BoundingBox::is_nan/min-nan" {
  let bbox = @vec2.BoundingBox::new(
    min=@vec2.vec2(@double.not_a_number, 2.0),
    max=@vec2.vec2(3.0, 4.0),
  )
  inspect!(bbox.is_nan(), content="true")
}

test "@vec2.BoundingBox::is_nan/max-nan" {
  let bbox = @vec2.BoundingBox::new(
    min=@vec2.vec2(1.0, 2.0),
    max=@vec2.vec2(3.0, @double.not_a_number),
  )
  inspect!(bbox.is_nan(), content="true")
}

test "@gmlewis/fonts/vec2.BoundingBox::is_nan/basic_functionality" {
  let bbox1 = @gmlewis/fonts/vec2.BoundingBox::new(
    min=@gmlewis/fonts/vec2.vec2(0.0, 0.0),
    max=@gmlewis/fonts/vec2.vec2(1.0, 1.0),
  )
  inspect!(@gmlewis/fonts/vec2.BoundingBox::is_nan(bbox1), content="false")
  let bbox2 = @gmlewis/fonts/vec2.BoundingBox::new(
    min=@gmlewis/fonts/vec2.vec2(@moonbitlang/core/double.not_a_number, 0.0),
    max=@gmlewis/fonts/vec2.vec2(1.0, 1.0),
  )
  inspect!(@gmlewis/fonts/vec2.BoundingBox::is_nan(bbox2), content="true")
  let bbox3 = @gmlewis/fonts/vec2.BoundingBox::new(
    min=@gmlewis/fonts/vec2.vec2(0.0, 0.0),
    max=@gmlewis/fonts/vec2.vec2(1.0, @moonbitlang/core/double.not_a_number),
  )
  inspect!(@gmlewis/fonts/vec2.BoundingBox::is_nan(bbox3), content="true")
  let bbox4 = @gmlewis/fonts/vec2.BoundingBox::new(
    min=@gmlewis/fonts/vec2.vec2(
      @moonbitlang/core/double.not_a_number, @moonbitlang/core/double.not_a_number,
    ),
    max=@gmlewis/fonts/vec2.vec2(
      @moonbitlang/core/double.not_a_number, @moonbitlang/core/double.not_a_number,
    ),
  )
  inspect!(@gmlewis/fonts/vec2.BoundingBox::is_nan(bbox4), content="true")
}

test "@gmlewis/fonts/vec2.BoundingBox::is_nan/invalid_bbox" {
  let bbox = @gmlewis/fonts/vec2.BoundingBox::new(
    min=@gmlewis/fonts/vec2.vec2(@moonbitlang/core/double.infinity, 0.0),
    max=@gmlewis/fonts/vec2.vec2(1.0, 1.0),
  )
  inspect!(@gmlewis/fonts/vec2.BoundingBox::is_nan(bbox), content="false")
}

test "@vec2.BoundingBox::expand_to_include_point/basic" {
  let bbox = @vec2.BoundingBox::new(
    min=@vec2.vec2(0.0, 0.0),
    max=@vec2.vec2(1.0, 1.0),
  )
  let point = @vec2.vec2(2.0, 2.0)
  let result = bbox.expand_to_include_point(point)
  inspect!(result.min.x, content="0")
  inspect!(result.min.y, content="0")
  inspect!(result.max.x, content="2")
  inspect!(result.max.y, content="2")
}

test "@vec2.BoundingBox::expand_to_include_point/inside" {
  let bbox = @vec2.BoundingBox::new(
    min=@vec2.vec2(0.0, 0.0),
    max=@vec2.vec2(2.0, 2.0),
  )
  let point = @vec2.vec2(1.0, 1.0)
  let result = bbox.expand_to_include_point(point)
  inspect!(result.min.x, content="0")
  inspect!(result.min.y, content="0")
  inspect!(result.max.x, content="2")
  inspect!(result.max.y, content="2")
}

test "@vec2.BoundingBox::expand_to_include_point/negative" {
  let bbox = @vec2.BoundingBox::new(
    min=@vec2.vec2(0.0, 0.0),
    max=@vec2.vec2(1.0, 1.0),
  )
  let point = @vec2.vec2(-1.0, -1.0)
  let result = bbox.expand_to_include_point(point)
  inspect!(result.min.x, content="-1")
  inspect!(result.min.y, content="-1")
  inspect!(result.max.x, content="1")
  inspect!(result.max.y, content="1")
}

test "@vec2.BoundingBox::expand_to_include_bounding_box" {
  // Test case where the second box is completely outside the first box
  let box1 = @vec2.BoundingBox::new(
    min=@vec2.vec2(0.0, 0.0),
    max=@vec2.vec2(1.0, 1.0),
  )
  let box2 = @vec2.BoundingBox::new(
    min=@vec2.vec2(2.0, 2.0),
    max=@vec2.vec2(3.0, 3.0),
  )
  let result = box1.expand_to_include_bounding_box(box2)
  inspect!(result.min.x, content="0")
  inspect!(result.min.y, content="0")
  inspect!(result.max.x, content="3")
  inspect!(result.max.y, content="3")
}

test "@vec2.BoundingBox::expand_to_include_bounding_box/partially_overlapping" {
  // Test case where the boxes partially overlap
  let box1 = @vec2.BoundingBox::new(
    min=@vec2.vec2(0.0, 0.0),
    max=@vec2.vec2(2.0, 2.0),
  )
  let box2 = @vec2.BoundingBox::new(
    min=@vec2.vec2(1.0, 1.0),
    max=@vec2.vec2(3.0, 3.0),
  )
  let result = box1.expand_to_include_bounding_box(box2)
  inspect!(result.min.x, content="0")
  inspect!(result.min.y, content="0")
  inspect!(result.max.x, content="3")
  inspect!(result.max.y, content="3")
}

test "@vec2.BoundingBox::expand_to_include_bounding_box/fully_contained" {
  // Test case where one box is completely inside the other
  let box1 = @vec2.BoundingBox::new(
    min=@vec2.vec2(0.0, 0.0),
    max=@vec2.vec2(4.0, 4.0),
  )
  let box2 = @vec2.BoundingBox::new(
    min=@vec2.vec2(1.0, 1.0),
    max=@vec2.vec2(2.0, 2.0),
  )
  let result = box1.expand_to_include_bounding_box(box2)
  inspect!(result.min.x, content="0")
  inspect!(result.min.y, content="0")
  inspect!(result.max.x, content="4")
  inspect!(result.max.y, content="4")
}

test "@vec2.BoundingBox::expand_scalar/zero" {
  let bbox = @vec2.BoundingBox::new(
    min=@vec2.vec2(1.0, 1.0),
    max=@vec2.vec2(2.0, 2.0),
  )
  let result = bbox.expand_scalar(0.0)
  inspect!(result.min.x, content="1")
  inspect!(result.min.y, content="1")
  inspect!(result.max.x, content="2")
  inspect!(result.max.y, content="2")
}

test "@vec2.BoundingBox::expand_scalar/positive" {
  let bbox = @vec2.BoundingBox::new(
    min=@vec2.vec2(0.0, 0.0),
    max=@vec2.vec2(1.0, 1.0),
  )
  let result = bbox.expand_scalar(2.0)
  inspect!(result.min.x, content="-2")
  inspect!(result.min.y, content="-2")
  inspect!(result.max.x, content="3")
  inspect!(result.max.y, content="3")
}

test "@vec2.BoundingBox::expand_scalar/negative" {
  let bbox = @vec2.BoundingBox::new(
    min=@vec2.vec2(-1.0, -1.0),
    max=@vec2.vec2(1.0, 1.0),
  )
  let result = bbox.expand_scalar(-0.5)
  inspect!(result.min.x, content="-0.5")
  inspect!(result.min.y, content="-0.5")
  inspect!(result.max.x, content="0.5")
  inspect!(result.max.y, content="0.5")
}

test "@vec2.BoundingBox::contains_point/inside" {
  let bbox = @vec2.BoundingBox::new(
    min=@vec2.vec2(0.0, 0.0),
    max=@vec2.vec2(10.0, 10.0),
  )
  let point = @vec2.vec2(5.0, 5.0)
  inspect!(bbox.contains_point(point), content="true")
}

test "@vec2.BoundingBox::contains_point/edges" {
  let bbox = @vec2.BoundingBox::new(
    min=@vec2.vec2(-1.0, -1.0),
    max=@vec2.vec2(1.0, 1.0),
  )
  // Test points on all edges
  let left = @vec2.vec2(-1.0, 0.0)
  let right = @vec2.vec2(1.0, 0.0)
  let top = @vec2.vec2(0.0, 1.0)
  let bottom = @vec2.vec2(0.0, -1.0)
  inspect!(bbox.contains_point(left), content="true")
  inspect!(bbox.contains_point(right), content="true")
  inspect!(bbox.contains_point(top), content="true")
  inspect!(bbox.contains_point(bottom), content="true")
}

test "@vec2.BoundingBox::contains_point/outside" {
  let bbox = @vec2.BoundingBox::new(
    min=@vec2.vec2(0.0, 0.0),
    max=@vec2.vec2(1.0, 1.0),
  )
  let left = @vec2.vec2(-0.1, 0.5)
  let right = @vec2.vec2(1.1, 0.5)
  let top = @vec2.vec2(0.5, 1.1)
  let bottom = @vec2.vec2(0.5, -0.1)
  inspect!(bbox.contains_point(left), content="false")
  inspect!(bbox.contains_point(right), content="false")
  inspect!(bbox.contains_point(top), content="false")
  inspect!(bbox.contains_point(bottom), content="false")
}

test "@vec2.overlaps_bounding_box/no-overlap" {
  // Two non-overlapping boxes
  let box1 = @vec2.BoundingBox::new(
    min=@vec2.vec2(0.0, 0.0),
    max=@vec2.vec2(1.0, 1.0),
  )
  let box2 = @vec2.BoundingBox::new(
    min=@vec2.vec2(2.0, 2.0),
    max=@vec2.vec2(3.0, 3.0),
  )
  inspect!(box1.overlaps_bounding_box(box2), content="false")
}

test "@vec2.overlaps_bounding_box/complete-overlap" {
  // One box completely inside another
  let outer = @vec2.BoundingBox::new(
    min=@vec2.vec2(0.0, 0.0),
    max=@vec2.vec2(4.0, 4.0),
  )
  let inner = @vec2.BoundingBox::new(
    min=@vec2.vec2(1.0, 1.0),
    max=@vec2.vec2(2.0, 2.0),
  )
  inspect!(outer.overlaps_bounding_box(inner), content="true")
}

test "@vec2.overlaps_bounding_box/partial-overlap" {
  // Two boxes that partially overlap
  let box1 = @vec2.BoundingBox::new(
    min=@vec2.vec2(0.0, 0.0),
    max=@vec2.vec2(2.0, 2.0),
  )
  let box2 = @vec2.BoundingBox::new(
    min=@vec2.vec2(1.0, 1.0),
    max=@vec2.vec2(3.0, 3.0),
  )
  inspect!(box1.overlaps_bounding_box(box2), content="false")
}

test "@vec2.BoundingBox::overlaps_bounding_box/basic-functionality" {
  let bbox1 = @vec2.BoundingBox::new(min=@vec2.vec2(0, 0), max=@vec2.vec2(5, 5))
  let bbox2 = @vec2.BoundingBox::new(min=@vec2.vec2(3, 3), max=@vec2.vec2(7, 7))
  inspect!(@vec2.overlaps_bounding_box(bbox1, bbox2), content="false")
  let bbox3 = @vec2.BoundingBox::new(min=@vec2.vec2(7, 7), max=@vec2.vec2(9, 9))
  inspect!(@vec2.overlaps_bounding_box(bbox1, bbox3), content="false")
}

test "@vec2.BoundingBox::overlaps_bounding_box/edge-cases" {
  let bbox1 = @vec2.BoundingBox::new(min=@vec2.vec2(0, 0), max=@vec2.vec2(5, 5))
  let bbox2 = @vec2.BoundingBox::new(min=@vec2.vec2(5, 5), max=@vec2.vec2(5, 5))
  inspect!(@vec2.overlaps_bounding_box(bbox1, bbox2), content="true")
  let bbox3 = @vec2.BoundingBox::new(min=@vec2.vec2(6, 6), max=@vec2.vec2(6, 6))
  inspect!(@vec2.overlaps_bounding_box(bbox1, bbox3), content="false")
  let bbox4 = @vec2.BoundingBox::new(
    min=@vec2.vec2(-1, -1),
    max=@vec2.vec2(1, 1),
  )
  inspect!(@vec2.overlaps_bounding_box(bbox1, bbox4), content="false")
}

test "@vec2.BoundingBox::overlaps_bounding_box/negative-coordinates" {
  let bbox1 = @vec2.BoundingBox::new(
    min=@vec2.vec2(-5, -5),
    max=@vec2.vec2(0, 0),
  )
  let bbox2 = @vec2.BoundingBox::new(
    min=@vec2.vec2(-3, -3),
    max=@vec2.vec2(2, 2),
  )
  inspect!(@vec2.overlaps_bounding_box(bbox1, bbox2), content="false")
  let bbox3 = @vec2.BoundingBox::new(
    min=@vec2.vec2(-6, -6),
    max=@vec2.vec2(-5, -5),
  )
  inspect!(@vec2.overlaps_bounding_box(bbox1, bbox3), content="false")
  let bbox4 = @vec2.BoundingBox::new(min=@vec2.vec2(1, 1), max=@vec2.vec2(2, 2))
  inspect!(@vec2.overlaps_bounding_box(bbox1, bbox4), content="false")
}
