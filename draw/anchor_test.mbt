///|
test "Anchor::new/default 1" {
  let anchor = Anchor::new()
  inspect(
    anchor,
    content="{position: {x: 0, y: 0}, handle_in: {x: 0, y: 0}, handle_out: {x: 0, y: 0}}",
  )
}

///|
test "Anchor::new/custom-position" {
  let pos = vec2(1, 2)
  let anchor = Anchor::new(position=pos)
  inspect(
    anchor,
    content="{position: {x: 1, y: 2}, handle_in: {x: 0, y: 0}, handle_out: {x: 0, y: 0}}",
  )
}

///|
test "Anchor::new/all-params" {
  let pos = vec2(1, 2)
  let hin = vec2(3, 4)
  let hout = vec2(5, 6)
  let anchor = Anchor::new(position=pos, handle_in=hin, handle_out=hout)
  inspect(
    anchor,
    content="{position: {x: 1, y: 2}, handle_in: {x: 3, y: 4}, handle_out: {x: 5, y: 6}}",
  )
}

///|
test "Anchor::new/default 2" {
  let default_anchor = Anchor::new()
  inspect(default_anchor.position, content="{x: 0, y: 0}")
  inspect(default_anchor.handle_in, content="{x: 0, y: 0}")
  inspect(default_anchor.handle_out, content="{x: 0, y: 0}")
}

///|
test "Anchor::new/custom" {
  let custom_position = vec2(1.5, -2.5)
  let custom_handle_in = vec2(-3.0, 0.0)
  let custom_handle_out = vec2(2.0, 4.0)
  let anchor = Anchor::new(
    position=custom_position,
    handle_in=custom_handle_in,
    handle_out=custom_handle_out,
  )
  inspect(anchor.position, content="{x: 1.5, y: -2.5}")
  inspect(anchor.handle_in, content="{x: -3, y: 0}")
  inspect(anchor.handle_out, content="{x: 2, y: 4}")
}

///|
test "Anchor::new/partial_custom" {
  let custom_handle_in = vec2(-1.0, 1.0)
  let anchor = Anchor::new(handle_in=custom_handle_in)
  inspect(anchor.position, content="{x: 0, y: 0}")
  inspect(anchor.handle_in, content="{x: -1, y: 1}")
  inspect(anchor.handle_out, content="{x: 0, y: 0}")
}

///|
test "affine_transform/identity" {
  let anchor = Anchor::new(
    position=vec2(1.0, 2.0),
    handle_in=vec2(0.5, 0.5),
    handle_out=vec2(-0.5, -0.5),
  )
  let matrix = AffineMatrix::new() // Identity matrix
  let result = anchor.affine_transform(matrix)
  inspect(result.position, content="{x: 1, y: 2}")
  inspect(result.handle_in, content="{x: 0.5, y: 0.5}")
  inspect(result.handle_out, content="{x: -0.5, y: -0.5}")
}

///|
test "affine_transform/translation" {
  let anchor = Anchor::new(
    position=vec2(1.0, 1.0),
    handle_in=vec2(1.0, 1.0),
    handle_out=vec2(1.0, 1.0),
  )
  let matrix = AffineMatrix::new(tx=2.0, ty=3.0) // Translation only
  let result = anchor.affine_transform(matrix)
  // Position should be translated
  inspect(result.position, content="{x: 3, y: 4}")
  // Handles should not be affected by translation
  inspect(result.handle_in, content="{x: 1, y: 1}")
  inspect(result.handle_out, content="{x: 1, y: 1}")
}

///|
test "affine_transform/scale-and-rotate" {
  let anchor = Anchor::new(
    position=vec2(1.0, 0.0),
    handle_in=vec2(1.0, 0.0),
    handle_out=vec2(1.0, 0.0),
  )
  // Scale by 2 and rotate 90 degrees
  let matrix = AffineMatrix::new(a=0.0, b=2.0, c=-2.0, d=0.0)
  let result = anchor.affine_transform(matrix)
  // Both position and handles should be scaled and rotated
  inspect(result.position, content="{x: 0, y: 2}")
  inspect(result.handle_in, content="{x: 0, y: 2}")
  inspect(result.handle_out, content="{x: 0, y: 2}")
}

///|
test "affine_transform_without_translation/identity" {
  let anchor = Anchor::new(
    position=vec2(1.0, 2.0),
    handle_in=vec2(0.5, 0.5),
    handle_out=vec2(-0.5, -0.5),
  )
  let matrix = AffineMatrix::new() // identity matrix
  let result = anchor.affine_transform_without_translation(matrix)
  inspect(result.position, content="{x: 1, y: 2}")
  inspect(result.handle_in, content="{x: 0.5, y: 0.5}")
  inspect(result.handle_out, content="{x: -0.5, y: -0.5}")
}

///|
test "affine_transform_without_translation/rotation" {
  let anchor = Anchor::new(
    position=vec2(1.0, 0.0),
    handle_in=vec2(1.0, 0.0),
    handle_out=vec2(0.0, 1.0),
  )
  // 90-degree rotation matrix
  let matrix = AffineMatrix::new(a=0.0, b=1.0, c=-1.0, d=0.0)
  let result = anchor.affine_transform_without_translation(matrix)
  inspect(result.position, content="{x: 0, y: 1}")
  inspect(result.handle_in, content="{x: 0, y: 1}")
  inspect(result.handle_out, content="{x: -1, y: 0}")
}

///|
test "affine_transform_without_translation/scale" {
  let anchor = Anchor::new(
    position=vec2(2.0, 3.0),
    handle_in=vec2(1.0, 1.0),
    handle_out=vec2(-1.0, -1.0),
  )
  // Scale matrix (2x horizontally, 0.5x vertically)
  let matrix = AffineMatrix::new(a=2.0, d=0.5)
  let result = anchor.affine_transform_without_translation(matrix)
  inspect(result.position, content="{x: 4, y: 1.5}")
  inspect(result.handle_in, content="{x: 2, y: 0.5}")
  inspect(result.handle_out, content="{x: -2, y: -0.5}")
}

///|
test "Anchor::is_contained_by_bounding_box/inside" {
  let pos = vec2(1, 1)
  let box = BoundingBox::new(min=vec2(0, 0), max=vec2(2, 2))
  let anchor = Anchor::new(position=pos)
  inspect(anchor.is_contained_by_bounding_box(box), content="true")
}

///|
test "Anchor::is_contained_by_bounding_box/on_boundary" {
  let pos = vec2(0, 0)
  let box = BoundingBox::new(min=vec2(0, 0), max=vec2(2, 2))
  let anchor = Anchor::new(position=pos)
  inspect(anchor.is_contained_by_bounding_box(box), content="true")
}

///|
test "Anchor::is_contained_by_bounding_box/outside" {
  let pos = vec2(3, 3)
  let box = BoundingBox::new(min=vec2(0, 0), max=vec2(2, 2))
  let anchor = Anchor::new(position=pos)
  inspect(anchor.is_contained_by_bounding_box(box), content="false")
}

///|
test "reverse/basic_functionality" {
  let anchor = Anchor::new(
    position=vec2(1.0, 1.0),
    handle_in=vec2(2.0, 3.0),
    handle_out=vec2(4.0, 5.0),
  )
  let reversed_anchor = Anchor::reverse(anchor)
  inspect(reversed_anchor.handle_in, content="{x: 4, y: 5}")
  inspect(reversed_anchor.handle_out, content="{x: 2, y: 3}")
}

///|
test "reverse/identical_handles" {
  let anchor = Anchor::new(handle_in=vec2(2.0, 2.0), handle_out=vec2(2.0, 2.0))
  let reversed_anchor = Anchor::reverse(anchor)
  inspect(reversed_anchor.handle_in, content="{x: 2, y: 2}")
  inspect(reversed_anchor.handle_out, content="{x: 2, y: 2}")
}

///|
test "reverse/zero_handles" {
  let anchor = Anchor::new(
    position=vec2(0.0, 0.0),
    handle_in=vec2(0.0, 0.0),
    handle_out=vec2(0.0, 0.0),
  )
  let reversed_anchor = Anchor::reverse(anchor)
  inspect(reversed_anchor.handle_in, content="{x: 0, y: 0}")
  inspect(reversed_anchor.handle_out, content="{x: 0, y: 0}")
}

///|
test "Anchor::to_json" {
  let v = Anchor::new(
    position=vec2(1, 2),
    handle_in=vec2(1.1, 2.1),
    handle_out=vec2(1.2, 2.2),
  )
  let got = v.to_json().stringify()
  inspect(
    got,
    content=(
      #|{"position":{"x":1,"y":2},"handle_in":{"x":1.1,"y":2.1},"handle_out":{"x":1.2,"y":2.2}}
    ),
  )
}

///|
test "Anchor::from_json" {
  let json_str =
    #|{"position":{"x":1,"y":2},"handle_in":{"x":1.1,"y":2.1},"handle_out":{"x":1.2,"y":2.2}}
  let json = @json.parse(json_str)
  let got : Anchor = @json.from_json(json)
  inspect(
    got,
    content="{position: {x: 1, y: 2}, handle_in: {x: 1.1, y: 2.1}, handle_out: {x: 1.2, y: 2.2}}",
  )
}
