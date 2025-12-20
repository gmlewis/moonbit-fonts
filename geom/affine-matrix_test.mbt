///|
test "AffineMatrix::from_transform/identity" {
  // Test with identity transform (all default values)
  let transform = Transform::new()
  let result = AffineMatrix::from_transform(transform)
  inspect(result.a, content="1")
  inspect(result.b, content="0")
  inspect(result.c, content="0")
  inspect(result.d, content="1")
  inspect(result.tx, content="0")
  inspect(result.ty, content="0")
}

///|
test "AffineMatrix::from_transform/translation" {
  // Test with only translation
  let transform = Transform::new(position=vec2(10, 20))
  let result = AffineMatrix::from_transform(transform)
  inspect(result.tx, content="10")
  inspect(result.ty, content="20")
}

///|
test "AffineMatrix::from_transform/combined" {
  // Test with combined transformations
  let transform = Transform::new(
    position=vec2(1, 1),
    rotation=90,
    scale=vec2(2, 2),
    skew=45,
    origin=vec2(5, 5),
  )
  let result = AffineMatrix::from_transform(transform)
  // Result should be non-identity matrix with all components affected
  inspect(result.is_identity(), content="false")
}

///|
test "AffineMatrix::from_translation/basic" {
  let vec1 = vec2(10.0, 20.0)
  let mat1 = AffineMatrix::from_translation(vec1)
  inspect(mat1.a, content="1")
  inspect(mat1.b, content="0")
  inspect(mat1.c, content="0")
  inspect(mat1.d, content="1")
  inspect(mat1.tx, content="10")
  inspect(mat1.ty, content="20")
}

///|
test "AffineMatrix::from_translation_points/basic" {
  let p1 = vec2(1.0, 2.0)
  let p2 = vec2(4.0, 6.0)
  let m = AffineMatrix::from_translation_points(p1, p2)
  inspect(m.a, content="1")
  inspect(m.b, content="0")
  inspect(m.c, content="0")
  inspect(m.d, content="1")
  inspect(m.tx, content="3") // 4 - 1
  inspect(m.ty, content="4") // 6 - 2
}

///|
test "AffineMatrix::from_center_scale/identity" {
  // Test identity transformation (scale = 1)
  let center = vec2(10.0, 10.0)
  let scale = vec2(1.0, 1.0)
  let m = AffineMatrix::from_center_scale(center, scale)
  inspect(m.a, content="1")
  inspect(m.b, content="0")
  inspect(m.c, content="0")
  inspect(m.d, content="1")
  inspect(m.tx, content="0")
  inspect(m.ty, content="0")
}

///|
test "AffineMatrix::clone" {
  let matrix = AffineMatrix::new(a=1, b=2, c=3, d=4, tx=5, ty=6)
  let cloned_matrix = matrix.clone()
  inspect(cloned_matrix, content="{a: 1, b: 2, c: 3, d: 4, tx: 5, ty: 6}")
}

///|
test "AffineMatrix::invert/basic" {
  let matrix = AffineMatrix::new(a=2, b=0, c=0, d=2, tx=1, ty=1)
  let inverted_matrix = matrix.invert()
  inspect(
    inverted_matrix,
    content="{a: 0.5, b: 0, c: 0, d: 0.5, tx: -0.5, ty: -0.5}",
  )
}

///|
test "mul/identity" {
  let id = AffineMatrix::new() // identity matrix
  let m = AffineMatrix::new(a=2, b=0, c=0, d=2, tx=1, ty=1) // scale + translate
  let result = m.mul(id)
  inspect(result.a, content="2")
  inspect(result.b, content="0")
  inspect(result.c, content="0")
  inspect(result.d, content="2")
  inspect(result.tx, content="1")
  inspect(result.ty, content="1")
}

///|
test "translate" {
  // Basic translation
  let m = AffineMatrix::new()
  let v = vec2(2.0, 3.0)
  let result = m.translate(v)
  inspect(result.tx, content="2")
  inspect(result.ty, content="3")
}

///|
test "AffineMatrix::rotate" {
  // Test rotation by 0 degrees (identity)
  let m0 = AffineMatrix::new()
  inspect(m0.rotate(0), content="{a: 1, b: 0, c: 0, d: 1, tx: 0, ty: 0}")

  // Test rotation by 90 degrees
  let m90 = AffineMatrix::new()
  inspect(
    m90.rotate(90),
    content="{a: 6.123233995736766e-17, b: 1, c: -1, d: 6.123233995736766e-17, tx: 0, ty: 0}",
  )
}

///|
test "AffineMatrix::to_transform/identity" {
  // Test identity matrix transformation
  let matrix = AffineMatrix::new() // Creates identity matrix
  let transform = matrix.to_transform()
  inspect(transform.position, content="{x: 0, y: 0}")
  inspect(transform.rotation, content="0")
  inspect(transform.scale, content="{x: 1, y: 1}")
  inspect(transform.skew, content="0")
  inspect(transform.origin, content="{x: 0, y: 0}")
}
