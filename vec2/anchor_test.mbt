test "@vec2.Anchor::new/default" {
  let anchor = @vec2.Anchor::new()
  inspect!(
    anchor,
    content="{position: {x: 0, y: 0}, handle_in: {x: 0, y: 0}, handle_out: {x: 0, y: 0}}",
  )
}

test "@vec2.Anchor::new/custom-position" {
  let pos = @vec2.vec2(1, 2)
  let anchor = @vec2.Anchor::new(position=pos)
  inspect!(
    anchor,
    content="{position: {x: 1, y: 2}, handle_in: {x: 0, y: 0}, handle_out: {x: 0, y: 0}}",
  )
}

test "@vec2.Anchor::new/all-params" {
  let pos = @vec2.vec2(1, 2)
  let hin = @vec2.vec2(3, 4)
  let hout = @vec2.vec2(5, 6)
  let anchor = @vec2.Anchor::new(position=pos, handle_in=hin, handle_out=hout)
  inspect!(
    anchor,
    content="{position: {x: 1, y: 2}, handle_in: {x: 3, y: 4}, handle_out: {x: 5, y: 6}}",
  )
}

test "@gmlewis/fonts/vec2.Anchor::new/default" {
  let default_anchor = @gmlewis/fonts/vec2.Anchor::new()
  inspect!(default_anchor.position, content="{x: 0, y: 0}")
  inspect!(default_anchor.handle_in, content="{x: 0, y: 0}")
  inspect!(default_anchor.handle_out, content="{x: 0, y: 0}")
}

test "@gmlewis/fonts/vec2.Anchor::new/custom" {
  let custom_position = @gmlewis/fonts/vec2.vec2(1.5, -2.5)
  let custom_handle_in = @gmlewis/fonts/vec2.vec2(-3.0, 0.0)
  let custom_handle_out = @gmlewis/fonts/vec2.vec2(2.0, 4.0)
  let anchor = @gmlewis/fonts/vec2.Anchor::new(
    position=custom_position,
    handle_in=custom_handle_in,
    handle_out=custom_handle_out,
  )
  inspect!(anchor.position, content="{x: 1.5, y: -2.5}")
  inspect!(anchor.handle_in, content="{x: -3, y: 0}")
  inspect!(anchor.handle_out, content="{x: 2, y: 4}")
}

test "@gmlewis/fonts/vec2.Anchor::new/partial_custom" {
  let custom_handle_in = @gmlewis/fonts/vec2.vec2(-1.0, 1.0)
  let anchor = @gmlewis/fonts/vec2.Anchor::new(handle_in=custom_handle_in)
  inspect!(anchor.position, content="{x: 0, y: 0}")
  inspect!(anchor.handle_in, content="{x: -1, y: 1}")
  inspect!(anchor.handle_out, content="{x: 0, y: 0}")
}

test "@vec2.affine_transform/identity" {
  let anchor = @vec2.Anchor::new(
    position=@vec2.vec2(1.0, 2.0),
    handle_in=@vec2.vec2(0.5, 0.5),
    handle_out=@vec2.vec2(-0.5, -0.5),
  )
  let matrix = @vec2.AffineMatrix::new() // Identity matrix
  let result = anchor.affine_transform(matrix)
  inspect!(result.position, content="{x: 1, y: 2}")
  inspect!(result.handle_in, content="{x: 0.5, y: 0.5}")
  inspect!(result.handle_out, content="{x: -0.5, y: -0.5}")
}

test "@vec2.affine_transform/translation" {
  let anchor = @vec2.Anchor::new(
    position=@vec2.vec2(1.0, 1.0),
    handle_in=@vec2.vec2(1.0, 1.0),
    handle_out=@vec2.vec2(1.0, 1.0),
  )
  let matrix = @vec2.AffineMatrix::new(tx=2.0, ty=3.0) // Translation only
  let result = anchor.affine_transform(matrix)
  // Position should be translated
  inspect!(result.position, content="{x: 3, y: 4}")
  // Handles should not be affected by translation
  inspect!(result.handle_in, content="{x: 1, y: 1}")
  inspect!(result.handle_out, content="{x: 1, y: 1}")
}

test "@vec2.affine_transform/scale-and-rotate" {
  let anchor = @vec2.Anchor::new(
    position=@vec2.vec2(1.0, 0.0),
    handle_in=@vec2.vec2(1.0, 0.0),
    handle_out=@vec2.vec2(1.0, 0.0),
  )
  // Scale by 2 and rotate 90 degrees
  let matrix = @vec2.AffineMatrix::new(a=0.0, b=2.0, c=-2.0, d=0.0)
  let result = anchor.affine_transform(matrix)
  // Both position and handles should be scaled and rotated
  inspect!(result.position, content="{x: 0, y: 2}")
  inspect!(result.handle_in, content="{x: 0, y: 2}")
  inspect!(result.handle_out, content="{x: 0, y: 2}")
}

test "@vec2.affine_transform_without_translation/identity" {
  let anchor = @vec2.Anchor::new(
    position=@vec2.vec2(1.0, 2.0),
    handle_in=@vec2.vec2(0.5, 0.5),
    handle_out=@vec2.vec2(-0.5, -0.5),
  )
  let matrix = @vec2.AffineMatrix::new() // identity matrix
  let result = anchor.affine_transform_without_translation(matrix)
  inspect!(result.position, content="{x: 1, y: 2}")
  inspect!(result.handle_in, content="{x: 0.5, y: 0.5}")
  inspect!(result.handle_out, content="{x: -0.5, y: -0.5}")
}

test "@vec2.affine_transform_without_translation/rotation" {
  let anchor = @vec2.Anchor::new(
    position=@vec2.vec2(1.0, 0.0),
    handle_in=@vec2.vec2(1.0, 0.0),
    handle_out=@vec2.vec2(0.0, 1.0),
  )
  // 90-degree rotation matrix
  let matrix = @vec2.AffineMatrix::new(a=0.0, b=1.0, c=-1.0, d=0.0)
  let result = anchor.affine_transform_without_translation(matrix)
  inspect!(result.position, content="{x: 0, y: 1}")
  inspect!(result.handle_in, content="{x: 0, y: 1}")
  inspect!(result.handle_out, content="{x: -1, y: 0}")
}

test "@vec2.affine_transform_without_translation/scale" {
  let anchor = @vec2.Anchor::new(
    position=@vec2.vec2(2.0, 3.0),
    handle_in=@vec2.vec2(1.0, 1.0),
    handle_out=@vec2.vec2(-1.0, -1.0),
  )
  // Scale matrix (2x horizontally, 0.5x vertically)
  let matrix = @vec2.AffineMatrix::new(a=2.0, d=0.5)
  let result = anchor.affine_transform_without_translation(matrix)
  inspect!(result.position, content="{x: 4, y: 1.5}")
  inspect!(result.handle_in, content="{x: 2, y: 0.5}")
  inspect!(result.handle_out, content="{x: -2, y: -0.5}")
}

test "@vec2.Anchor::is_contained_by_bounding_box/inside" {
  let pos = @vec2.vec2(1, 1)
  let box = @vec2.BoundingBox::new(min=@vec2.vec2(0, 0), max=@vec2.vec2(2, 2))
  let anchor = @vec2.Anchor::new(position=pos)
  inspect!(anchor.is_contained_by_bounding_box(box), content="true")
}

test "@vec2.Anchor::is_contained_by_bounding_box/on_boundary" {
  let pos = @vec2.vec2(0, 0)
  let box = @vec2.BoundingBox::new(min=@vec2.vec2(0, 0), max=@vec2.vec2(2, 2))
  let anchor = @vec2.Anchor::new(position=pos)
  inspect!(anchor.is_contained_by_bounding_box(box), content="true")
}

test "@vec2.Anchor::is_contained_by_bounding_box/outside" {
  let pos = @vec2.vec2(3, 3)
  let box = @vec2.BoundingBox::new(min=@vec2.vec2(0, 0), max=@vec2.vec2(2, 2))
  let anchor = @vec2.Anchor::new(position=pos)
  inspect!(anchor.is_contained_by_bounding_box(box), content="false")
}

test "@vec2.reverse/basic_functionality" {
  let anchor = @vec2.Anchor::new(
    position=@vec2.vec2(1.0, 1.0),
    handle_in=@vec2.vec2(2.0, 3.0),
    handle_out=@vec2.vec2(4.0, 5.0),
  )
  let reversed_anchor = @vec2.reverse(anchor)
  inspect!(reversed_anchor.handle_in, content="{x: 4, y: 5}")
  inspect!(reversed_anchor.handle_out, content="{x: 2, y: 3}")
}

test "@vec2.reverse/identical_handles" {
  let anchor = @vec2.Anchor::new(
    handle_in=@vec2.vec2(2.0, 2.0),
    handle_out=@vec2.vec2(2.0, 2.0),
  )
  let reversed_anchor = @vec2.reverse(anchor)
  inspect!(reversed_anchor.handle_in, content="{x: 2, y: 2}")
  inspect!(reversed_anchor.handle_out, content="{x: 2, y: 2}")
}

test "@vec2.reverse/zero_handles" {
  let anchor = @vec2.Anchor::new(
    position=@vec2.vec2(0.0, 0.0),
    handle_in=@vec2.vec2(0.0, 0.0),
    handle_out=@vec2.vec2(0.0, 0.0),
  )
  let reversed_anchor = @vec2.reverse(anchor)
  inspect!(reversed_anchor.handle_in, content="{x: 0, y: 0}")
  inspect!(reversed_anchor.handle_out, content="{x: 0, y: 0}")
}
