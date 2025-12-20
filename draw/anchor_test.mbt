///|
test "Anchor::new/default" {
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
test "affine_transform/identity" {
  let anchor = Anchor::new(
    position=vec2(1.0, 2.0),
    handle_in=vec2(0.5, 0.5),
    handle_out=vec2(-0.5, -0.5),
  )
  let matrix = AffineMatrix::new() // Identity matrix
  let result = anchor.affine_transform(matrix)
  inspect(result.position, content="{x: 1, y: 2}")
}

///|
test "Anchor::is_contained_by_bounding_box" {
  let pos = vec2(1, 1)
  let box = BoundingBox::new(min=vec2(0, 0), max=vec2(2, 2))
  let anchor = Anchor::new(position=pos)
  inspect(anchor.is_contained_by_bounding_box(box), content="true")
}

///|
test "Anchor::reverse" {
  let anchor = Anchor::new(
    position=vec2(1.0, 1.0),
    handle_in=vec2(2.0, 3.0),
    handle_out=vec2(4.0, 5.0),
  )
  let reversed_anchor = anchor.reverse()
  inspect(reversed_anchor.handle_in, content="{x: 4, y: 5}")
  inspect(reversed_anchor.handle_out, content="{x: 2, y: 3}")
}
