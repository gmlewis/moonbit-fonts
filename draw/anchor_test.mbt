test "@draw.Anchor::new/default" {
  let anchor = @draw.Anchor::new()
  inspect!(
    anchor,
    content="{position: {x: 0, y: 0}, handle_in: {x: 0, y: 0}, handle_out: {x: 0, y: 0}}",
  )
}

test "@draw.Anchor::new/custom-position" {
  let pos = @draw.vec2(1, 2)
  let anchor = @draw.Anchor::new(position=pos)
  inspect!(
    anchor,
    content="{position: {x: 1, y: 2}, handle_in: {x: 0, y: 0}, handle_out: {x: 0, y: 0}}",
  )
}

test "@draw.Anchor::new/all-params" {
  let pos = @draw.vec2(1, 2)
  let hin = @draw.vec2(3, 4)
  let hout = @draw.vec2(5, 6)
  let anchor = @draw.Anchor::new(position=pos, handle_in=hin, handle_out=hout)
  inspect!(
    anchor,
    content="{position: {x: 1, y: 2}, handle_in: {x: 3, y: 4}, handle_out: {x: 5, y: 6}}",
  )
}

test "@draw.Anchor::new/default" {
  let default_anchor = @draw.Anchor::new()
  inspect!(default_anchor.position, content="{x: 0, y: 0}")
  inspect!(default_anchor.handle_in, content="{x: 0, y: 0}")
  inspect!(default_anchor.handle_out, content="{x: 0, y: 0}")
}

test "@draw.Anchor::new/custom" {
  let custom_position = @draw.vec2(1.5, -2.5)
  let custom_handle_in = @draw.vec2(-3.0, 0.0)
  let custom_handle_out = @draw.vec2(2.0, 4.0)
  let anchor = @draw.Anchor::new(
    position=custom_position,
    handle_in=custom_handle_in,
    handle_out=custom_handle_out,
  )
  inspect!(anchor.position, content="{x: 1.5, y: -2.5}")
  inspect!(anchor.handle_in, content="{x: -3, y: 0}")
  inspect!(anchor.handle_out, content="{x: 2, y: 4}")
}

test "@draw.Anchor::new/partial_custom" {
  let custom_handle_in = @draw.vec2(-1.0, 1.0)
  let anchor = @draw.Anchor::new(handle_in=custom_handle_in)
  inspect!(anchor.position, content="{x: 0, y: 0}")
  inspect!(anchor.handle_in, content="{x: -1, y: 1}")
  inspect!(anchor.handle_out, content="{x: 0, y: 0}")
}

test "@draw.affine_transform/identity" {
  let anchor = @draw.Anchor::new(
    position=@draw.vec2(1.0, 2.0),
    handle_in=@draw.vec2(0.5, 0.5),
    handle_out=@draw.vec2(-0.5, -0.5),
  )
  let matrix = @draw.AffineMatrix::new() // Identity matrix
  let result = anchor.affine_transform(matrix)
  inspect!(result.position, content="{x: 1, y: 2}")
  inspect!(result.handle_in, content="{x: 0.5, y: 0.5}")
  inspect!(result.handle_out, content="{x: -0.5, y: -0.5}")
}

test "@draw.affine_transform/translation" {
  let anchor = @draw.Anchor::new(
    position=@draw.vec2(1.0, 1.0),
    handle_in=@draw.vec2(1.0, 1.0),
    handle_out=@draw.vec2(1.0, 1.0),
  )
  let matrix = @draw.AffineMatrix::new(tx=2.0, ty=3.0) // Translation only
  let result = anchor.affine_transform(matrix)
  // Position should be translated
  inspect!(result.position, content="{x: 3, y: 4}")
  // Handles should not be affected by translation
  inspect!(result.handle_in, content="{x: 1, y: 1}")
  inspect!(result.handle_out, content="{x: 1, y: 1}")
}

test "@draw.affine_transform/scale-and-rotate" {
  let anchor = @draw.Anchor::new(
    position=@draw.vec2(1.0, 0.0),
    handle_in=@draw.vec2(1.0, 0.0),
    handle_out=@draw.vec2(1.0, 0.0),
  )
  // Scale by 2 and rotate 90 degrees
  let matrix = @draw.AffineMatrix::new(a=0.0, b=2.0, c=-2.0, d=0.0)
  let result = anchor.affine_transform(matrix)
  // Both position and handles should be scaled and rotated
  inspect!(result.position, content="{x: 0, y: 2}")
  inspect!(result.handle_in, content="{x: 0, y: 2}")
  inspect!(result.handle_out, content="{x: 0, y: 2}")
}

test "@draw.affine_transform_without_translation/identity" {
  let anchor = @draw.Anchor::new(
    position=@draw.vec2(1.0, 2.0),
    handle_in=@draw.vec2(0.5, 0.5),
    handle_out=@draw.vec2(-0.5, -0.5),
  )
  let matrix = @draw.AffineMatrix::new() // identity matrix
  let result = anchor.affine_transform_without_translation(matrix)
  inspect!(result.position, content="{x: 1, y: 2}")
  inspect!(result.handle_in, content="{x: 0.5, y: 0.5}")
  inspect!(result.handle_out, content="{x: -0.5, y: -0.5}")
}

test "@draw.affine_transform_without_translation/rotation" {
  let anchor = @draw.Anchor::new(
    position=@draw.vec2(1.0, 0.0),
    handle_in=@draw.vec2(1.0, 0.0),
    handle_out=@draw.vec2(0.0, 1.0),
  )
  // 90-degree rotation matrix
  let matrix = @draw.AffineMatrix::new(a=0.0, b=1.0, c=-1.0, d=0.0)
  let result = anchor.affine_transform_without_translation(matrix)
  inspect!(result.position, content="{x: 0, y: 1}")
  inspect!(result.handle_in, content="{x: 0, y: 1}")
  inspect!(result.handle_out, content="{x: -1, y: 0}")
}

test "@draw.affine_transform_without_translation/scale" {
  let anchor = @draw.Anchor::new(
    position=@draw.vec2(2.0, 3.0),
    handle_in=@draw.vec2(1.0, 1.0),
    handle_out=@draw.vec2(-1.0, -1.0),
  )
  // Scale matrix (2x horizontally, 0.5x vertically)
  let matrix = @draw.AffineMatrix::new(a=2.0, d=0.5)
  let result = anchor.affine_transform_without_translation(matrix)
  inspect!(result.position, content="{x: 4, y: 1.5}")
  inspect!(result.handle_in, content="{x: 2, y: 0.5}")
  inspect!(result.handle_out, content="{x: -2, y: -0.5}")
}

test "@draw.Anchor::is_contained_by_bounding_box/inside" {
  let pos = @draw.vec2(1, 1)
  let box = @draw.BoundingBox::new(min=@draw.vec2(0, 0), max=@draw.vec2(2, 2))
  let anchor = @draw.Anchor::new(position=pos)
  inspect!(anchor.is_contained_by_bounding_box(box), content="true")
}

test "@draw.Anchor::is_contained_by_bounding_box/on_boundary" {
  let pos = @draw.vec2(0, 0)
  let box = @draw.BoundingBox::new(min=@draw.vec2(0, 0), max=@draw.vec2(2, 2))
  let anchor = @draw.Anchor::new(position=pos)
  inspect!(anchor.is_contained_by_bounding_box(box), content="true")
}

test "@draw.Anchor::is_contained_by_bounding_box/outside" {
  let pos = @draw.vec2(3, 3)
  let box = @draw.BoundingBox::new(min=@draw.vec2(0, 0), max=@draw.vec2(2, 2))
  let anchor = @draw.Anchor::new(position=pos)
  inspect!(anchor.is_contained_by_bounding_box(box), content="false")
}

test "@draw.reverse/basic_functionality" {
  let anchor = @draw.Anchor::new(
    position=@draw.vec2(1.0, 1.0),
    handle_in=@draw.vec2(2.0, 3.0),
    handle_out=@draw.vec2(4.0, 5.0),
  )
  let reversed_anchor = @draw.Anchor::reverse(anchor)
  inspect!(reversed_anchor.handle_in, content="{x: 4, y: 5}")
  inspect!(reversed_anchor.handle_out, content="{x: 2, y: 3}")
}

test "@draw.reverse/identical_handles" {
  let anchor = @draw.Anchor::new(
    handle_in=@draw.vec2(2.0, 2.0),
    handle_out=@draw.vec2(2.0, 2.0),
  )
  let reversed_anchor = @draw.Anchor::reverse(anchor)
  inspect!(reversed_anchor.handle_in, content="{x: 2, y: 2}")
  inspect!(reversed_anchor.handle_out, content="{x: 2, y: 2}")
}

test "@draw.reverse/zero_handles" {
  let anchor = @draw.Anchor::new(
    position=@draw.vec2(0.0, 0.0),
    handle_in=@draw.vec2(0.0, 0.0),
    handle_out=@draw.vec2(0.0, 0.0),
  )
  let reversed_anchor = @draw.Anchor::reverse(anchor)
  inspect!(reversed_anchor.handle_in, content="{x: 0, y: 0}")
  inspect!(reversed_anchor.handle_out, content="{x: 0, y: 0}")
}
