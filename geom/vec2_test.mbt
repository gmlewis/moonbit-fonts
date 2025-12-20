///|
test "Vec2::new/basic" {
  let v = Vec2::new(x=3.14, y=2.718)
  inspect(v.x, content="3.14")
  inspect(v.y, content="2.718")
}

///|
test "vec2/basic" {
  let v1 = vec2(1.0, 2.0)
  inspect(v1.x, content="1")
  inspect(v1.y, content="2")
}

///|
test "Vec2::from_angle" {
  inspect(Vec2::from_angle(0), content="{x: 1, y: 0}")
  inspect(Vec2::from_angle(90), content="{x: 6.123233995736766e-17, y: 1}")
}

///|
test "clone" {
  let v = vec2(3.0, 4.0)
  let cloned = v.clone()
  inspect(cloned, content="{x: 3, y: 4}")
}

///|
test "affine_transform/identity" {
  let v = vec2(2.0, 3.0)
  let m = AffineMatrix::new() // Identity matrix
  let result = v.affine_transform(m)
  inspect(result.x, content="2")
  inspect(result.y, content="3")
}

///|
test "transform/identity" {
  let v = vec2(1.0, 1.0)
  inspect(v.transform(), content="{x: 1, y: 1}")
}

///|
test "self_add" {
  let v1 = vec2(1.0, 2.0)
  let v2 = vec2(3.0, 4.0)
  inspect(v1.self_add(v2), content="{x: 4, y: 6}")
}

///|
test "Vec2::dot" {
  let v1 = vec2(1.0, 2.0)
  let v2 = vec2(3.0, 4.0)
  inspect(v1.dot(v2), content="11")
}

///|
test "normalize" {
  let v = vec2(3.0, 4.0)
  let result = v.normalize()
  inspect(result, content="{x: 0.6000000000000001, y: 0.8}")
}
