///|
typealias @draw.AffineMatrix

///|
typealias @draw.Transform

///|
typealias @draw.Vec2

///|
let vec2 = @draw.vec2

///|
test "Vec2::new/basic" {
  let v = Vec2::new(x=3.14, y=2.718)
  inspect(v.x, content="3.14")
  inspect(v.y, content="2.718")
}

///|
test "Vec2::new/defaults" {
  let v = Vec2::new()
  inspect(v.x, content="0")
  inspect(v.y, content="0")
}

///|
test "Vec2::new/special-values" {
  let v1 = Vec2::new(x=@double.infinity, y=@double.neg_infinity)
  inspect(v1.x.is_inf(), content="true")
  inspect(v1.y.is_inf(), content="true")
  let v2 = Vec2::new(x=@double.not_a_number, y=0)
  inspect(v2.x.is_nan(), content="true")
  inspect(v2.y.is_nan(), content="false")
}

///|
test "Vec2::new/default_values" {
  let v = Vec2::new()
  inspect(v.x, content="0")
  inspect(v.y, content="0")
}

///|
test "Vec2::new/positive_values" {
  let v = Vec2::new(x=5.5, y=10.0)
  inspect(v.x, content="5.5")
  inspect(v.y, content="10")
}

///|
test "Vec2::new/negative_values" {
  let v = Vec2::new(x=-3.5, y=-7.2)
  inspect(v.x, content="-3.5")
  inspect(v.y, content="-7.2")
}

///|
test "vec2/basic" {
  let v1 = vec2(1.0, 2.0)
  inspect(v1.x, content="1")
  inspect(v1.y, content="2")
  let v2 = vec2(-3.0, -4.0)
  inspect(v2.x, content="-3")
  inspect(v2.y, content="-4")
}

///|
test "vec2/zero" {
  let v = vec2(0.0, 0.0)
  inspect(v.x, content="0")
  inspect(v.y, content="0")
}

///|
test "vec2/large_numbers" {
  let v = vec2(1.0e15, -1.0e15)
  inspect(v.x, content="1000000000000000")
  inspect(v.y, content="-1000000000000000")
}

///|
test "vec2/basic_functionality" {
  let v = vec2(3.0, 4.0)
  inspect(v.x, content="3")
  inspect(v.y, content="4")
}

///|
test "vec2/boundary_values/zero" {
  let v = vec2(0.0, 0.0)
  inspect(v.x, content="0")
  inspect(v.y, content="0")
}

///|
test "vec2/boundary_values/negative" {
  let v = vec2(-1.0, -2.0)
  inspect(v.x, content="-1")
  inspect(v.y, content="-2")
}

///|
fn assert_vec2_approx_eq(
  result : Vec2,
  expect_x : Double,
  expect_y : Double,
  error : Double
) -> Unit raise Error {
  if (result.x - expect_x).abs() < error && (result.y - expect_y).abs() < error {
    ()
  } else {
    fail(
      "Expecting (\{expect_x}, \{expect_y}), got (\{result.x}, \{result.y}) instead",
    )
  }
}

///|
test "Vec2::from_angle/cardinal" {
  let error = 0.0001
  assert_vec2_approx_eq(Vec2::from_angle(0.0), 1.0, 0.0, error)
  assert_vec2_approx_eq(Vec2::from_angle(90.0), 0.0, 1.0, error)
  assert_vec2_approx_eq(Vec2::from_angle(180.0), -1.0, 0.0, error)
  assert_vec2_approx_eq(Vec2::from_angle(270.0), 0.0, -1.0, error)
}

///|
test "Vec2::from_angle/diagonal" {
  let error = 0.0001
  let sqrt2_2 = 0.7071067811865476 // √2/2
  assert_vec2_approx_eq(Vec2::from_angle(45.0), sqrt2_2, sqrt2_2, error)
  assert_vec2_approx_eq(Vec2::from_angle(135.0), -sqrt2_2, sqrt2_2, error)
  assert_vec2_approx_eq(Vec2::from_angle(225.0), -sqrt2_2, -sqrt2_2, error)
  assert_vec2_approx_eq(Vec2::from_angle(315.0), sqrt2_2, -sqrt2_2, error)
}

///|
test "Vec2::from_angle/wrapped" {
  let error = 0.0001
  assert_vec2_approx_eq(Vec2::from_angle(-360.0), 1.0, 0.0, error)
  assert_vec2_approx_eq(Vec2::from_angle(-180.0), -1.0, 0.0, error)
  assert_vec2_approx_eq(Vec2::from_angle(360.0), 1.0, 0.0, error)
  assert_vec2_approx_eq(Vec2::from_angle(720.0), 1.0, 0.0, error)
}

///|
test "Vec2::from_angle/basic_angles" {
  inspect(Vec2::from_angle(0), content="{x: 1, y: 0}")
  inspect(Vec2::from_angle(90), content="{x: 6.123233995736766e-17, y: 1}")
  inspect(Vec2::from_angle(180), content="{x: -1, y: 1.2246467991473532e-16}")
  inspect(Vec2::from_angle(270), content="{x: -1.8369701987210297e-16, y: -1}")
}

///|
test "Vec2::from_angle/negative_angles" {
  inspect(Vec2::from_angle(-90), content="{x: 6.123233995736766e-17, y: -1}")
  inspect(Vec2::from_angle(-180), content="{x: -1, y: -1.2246467991473532e-16}")
  inspect(Vec2::from_angle(-270), content="{x: -1.8369701987210297e-16, y: 1}")
}

///|
test "Vec2::from_angle/out_of_range_angles" {
  inspect(Vec2::from_angle(360), content="{x: 1, y: -2.4492935982947064e-16}")
  inspect(Vec2::from_angle(450), content="{x: 3.061616997868383e-16, y: 1}")
  inspect(Vec2::from_angle(-360), content="{x: 1, y: 2.4492935982947064e-16}")
  inspect(Vec2::from_angle(-450), content="{x: 3.061616997868383e-16, y: -1}")
}

///|
fn assert_approx_eq12(
  result : Vec2,
  expect : Vec2,
  error : Double
) -> Unit raise Error {
  if (result.x - expect.x).abs() < error && (result.y - expect.y).abs() < error {
    ()
  } else {
    fail("Expected (\{expect.x}, \{expect.y}), got (\{result.x}, \{result.y})")
  }
}

///|
test "Vec2::from_angle_radians/special-angles" {
  // 0 radians = (1, 0)
  assert_approx_eq12(Vec2::from_angle_radians(0.0), vec2(1.0, 0.0), 0.000001)

  // π/2 radians = (0, 1)
  assert_approx_eq12(
    Vec2::from_angle_radians(@math.PI / 2.0),
    vec2(0.0, 1.0),
    0.000001,
  )

  // π radians = (-1, 0)
  assert_approx_eq12(
    Vec2::from_angle_radians(@math.PI),
    vec2(-1.0, 0.0),
    0.000001,
  )

  // 3π/2 radians = (0, -1)
  assert_approx_eq12(
    Vec2::from_angle_radians(3.0 * @math.PI / 2.0),
    vec2(0.0, -1.0),
    0.000001,
  )
}

///|
test "Vec2::from_angle_radians/unit-length" {
  let angles = [0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0]
  for i = 0; i < angles.length(); i = i + 1 {
    let v = Vec2::from_angle_radians(angles[i])
    // Check if length is approximately 1
    let len = v.length()
    if (len - 1.0).abs() > 0.000001 {
      fail("Vector at angle \{angles[i]} has length \{len}, expected 1.0")
    }
  }
}

///|
fn assert_approx_eq(
  result : Double,
  expect : Double,
  error : Double
) -> Unit raise Error {
  if (result - expect).abs() < error {
    ()
  } else {
    fail("Expecting \{expect}, got \{result} instead")
  }
}

///|
test "Vec2::from_angle_radians" {
  // Test case for converting 0 radians to Vec2
  let vec = Vec2::from_angle_radians(0.0)
  assert_approx_eq(vec.x, 1.0, 0.0001)
  assert_approx_eq(vec.y, 0.0, 0.0001)
}

///|
test "Vec2::from_angle_radians/PI" {
  // Test case for converting PI radians to Vec2
  let vec = Vec2::from_angle_radians(@math.PI)
  assert_approx_eq(vec.x, -1.0, 0.0001)
  assert_approx_eq(vec.y, 0.0, 0.0001)
}

///|
test "Vec2::from_angle_radians/PI_half" {
  // Test case for converting PI/2 radians to Vec2
  let vec = Vec2::from_angle_radians(@math.PI / 2.0)
  assert_approx_eq(vec.x, 0.0, 0.0001)
  assert_approx_eq(vec.y, 1.0, 0.0001)
}

///|
test "@draw.clone" {
  // Test basic functionality
  let v = vec2(3.0, 4.0)
  let cloned = v.clone()
  inspect(cloned, content="{x: 3, y: 4}")

  // Test with zero values
  let zero = vec2(0.0, 0.0)
  let zero_clone = zero.clone()
  inspect(zero_clone, content="{x: 0, y: 0}")

  // Test that it's a new copy
  let original = vec2(1.0, 1.0)
  let copy = original.clone()
  original.x = 2.0
  original.y = 2.0
  inspect(copy, content="{x: 1, y: 1}") // Copy should remain unchanged
}

///|
test "@draw.clone" {
  let vec = Vec2::new(x=0, y=0)
  let cloned_vec = vec.clone()
  inspect(cloned_vec, content="{x: 0, y: 0}")
}

///|
test "@draw.clone/large_values" {
  let vec = Vec2::new(x=1.0e308, y=1.0e308)
  let cloned_vec = vec.clone()
  inspect(cloned_vec, content="{x: 1e+308, y: 1e+308}")
}

///|
test "@draw.clone/small_values" {
  let vec = Vec2::new(x=1.0e-308, y=1.0e-308)
  let cloned_vec = vec.clone()
  inspect(cloned_vec, content="{x: 1e-308, y: 1e-308}")
}

///|
test "@draw.copy" {
  // Test normal case
  let v1 = Vec2::new(x=1.0, y=2.0)
  let v2 = Vec2::new(x=3.0, y=4.0)
  let result = v1.copy(v2)
  inspect(result.x, content="3")
  inspect(result.y, content="4")

  // Test copying to itself (should work)
  let v3 = Vec2::new(x=5.0, y=6.0)
  let result2 = v3.copy(v3)
  inspect(result2.x, content="5")
  inspect(result2.y, content="6")
}

///|
test "@draw.copy/zero" {
  // Test copying zero vector
  let v1 = Vec2::new(x=1.0, y=1.0)
  let v2 = Vec2::new(x=0.0, y=0.0)
  let result = v1.copy(v2)
  inspect(result.x, content="0")
  inspect(result.y, content="0")
}

///|
test "@draw.copy/negative" {
  // Test copying negative values
  let v1 = Vec2::new(x=1.0, y=1.0)
  let v2 = Vec2::new(x=-1.0, y=-2.0)
  let result = v1.copy(v2)
  inspect(result.x, content="-1")
  inspect(result.y, content="-2")
}

///|
test "@draw.copy/zero_vector" {
  let source = Vec2::{ x: 0, y: 0 }
  let target = Vec2::{ x: 5, y: 10 }
  let result = source.copy(target)
  inspect(result, content="{x: 5, y: 10}")
}

///|
test "@draw.copy/negative_values" {
  let source = Vec2::{ x: -1, y: -1 }
  let target = Vec2::{ x: -5, y: -10 }
  let result = source.copy(target)
  inspect(result, content="{x: -5, y: -10}")
}

///|
test "@draw.Vec2::is_valid/regular_values" {
  let v = Vec2::new(x=1.0, y=2.0)
  inspect(v.is_valid(), content="true")
  let v2 = Vec2::new(x=0.0, y=0.0)
  inspect(v2.is_valid(), content="true")
  let v3 = Vec2::new(x=-1.0, y=-2.0)
  inspect(v3.is_valid(), content="true")
}

///|
test "@draw.Vec2::is_valid/infinity" {
  let inf = @double.infinity
  let v1 = Vec2::new(x=inf, y=0.0)
  inspect(v1.is_valid(), content="false")
  let v2 = Vec2::new(x=0.0, y=inf)
  inspect(v2.is_valid(), content="false")
}

///|
test "@draw.Vec2::is_valid/nan" {
  let nan = @double.not_a_number
  let v1 = Vec2::new(x=nan, y=1.0)
  inspect(v1.is_valid(), content="false")
  let v2 = Vec2::new(x=1.0, y=nan)
  inspect(v2.is_valid(), content="false")
}

///|
test "@draw.Vec2::is_valid" {
  // Test with zero vector
  inspect(@draw.Vec2::is_valid(Vec2::new()), content="true")
}

///|
test "@draw.Vec2::is_valid/inf_values" {
  // Test with infinity values
  inspect(
    Vec2::new(x=@double.infinity, y=@double.infinity).is_valid(),
    content="false",
  )
  inspect(
    @draw.Vec2::is_valid(Vec2::new(x=@double.infinity, y=0.0)),
    content="false",
  )
  inspect(
    @draw.Vec2::is_valid(Vec2::new(x=0.0, y=@double.infinity)),
    content="false",
  )
}

///|
test "@draw.Vec2::is_valid/nan_values" {
  // Test with NaN values
  inspect(
    @draw.Vec2::is_valid(vec2(@double.not_a_number, @double.not_a_number)),
    content="false",
  )
  inspect(
    @draw.Vec2::is_valid(vec2(@double.not_a_number, 0.0)),
    content="false",
  )
  inspect(
    @draw.Vec2::is_valid(vec2(0.0, @double.not_a_number)),
    content="false",
  )
} // Test identity transformation (no change)

///|
test "@draw.affine_transform/identity" {
  let v = vec2(2.0, 3.0)
  let m = AffineMatrix::new() // Identity matrix
  let result = v.affine_transform(m)
  inspect(result.x, content="2")
  inspect(result.y, content="3")
}

// Test translation only
///|
test "@draw.affine_transform/translation" {
  let v = vec2(1.0, 1.0)
  let m = AffineMatrix::new(tx=2.0, ty=3.0)
  let result = v.affine_transform(m)
  inspect(result.x, content="3")
  inspect(result.y, content="4")
}

// Test complex transformation
///|
test "@draw.affine_transform/complex" {
  let v = vec2(1.0, 2.0)
  // Combines rotation, scale, and translation
  let m = AffineMatrix::new(
    a=2.0, // Scale X
    b=1.0, // Rotation/Skew
    c=-1.0, // Rotation/Skew
    d=2.0, // Scale Y
    tx=5.0, // Translate X
    ty=3.0, // Translate Y
  )
  let result = v.affine_transform(m)
  inspect(result.x, content="5")
  inspect(result.y, content="8")
}

///|
test "@draw.affine_transform/identity_matrix" {
  let v = Vec2::new(x=3.0, y=4.0)
  let m = @draw.AffineMatrix::new(a=1.0, b=0.0, c=0.0, d=1.0, tx=0.0, ty=0.0)
  inspect(v.affine_transform(m), content="{x: 3, y: 4}")
}

///|
test "@draw.affine_transform/translation_matrix" {
  let v = Vec2::new(x=3.0, y=4.0)
  let m = @draw.AffineMatrix::new(a=1.0, b=0.0, c=0.0, d=1.0, tx=5.0, ty=-2.0)
  inspect(v.affine_transform(m), content="{x: 8, y: 2}")
}

///|
test "@draw.affine_transform/scaling_matrix" {
  let v = Vec2::new(x=3.0, y=4.0)
  let m = @draw.AffineMatrix::new(a=2.0, b=0.0, c=0.0, d=3.0, tx=0.0, ty=0.0)
  inspect(v.affine_transform(m), content="{x: 6, y: 12}")
}

///|
test "@draw.affine_transform_without_translation/identity" {
  let v = vec2(3.0, 4.0)
  let m = @draw.AffineMatrix::new() // Identity matrix
  let result = v.affine_transform_without_translation(m)
  inspect(result.x, content="3")
  inspect(result.y, content="4")
}

///|
test "@draw.affine_transform_without_translation/scale" {
  let v = vec2(2.0, 3.0)
  // Scale x by 2 and y by 3
  let m = @draw.AffineMatrix::new(a=2.0, d=3.0)
  let result = v.affine_transform_without_translation(m)
  inspect(result.x, content="4")
  inspect(result.y, content="9")
}

///|
test "@draw.affine_transform_without_translation/with_translation" {
  let v = vec2(1.0, 1.0)
  // Matrix with translation (tx=5, ty=5) which should be ignored
  let m = @draw.AffineMatrix::new(tx=5.0, ty=5.0)
  let result = v.affine_transform_without_translation(m)
  inspect(result.x, content="1")
  inspect(result.y, content="1")
}

///|
test "@draw.affine_transform_without_translation/identity_matrix" {
  let v = vec2(2.0, 3.0)
  let m = @draw.AffineMatrix::new()
  inspect(v.affine_transform_without_translation(m), content="{x: 2, y: 3}")
}

///|
test "@draw.affine_transform_without_translation/rotation_matrix" {
  let v = vec2(1.0, 0.0)
  let m = @draw.AffineMatrix::from_rotation(90.0)
  inspect(
    v.affine_transform_without_translation(m),
    content="{x: 6.123233995736766e-17, y: 1}",
  )
}

///|
test "@draw.affine_transform_without_translation/scaling_matrix" {
  let v = vec2(2.0, 3.0)
  let m = @draw.AffineMatrix::from_scale(vec2(2.0, 2.0))
  inspect(v.affine_transform_without_translation(m), content="{x: 4, y: 6}")
}

///|
test "@draw.transform/identity" {
  let v = vec2(1.0, 1.0)
  inspect(v.transform(), content="{x: 1, y: 1}")
}

///|
test "@draw.transform/translation" {
  let v = vec2(1.0, 1.0)
  let position = vec2(2.0, 3.0)
  inspect(v.transform(position~), content="{x: 3, y: 4}")
}

///|
test "@draw.transform/scale-and-rotate" {
  let v = vec2(1.0, 0.0)
  let rotation = 90.0
  let scale = vec2(2.0, 2.0)
  // After scaling by 2 and rotating 90 degrees, (1,0) should become (0,2)
  let result = v.transform(rotation~, scale~)
  inspect(result.x, content="1.2246467991473532e-16")
  inspect(result.y, content="2")
}

///|
test "@draw.transform/standard_scale_rotation" {
  let v = vec2(1, 2)
  let position = vec2(0, 0)
  let rotation = 90.0
  let scale = vec2(2, 2)
  let skew = 0.0
  let origin = vec2(0, 0)
  let result = @draw.Vec2::transform(
    v,
    position~,
    rotation~,
    scale~,
    skew~,
    origin~,
  )
  inspect(result, content="{x: -4, y: 2.0000000000000004}")
}

///|
test "@draw.transform/identity" {
  let v = vec2(1, 2)
  let result = @draw.Vec2::transform(v)
  inspect(result, content="{x: 1, y: 2}")
}

///|
test "@draw.transform/boundary_neg_scale_translation" {
  let v = vec2(1, -2)
  let result = @draw.Vec2::transform(
    v,
    position=vec2(3, 4),
    rotation=0,
    scale=vec2(-1, -0.5),
    skew=0,
    origin=vec2(0, 0),
  )
  inspect(result, content="{x: 2, y: 5}")
}

///|
test "@draw.add" {
  // Basic vector addition
  let v1 = vec2(1.0, 2.0)
  let v2 = vec2(3.0, -1.0)
  let result = v1.add(v2)
  inspect(result.x, content="4")
  inspect(result.y, content="1")

  // Adding zero vector
  let v3 = vec2(5.0, -3.0)
  let zero = vec2(0.0, 0.0)
  let result2 = v3.add(zero)
  inspect(result2.x, content="5")
  inspect(result2.y, content="-3")

  // Adding vector to itself
  let v4 = vec2(2.5, 1.5)
  let result3 = v4.add(v4)
  inspect(result3.x, content="5")
  inspect(result3.y, content="3")
}

///|
test "@draw.add" {
  // Basic test case with positive values
  let v1 = vec2(1.0, 2.0)
  let v2 = vec2(3.0, 4.0)
  inspect(v1.add(v2), content="{x: 4, y: 6}")
}

///|
test "@draw.add/boundary" {
  // Test case with zero values
  let v1 = vec2(0.0, 0.0)
  let v2 = vec2(0.0, 0.0)
  inspect(v1.add(v2), content="{x: 0, y: 0}")

  // Test case with negative values
  let v3 = vec2(-1.0, -2.0)
  let v4 = vec2(-3.0, -4.0)
  inspect(v3.add(v4), content="{x: -4, y: -6}")
}

///|
test "@draw.add/boundary-large-small" {
  // Test case with large and small values
  let v1 = vec2(1.0e308, 1.0e-308)
  let v2 = vec2(1.0e308, 1.0e-308)
  inspect(v1.add(v2), content="{x: Infinity, y: 2e-308}")
}

///|
test "@draw.Vec2::op_add" {
  // Basic vector addition
  inspect(
    @draw.Vec2::op_add(vec2(1.0, 2.0), vec2(3.0, 4.0)),
    content="{x: 4, y: 6}",
  )

  // Adding with zero vector should return the same vector
  inspect(
    @draw.Vec2::op_add(vec2(1.0, 2.0), vec2(0.0, 0.0)),
    content="{x: 1, y: 2}",
  )

  // Adding negative vectors
  inspect(
    @draw.Vec2::op_add(vec2(-1.0, -2.0), vec2(-3.0, -4.0)),
    content="{x: -4, y: -6}",
  )
}

///|
test "@draw.Vec2::op_add/edge_cases" {
  // Adding large numbers
  inspect(
    @draw.Vec2::op_add(vec2(1.0e15, 2.0e15), vec2(3.0e15, 4.0e15)),
    content="{x: 4000000000000000, y: 6000000000000000}",
  )

  // Adding small numbers
  inspect(
    @draw.Vec2::op_add(vec2(1.0e-15, 2.0e-15), vec2(3.0e-15, 4.0e-15)),
    content="{x: 4e-15, y: 6.0000000000000005e-15}",
  )
}

///|
test "@draw.Vec2::op_add/commutative" {
  // Test commutative property: a + b should equal b + a
  let a = vec2(1.0, 2.0)
  let b = vec2(3.0, 4.0)
  let sum1 = @draw.Vec2::op_add(a, b)
  let sum2 = @draw.Vec2::op_add(b, a)
  inspect(sum1, content="{x: 4, y: 6}")
  inspect(sum2, content="{x: 4, y: 6}")
}

///|
test "@draw.Vec2::op_add" {
  inspect(
    @draw.Vec2::op_add(vec2(1.0, 2.0), vec2(3.0, 4.0)),
    content="{x: 4, y: 6}",
  )
}

///|
test "@draw.Vec2::op_add/zero_vectors" {
  inspect(
    @draw.Vec2::op_add(vec2(0.0, 0.0), vec2(0.0, 0.0)),
    content="{x: 0, y: 0}",
  )
}

///|
test "@draw.Vec2::op_add/negative_values" {
  inspect(
    @draw.Vec2::op_add(vec2(-1.0, -2.0), vec2(-3.0, -4.0)),
    content="{x: -4, y: -6}",
  )
}

///|
fn assert_vec2_eq(v1 : Vec2, v2 : Vec2, error : Double) -> Unit raise Error {
  if (v1.x - v2.x).abs() < error && (v1.y - v2.y).abs() < error {
    ()
  } else {
    fail("Vectors not equal: (\{v1.x}, \{v1.y}) != (\{v2.x}, \{v2.y})")
  }
}

///|
test "@draw.Vec2::add_scalar/basic" {
  let v = vec2(1.0, 2.0)
  assert_vec2_eq(@draw.Vec2::add_scalar(v, 3.0), vec2(4.0, 5.0), 0.0001)
}

///|
test "@draw.Vec2::add_scalar/zero" {
  let v = vec2(1.0, 2.0)
  let orig = v.clone()
  assert_vec2_eq(@draw.Vec2::add_scalar(v, 0.0), orig, 0.0001)
}

///|
test "@draw.Vec2::add_scalar/zero-vector" {
  let v = vec2(0.0, 0.0)
  assert_vec2_eq(@draw.Vec2::add_scalar(v, 5.0), vec2(5.0, 5.0), 0.0001)
  assert_vec2_eq(@draw.Vec2::add_scalar(v, -3.0), vec2(2.0, 2.0), 0.0001)
}

///|
test "@draw.Vec2::add_scalar/positive_scalar" {
  let v = Vec2::new(x=2.0, y=3.0)
  let result = @draw.Vec2::add_scalar(v, 5.0)
  inspect(result, content="{x: 7, y: 8}")
}

///|
test "@draw.Vec2::add_scalar/zero_scalar" {
  let v = Vec2::new(x=2.0, y=3.0)
  let result = @draw.Vec2::add_scalar(v, 0.0)
  inspect(result, content="{x: 2, y: 3}")
}

///|
test "@draw.Vec2::add_scalar/negative_scalar" {
  let v = Vec2::new(x=2.0, y=3.0)
  let result = @draw.Vec2::add_scalar(v, -1.5)
  inspect(result, content="{x: 0.5, y: 1.5}")
}

///|
test "@draw.Vec2::sub/boundary_positive_and_negative" {
  let v1 = Vec2::{ x: 5.0, y: 3.0 }
  let v2 = Vec2::{ x: -2.5, y: 7.0 }
  let result = @draw.Vec2::sub(v1, v2)
  inspect(result.x, content="7.5")
  inspect(result.y, content="-4")
}

///|
test "@draw.Vec2::sub/boundary_both_zero" {
  let v1 = Vec2::{ x: 0.0, y: 0.0 }
  let v2 = Vec2::{ x: 0.0, y: 0.0 }
  let result = @draw.Vec2::sub(v1, v2)
  inspect(result.x, content="0")
  inspect(result.y, content="0")
}

///|
test "@draw.Vec2::sub/boundary_max_min_values" {
  let v1 = Vec2::{ x: @double.max_value, y: @double.min_value }
  let v2 = Vec2::{ x: @double.min_value, y: @double.max_value }
  let result = @draw.Vec2::sub(v1, v2)
  inspect(result.x, content="\{@double.max_value - @double.min_value}")
  inspect(result.y, content="\{@double.min_value - @double.max_value}")
}

///|
test "@draw.Vec2::sub" {
  // Test basic subtraction
  let v1 = vec2(3.0, 4.0)
  let v2 = vec2(1.0, 2.0)
  let result = v1.sub(v2)
  inspect(result.x, content="2")
  inspect(result.y, content="2")
}

///|
test "@draw.Vec2::sub/zero_vector" {
  // Test subtraction with zero vector
  let v1 = vec2(3.0, 4.0)
  let zero = vec2(0.0, 0.0)
  let result = v1.sub(zero)
  inspect(result.x, content="3")
  inspect(result.y, content="4")
}

///|
test "@draw.Vec2::sub/same_vector" {
  // Test subtraction of a vector from itself
  let v = vec2(3.0, 4.0)
  let result = v.sub(v)
  inspect(result.x, content="0")
  inspect(result.y, content="0")
}

///|
test "@draw.Vec2::op_sub/basic" {
  let v1 = vec2(3.0, 4.0)
  let v2 = vec2(1.0, 1.0)
  let result = v1.op_sub(v2)
  inspect(result.x, content="2")
  inspect(result.y, content="3")
  // Also verify that the original vectors are unchanged
  inspect(v1.x, content="3")
  inspect(v1.y, content="4")
  inspect(v2.x, content="1")
  inspect(v2.y, content="1")
}

///|
test "@draw.Vec2::op_sub/zero_vector" {
  let v1 = vec2(3.0, 4.0)
  let zero = vec2(0.0, 0.0)
  let result = v1.op_sub(zero)
  inspect(result.x, content="3")
  inspect(result.y, content="4")
}

///|
test "@draw.Vec2::op_sub/negative_components" {
  let v1 = vec2(-1.0, 2.0)
  let v2 = vec2(3.0, -4.0)
  let result = v1.op_sub(v2)
  inspect(result.x, content="-4")
  inspect(result.y, content="6")
}

///|
test "@draw.Vec2::op_sub" {
  let v1 = Vec2::new(x=3.0, y=4.0)
  let v2 = Vec2::new(x=1.0, y=2.0)
  let result = @draw.Vec2::op_sub(v1, v2)
  inspect(result, content="{x: 2, y: 2}")
}

///|
test "@draw.Vec2::op_sub/zero_vector" {
  let v1 = Vec2::new(x=0.0, y=0.0)
  let v2 = Vec2::new(x=5.0, y=6.0)
  let result = @draw.Vec2::op_sub(v1, v2)
  inspect(result, content="{x: -5, y: -6}")
}

///|
test "@draw.Vec2::op_sub/negative_coordinates" {
  let v1 = Vec2::new(x=-3.0, y=-4.0)
  let v2 = Vec2::new(x=-1.0, y=-2.0)
  let result = @draw.Vec2::op_sub(v1, v2)
  inspect(result, content="{x: -2, y: -2}")
}

///|
test "@draw.Vec2::sub_scalar" {
  let v = vec2(3.0, 4.0)
  inspect(v.sub_scalar(1.0), content="{x: 2, y: 3}")
  let v2 = vec2(-1.0, -2.0)
  inspect(v2.sub_scalar(-3.0), content="{x: 2, y: 1}")
  let v3 = vec2(1.0, 1.0)
  inspect(v3.sub_scalar(0.0), content="{x: 1, y: 1}")
}

///|
test "@draw.Vec2::sub_scalar/infinity" {
  let v = vec2(1.0, 1.0)
  let result = v.sub_scalar(@double.infinity)
  inspect(result.is_valid(), content="false")
}

///|
test "@draw.Vec2::sub_scalar/zero_subtraction" {
  let vec = Vec2::new(x=3.5, y=2.5)
  let result = @draw.Vec2::sub_scalar(vec, 0.0)
  inspect(result, content="{x: 3.5, y: 2.5}")
}

///|
test "@draw.Vec2::sub_scalar/negative_subtraction" {
  let vec = Vec2::new(x=-1.0, y=-2.0)
  let result = @draw.Vec2::sub_scalar(vec, -1.0)
  inspect(result, content="{x: 0, y: -1}")
}

///|
test "@draw.Vec2::sub_scalar/large_subtraction" {
  let vec = Vec2::new(x=1.0e15, y=-1.0e15)
  let result = @draw.Vec2::sub_scalar(vec, 1.0e15)
  inspect(result, content="{x: 0, y: -2000000000000000}")
}

///|
test "Vec2::mul/normal" {
  let v1 = vec2(2.0, 3.0)
  let v2 = vec2(3.0, 2.0)
  let result = v1.mul(v2)
  inspect(result.x, content="6")
  inspect(result.y, content="6")
}

///|
test "Vec2::mul/zero" {
  let v1 = vec2(2.0, 3.0)
  let v2 = vec2(0.0, 0.0)
  let result = v1.mul(v2)
  inspect(result.x, content="0")
  inspect(result.y, content="0")
}

///|
test "Vec2::mul/negative" {
  let v1 = vec2(2.0, -3.0)
  let v2 = vec2(-3.0, 2.0)
  let result = v1.mul(v2)
  inspect(result.x, content="-6")
  inspect(result.y, content="-6")
}

///|
test "@draw.mul/basic" {
  let vec1 = vec2(3.0, 4.0)
  let vec2 = vec2(2.0, 5.0)
  let result = vec1.mul(vec2)
  inspect(result.x, content="6")
  inspect(result.y, content="20")
}

///|
test "@draw.mul/with_zero" {
  let vec1 = vec2(3.0, 4.0)
  let vec2 = vec2(0.0, 0.0)
  let result = vec1.mul(vec2)
  inspect(result.x, content="0")
  inspect(result.y, content="0")
}

///|
test "@draw.mul/with_negative" {
  let vec1 = vec2(3.0, 4.0)
  let vec2 = vec2(-2.0, -5.0)
  let result = vec1.mul(vec2)
  inspect(result.x, content="-6")
  inspect(result.y, content="-20")
}

///|
test "@draw.op_mul" {
  let v1 = vec2(2.0, 3.0)
  let v2 = vec2(3.0, 4.0)
  let result = v1.op_mul(v2)
  inspect(result.x, content="6")
  inspect(result.y, content="12")
  // Check that original vectors are not modified
  inspect(v1.x, content="2")
  inspect(v1.y, content="3")
  inspect(v2.x, content="3")
  inspect(v2.y, content="4")
}

///|
test "@draw.op_mul/zero" {
  let v1 = vec2(2.0, 3.0)
  let v2 = vec2(0.0, 0.0)
  let result = v1.op_mul(v2)
  inspect(result.x, content="0")
  inspect(result.y, content="0")
}

///|
test "@draw.op_mul/identity" {
  let v1 = vec2(2.0, 3.0)
  let v2 = vec2(1.0, 1.0)
  let result = v1.op_mul(v2)
  inspect(result.x, content="2")
  inspect(result.y, content="3")
}

///|
test "@draw.op_mul/basic_functionality" {
  // Test the basic functionality of element-wise multiplication.
  let v1 = vec2(2.0, 3.0)
  let v2 = vec2(4.0, 5.0)
  inspect(v1 * v2, content="{x: 8, y: 15}")
}

///|
test "@draw.op_mul/zero_vector_multiplication" {
  // Test the multiplication with a zero vector.
  let v1 = vec2(2.0, 3.0)
  let zero_vector = vec2(0.0, 0.0)
  inspect(v1 * zero_vector, content="{x: 0, y: 0}")
}

///|
test "@draw.op_mul/negative_vector_multiplication" {
  // Test the multiplication with a negative vector.
  let v1 = vec2(2.0, 3.0)
  let v2 = vec2(-4.0, -5.0)
  inspect(v1 * v2, content="{x: -8, y: -15}")
}

///|
test "@draw.mul_scalar" {
  // Test basic multiplication
  let v1 = vec2(2.0, 3.0)
  inspect(v1.mul_scalar(2.0), content="{x: 4, y: 6}")

  // Test multiplication with zero
  let v2 = vec2(2.0, 3.0)
  inspect(v2.mul_scalar(0.0), content="{x: 0, y: 0}")

  // Test multiplication with negative scalar
  let v3 = vec2(2.0, 3.0)
  inspect(v3.mul_scalar(-2.0), content="{x: -4, y: -6}")
}

///|
test "Vec2::mul_scalar/basic_functionality" {
  let v1 = Vec2::new(x=3, y=4)
  inspect(v1.mul_scalar(2), content="{x: 6, y: 8}")
  let v2 = Vec2::new(x=-1, y=5)
  inspect(v2.mul_scalar(3), content="{x: -3, y: 15}")
  let v3 = Vec2::new(x=0, y=0)
  inspect(v3.mul_scalar(10), content="{x: 0, y: 0}")
}

///|
test "Vec2::mul_scalar/edge_case_inf" {
  let v = Vec2::new(x=1, y=2)
  inspect(v.mul_scalar(@double.infinity), content="{x: Infinity, y: Infinity}")
}

///|
test "Vec2::mul_scalar/edge_case_nan" {
  let v = Vec2::new(x=1, y=2)
  inspect(v.mul_scalar(@double.not_a_number), content="{x: NaN, y: NaN}")
}

///|
test "@draw.div" {
  // Basic division
  let v1 = Vec2::{ x: 6.0, y: 8.0 }
  let v2 = Vec2::{ x: 2.0, y: 4.0 }
  let result = v1.div(v2)
  inspect(result.x, content="3")
  inspect(result.y, content="2")

  // Division by 1 should keep the original values
  let v3 = Vec2::{ x: 5.0, y: 7.0 }
  let v4 = Vec2::{ x: 1.0, y: 1.0 }
  let result2 = v3.div(v4)
  inspect(result2.x, content="5")
  inspect(result2.y, content="7")
}

///|
test "@draw.div/division_by_zero" {
  let v1 = Vec2::{ x: 1.0, y: 1.0 }
  let v2 = Vec2::{ x: 0.0, y: 0.0 }
  inspect(v1.div(v2), content="{x: Infinity, y: Infinity}")
}

///|
test "@draw.div/basic" {
  let v1 = Vec2::new(x=4.0, y=9.0)
  let v2 = Vec2::new(x=2.0, y=3.0)
  let result = v1.div(v2)
  inspect(result, content="{x: 2, y: 3}")
}

///|
test "@draw.div/divide_by_zero" {
  let v1 = Vec2::new(x=4.0, y=9.0)
  let v2 = Vec2::new(x=0.0, y=0.0)
  inspect(v1.div(v2), content="{x: Infinity, y: Infinity}")
}

///|
test "@draw.div/negative_values" {
  let v1 = Vec2::new(x=-6.0, y=-15.0)
  let v2 = Vec2::new(x=3.0, y=-5.0)
  let result = v1.div(v2)
  inspect(result, content="{x: -2, y: 3}")
}

///|
test "@draw.Vec2::op_div/basic" {
  let v1 = Vec2::new(x=8.0, y=4.0)
  let v2 = Vec2::new(x=2.0, y=2.0)
  inspect(@draw.Vec2::op_div(v1, v2), content="{x: 4, y: 2}")
}

///|
test "@draw.Vec2::op_div/negative_division" {
  let v1 = Vec2::new(x=-6.0, y=3.0)
  let v2 = Vec2::new(x=2.0, y=-1.0)
  inspect(@draw.Vec2::op_div(v1, v2), content="{x: -3, y: -3}")
}

///|
test "@draw.Vec2::op_div/divide_by_zero" {
  let v1 = Vec2::new(x=5.0, y=3.0)
  let v2 = Vec2::new(x=0.0, y=0.0)
  inspect(@draw.Vec2::op_div(v1, v2), content="{x: Infinity, y: Infinity}")
}

///|
test "@draw.Vec2::op_div/regular" {
  let v1 = vec2(6.0, 8.0)
  let v2 = vec2(2.0, 4.0)
  let result = @draw.Vec2::op_div(v1, v2)
  inspect(result.x, content="3")
  inspect(result.y, content="2")
}

///|
test "@draw.Vec2::op_div/zero-vector" {
  let v1 = vec2(0.0, 0.0)
  let v2 = vec2(2.0, 4.0)
  let result = @draw.Vec2::op_div(v1, v2)
  inspect(result.x, content="0")
  inspect(result.y, content="0")
}

///|
test "@draw.Vec2::op_div/div-by-zero" {
  let v1 = vec2(6.0, 8.0)
  let v2 = vec2(0.0, 0.0)
  inspect(@draw.Vec2::op_div(v1, v2), content="{x: Infinity, y: Infinity}")
}

///|
test "@draw.div_scalar/basic" {
  let v = vec2(2.0, 4.0)
  let result = v.div_scalar(2.0)
  inspect(result.x, content="1")
  inspect(result.y, content="2")
}

///|
test "@draw.div_scalar/identity" {
  let v = vec2(3.0, 6.0)
  let result = v.div_scalar(1.0)
  inspect(result.x, content="3")
  inspect(result.y, content="6")
}

///|
test "@draw.div_scalar/zero" {
  let v = vec2(1.0, 2.0)
  inspect(v.div_scalar(0.0), content="{x: Infinity, y: Infinity}")
}

///|
test "@draw.div_scalar/basic_functionality" {
  let v = Vec2::new(x=10, y=20)
  inspect(v.div_scalar(2.0), content="{x: 5, y: 10}")
}

///|
test "@draw.div_scalar/divide_by_zero" {
  let v = Vec2::new(x=10, y=20)
  inspect(v.div_scalar(0.0), content="{x: Infinity, y: Infinity}")
}

///|
test "@draw.div_scalar/negative_scalar" {
  let v = Vec2::new(x=10, y=20)
  inspect(v.div_scalar(-2.0), content="{x: -5, y: -10}")
}

///|
test "@draw.negate/basic_functionality" {
  let v1 = Vec2::new(x=3.5, y=-2.5)
  let result1 = v1.negate()
  inspect(result1, content="{x: -3.5, y: 2.5}")
  let v2 = Vec2::new(x=0, y=5.0)
  let result2 = v2.negate()
  inspect(result2, content="{x: 0, y: -5}")
}

///|
test "@draw.negate/edge_cases" {
  let v1 = Vec2::new(
    x=@moonbitlang/core/double.infinity,
    y=-@moonbitlang/core/double.infinity,
  )
  let result1 = v1.negate()
  inspect(result1, content="{x: -Infinity, y: Infinity}")
  let v2 = Vec2::new(
    x=@moonbitlang/core/double.not_a_number,
    y=@moonbitlang/core/double.not_a_number,
  )
  let result2 = v2.negate()
  inspect(result2, content="{x: NaN, y: NaN}")
}

///|
test "@draw.negate/zero_vector" {
  let v = Vec2::new(x=0, y=0)
  let result = v.negate()
  inspect(result, content="{x: 0, y: 0}")
}

///|
test "@draw.negate" {
  let v = vec2(1.0, 2.0)
  inspect(v.negate(), content="{x: -1, y: -2}")
  let v2 = vec2(-3.0, -4.0)
  inspect(v2.negate(), content="{x: 3, y: 4}")
  let v3 = vec2(0.0, 0.0)
  inspect(v3.negate(), content="{x: 0, y: 0}")
}

///|
test "@draw.op_equal/identical" {
  let v1 = vec2(1.0, 2.0)
  let v2 = vec2(1.0, 2.0)
  inspect(v1.op_equal(v2), content="true")
}

///|
test "@draw.op_equal/different" {
  let v1 = vec2(1.0, 2.0)
  let v2 = vec2(1.0, 3.0)
  inspect(v1.op_equal(v2), content="false")
}

///|
test "@draw.op_equal/zero" {
  let v1 = vec2(0.0, 0.0)
  let v2 = vec2(0.0, 0.0)
  inspect(v1.op_equal(v2), content="true")
}

///|
test "@draw.op_equal/bounds" {
  // Test with zero vectors
  inspect(Vec2::new(x=0, y=0) == Vec2::new(x=0, y=0), content="true")

  // Test with very large vectors
  let maxValue : Double = @math.maximum(1000000000.0, 1000000000.0)
  inspect(
    Vec2::new(x=maxValue, y=maxValue) == Vec2::new(x=maxValue, y=maxValue),
    content="true",
  )

  // Test with very small vectors
  let minValue : Double = @math.minimum(0.0000001, 0.0000001)
  inspect(
    Vec2::new(x=minValue, y=minValue) == Vec2::new(x=minValue, y=minValue),
    content="true",
  )
}

///|
test "@draw.op_equal" {
  // Test with positive vectors
  inspect(Vec2::new(x=3, y=4) == Vec2::new(x=3, y=4), content="true")

  // Test with negative vectors
  inspect(Vec2::new(x=-5, y=-6) == Vec2::new(x=-5, y=-6), content="true")

  // Test with NaN values
  let nanValue : Double = @double.not_a_number
  inspect(
    Vec2::new(x=nanValue, y=nanValue) == Vec2::new(x=nanValue, y=nanValue),
    content="false",
  )
}

///|
test "@draw.op_equal/mismatched" {
  // Test with different x values
  inspect(Vec2::new(x=3, y=4) == Vec2::new(x=4, y=4), content="false")

  // Test with different y values
  inspect(Vec2::new(x=3, y=4) == Vec2::new(x=3, y=5), content="false")

  // Test with completely different vectors
  inspect(Vec2::new(x=1, y=2) == Vec2::new(x=3, y=4), content="false")
}

///|
test "@draw.almost_equals/identical_vectors" {
  let v1 = Vec2::new(x=1.0, y=1.0)
  let v2 = Vec2::new(x=1.0, y=1.0)
  inspect(v1.almost_equals(v2), content="true")
}

///|
test "@draw.almost_equals/boundary_tolerance" {
  let v1 = Vec2::new(x=1.0, y=1.0)
  let v2 = Vec2::new(x=1.001, y=1.001)
  inspect(v1.almost_equals(v2, tolerance=0.001), content="true")
  let v3 = Vec2::new(x=1.002, y=1.002)
  inspect(v1.almost_equals(v3, tolerance=0.001), content="false")
}

///|
test "@draw.almost_equals/nan_components" {
  let v1 = Vec2::new(x=@double.not_a_number, y=1.0)
  let v2 = Vec2::new(x=1.0, y=@double.not_a_number)
  inspect(v1.almost_equals(v2), content="false")
}

///|
test "@draw.almost_equals/exact" {
  let v1 = vec2(1.0, 2.0)
  let v2 = vec2(1.0, 2.0)
  inspect(v1.almost_equals(v2), content="true")
}

///|
test "@draw.almost_equals/within-tolerance" {
  let v1 = vec2(1.0, 2.0)
  let v2 = vec2(1.0001, 2.0001)
  inspect(v1.almost_equals(v2), content="true")
  let v3 = vec2(1000.0, 2000.0)
  let v4 = vec2(1000.1, 2000.1)
  inspect(v3.almost_equals(v4), content="true")
}

///|
test "@draw.almost_equals/outside-tolerance" {
  let v1 = vec2(1.0, 2.0)
  let v2 = vec2(1.1, 2.0)
  inspect(v1.almost_equals(v2), content="false")
  let v3 = vec2(1.0, 2.0)
  let v4 = vec2(1.0, 2.1)
  inspect(v3.almost_equals(v4), content="false")
}

///|
test "@draw.Vec2::apply/identity_function" {
  let v = Vec2::new(x=5.0, y=10.0)
  let result = @draw.Vec2::apply(v, fn(x : Double) -> Double { x })
  inspect(result.x, content="5")
  inspect(result.y, content="10")
}

///|
test "@draw.Vec2::apply/negation_function" {
  let v = Vec2::new(x=3.0, y=-7.0)
  let result = @draw.Vec2::apply(v, fn(x : Double) -> Double { -x })
  inspect(result.x, content="-3")
  inspect(result.y, content="7")
}

///|
test "@draw.Vec2::apply/nan_function" {
  let v = Vec2::new(x=1.0, y=2.0)
  inspect(
    @draw.Vec2::apply(v, fn(_x) { @double.not_a_number }),
    content="{x: NaN, y: NaN}",
  )
}

///|
test "@draw.Vec2::apply" {
  // Test basic functionality with a simple function that doubles the input
  let v = vec2(1.0, 2.0)
  let double = fn(x : Double) -> Double { x * 2.0 }
  inspect(v.apply(double), content="{x: 2, y: 4}")

  // Test with identity function
  let v2 = vec2(3.0, 4.0)
  let identity = fn(x : Double) -> Double { x }
  inspect(v2.apply(identity), content="{x: 3, y: 4}")
}

///|
test "@draw.Vec2::apply/zero" {
  // Test with zero values
  let v = vec2(0.0, 0.0)
  let triple = fn(x : Double) -> Double { x * 3.0 }
  inspect(v.apply(triple), content="{x: 0, y: 0}")
}

///|
test "@draw.Vec2::apply/negative" {
  // Test with negative values
  let v = vec2(-2.0, -3.0)
  let abs = fn(x : Double) -> Double { x.abs() }
  inspect(v.apply(abs), content="{x: 2, y: 3}")
}

///|
test "@draw/floor/positive_values" {
  // Test case with positive values
  let v = Vec2::new(x=1.7, y=2.9)
  let result = @draw.Vec2::floor(v)
  inspect(result.x, content="1")
  inspect(result.y, content="2")
}

///|
test "@draw/floor/negative_values" {
  // Test case with negative values
  let v = Vec2::new(x=-1.7, y=-2.9)
  let result = @draw.Vec2::floor(v)
  inspect(result.x, content="-2")
  inspect(result.y, content="-3")
}

///|
test "@draw/floor/boundary_values" {
  // Test case with boundary values
  let v = Vec2::new(x=0.0, y=-0.1)
  let result = @draw.Vec2::floor(v)
  inspect(result.x, content="0")
  inspect(result.y, content="-1")
}

///|
test "@draw.Vec2::floor/basic" {
  // Test basic positive numbers
  let v = vec2(1.7, 2.3)
  inspect(v.floor(), content="{x: 1, y: 2}")

  // Test zero components
  let v2 = vec2(0.9, 0.1)
  inspect(v2.floor(), content="{x: 0, y: 0}")
}

///|
test "@draw.Vec2::floor/negative" {
  // Test negative numbers
  // For negative numbers, floor should round down to the next lower integer
  let v = vec2(-1.3, -2.7)
  inspect(v.floor(), content="{x: -2, y: -3}")
}

///|
test "@draw.Vec2::floor/mixed" {
  // Test mixed positive and negative numbers with fractional parts
  let v = vec2(-1.8, 2.8)
  inspect(v.floor(), content="{x: -2, y: 2}")
}

///|
test "@draw.Vec2::ceil/positive_numbers" {
  let v : Vec2 = Vec2::new(x=1.5, y=2.3)
  let result = @draw.Vec2::ceil(v)
  inspect(result, content="{x: 2, y: 3}")
}

///|
test "@draw.Vec2::ceil/negative_numbers" {
  let v : Vec2 = Vec2::new(x=-1.7, y=-2.9)
  let result = @draw.Vec2::ceil(v)
  inspect(result, content="{x: -1, y: -2}")
}

///|
test "@draw.Vec2::ceil/boundary_case" {
  let v : Vec2 = Vec2::new(x=1.0, y=-1.0)
  let result = @draw.Vec2::ceil(v)
  inspect(result, content="{x: 1, y: -1}")
}

///|
test "@draw.Vec2::ceil" {
  // Test basic non-integer components
  let v1 = vec2(1.5, 2.7)
  inspect(v1.ceil(), content="{x: 2, y: 3}")

  // Test negative components
  let v2 = vec2(-1.5, -2.7)
  inspect(v2.ceil(), content="{x: -1, y: -2}")

  // Test already-integer components
  let v3 = vec2(1.0, 2.0)
  inspect(v3.ceil(), content="{x: 1, y: 2}")
}

///|
test "@draw.Vec2::ceil/zero" {
  // Test zero components
  let v = vec2(0.0, 0.0)
  inspect(v.ceil(), content="{x: 0, y: 0}")
}

///|
test "@draw.Vec2::ceil/extreme" {
  // Test very small decimal parts
  let v1 = vec2(1.0001, 2.0001)
  inspect(v1.ceil(), content="{x: 2, y: 3}")

  // Test very large numbers
  let v2 = vec2(999999.1, -999999.1)
  inspect(v2.ceil(), content="{x: 1000000, y: -999999}")
}

///|
test "@draw.round/basic" {
  let v = Vec2::new(x=1.6, y=2.3)
  inspect(v.round(), content="{x: 2, y: 2}")
}

///|
test "@draw.round/negative_numbers" {
  let v = Vec2::new(x=-1.6, y=-2.3)
  inspect(v.round(), content="{x: -2, y: -2}")
}

///|
test "@draw.round/zero" {
  let v = Vec2::new(x=0.0, y=0.0)
  inspect(v.round(), content="{x: 0, y: 0}")
}

///|
test "@draw.round/basic" {
  let v = vec2(1.4, 2.6)
  inspect(v.round(), content="{x: 1, y: 3}")
  let v2 = vec2(-1.6, -2.3)
  inspect(v2.round(), content="{x: -2, y: -2}")
}

///|
test "@draw.round/edge-cases" {
  // Test rounding of exactly halfway values
  let v = vec2(1.5, 2.5)
  inspect(v.round(), content="{x: 2, y: 3}")

  // Test rounding of zeros
  let v2 = vec2(0.0, -0.0)
  inspect(v2.round(), content="{x: 0, y: 0}")
}

///|
test "@draw.round/special-values" {
  // Test rounding of very large numbers
  let v = vec2(999999.6, -999999.6)
  inspect(v.round(), content="{x: 1000000, y: -1000000}")
}

///|
fn assert_vec2_approx_eq2(
  result : Vec2,
  expect : Vec2,
  error : Double
) -> Unit raise Error {
  if (result.x - expect.x).abs() < error && (result.y - expect.y).abs() < error {
    ()
  } else {
    fail(
      "Expecting (\{expect.x}, \{expect.y}), got (\{result.x}, \{result.y}) instead",
    )
  }
}

///|
test "@draw.Vec2::round_to_fixed/basic" {
  let v = vec2(1.23456, -7.89012)
  assert_vec2_approx_eq2(v.round_to_fixed(2), vec2(1.23, -7.89), 0.0001)
}

///|
test "@draw.Vec2::round_to_fixed/zero_digits" {
  let v = vec2(1.23456, -7.89012)
  assert_vec2_approx_eq2(v.round_to_fixed(0), vec2(1.0, -8.0), 0.0001)
}

///|
test "@draw.Vec2::round_to_fixed/negative_digits" {
  let v = vec2(123.456, -789.012)
  assert_vec2_approx_eq2(v.round_to_fixed(-2), vec2(100.0, -800.0), 0.0001)
}

///|
test "@draw.Vec2::round_to_fixed" {
  // Test the case with zero digits, expecting that the components should be rounded to the nearest integer.
  let v1 = Vec2::new(x=12.345, y=-0.9876)
  let v1_rounded = @draw.Vec2::round_to_fixed(v1, 0)
  inspect(v1_rounded, content="{x: 12, y: -1}")

  // Test the case with negative digits, expecting the components should be rounded to the nearest 10^(-digits).
  let v2 = Vec2::new(x=1234.5678, y=-8765.4321)
  let v2_rounded = @draw.Vec2::round_to_fixed(v2, -2)
  inspect(v2_rounded, content="{x: 1200, y: -8800}")
}

///|
test "@draw.Vec2::round_to_fixed/large_digits" {
  // Test extreme case where digits is too large, expecting the result might approximate the original value due to precision limit.
  let v3 = Vec2::new(x=0.123456789, y=-0.987654321)
  let v3_rounded = @draw.Vec2::round_to_fixed(v3, 50)
  inspect(v3_rounded, content="{x: 0.123456789, y: -0.987654321}")
} // Test `round_to_multiple` with positive multiple, boundary value just below and exactly at multiple

///|
test "@draw.round_to_multiple/positive_multiple" {
  let v1 = vec2(5.99, 10.01)
  let v2 = vec2(6.0, 12.0)
  inspect(v1.round_to_multiple(3.0), content="{x: 6, y: 9}")
  inspect(v2.round_to_multiple(3.0), content="{x: 6, y: 12}")
}

// Test `round_to_multiple` with negative multiple
///|
test "@draw.round_to_multiple/negative_multiple" {
  let v = vec2(11.5, 24.3)
  inspect(v.round_to_multiple(-5.0), content="{x: 10, y: 25}")
}

// Test `round_to_multiple` with zero multiple
///|
test "@draw.round_to_multiple/zero_multiple" {
  let v = vec2(8.7, 15.4)
  inspect(v.round_to_multiple(0.0), content="{x: 8.7, y: 15.4}")
}

///|
test "@draw.round_to_multiple" {
  // Test normal case
  let v = vec2(3.7, 2.3)
  inspect(v.round_to_multiple(1.0), content="{x: 4, y: 2}")

  // Test with non-unit multiple
  let v2 = vec2(7.6, 5.3)
  inspect(v2.round_to_multiple(2.0), content="{x: 8, y: 6}")
}

///|
test "@draw.round_to_multiple/boundary" {
  // Test zero multiple - should return original vector
  let v = vec2(3.7, 2.3)
  inspect(v.round_to_multiple(0.0), content="{x: 3.7, y: 2.3}")
}

///|
test "@draw.round_to_multiple/small-values" {
  // Test with small values and small multiple
  let v = vec2(0.13, 0.27)
  inspect(v.round_to_multiple(0.1), content="{x: 0.1, y: 0.30000000000000004}")
}

///|
test "@draw.min/positive_and_negative" {
  let v1 = vec2(5.0, -3.0)
  let v2 = vec2(2.0, 1.0)
  let result = v1.min(v2)
  inspect(result, content="{x: 2, y: -3}")
}

///|
test "@draw.min/boundary_values" {
  let v1 = vec2(@double.infinity, @double.neg_infinity)
  let v2 = vec2(@double.max_value, @double.min_value)
  let result = v1.min(v2)
  inspect(result, content="{x: 1.7976931348623157e+308, y: -Infinity}")
}

///|
test "@draw.min/nan_value" {
  let v1 = vec2(@double.not_a_number, 10.0)
  let v2 = vec2(5.0, @double.not_a_number)
  inspect(v1.min(v2), content="{x: NaN, y: 10}")
}

///|
test "@draw.min/basic" {
  let v1 = Vec2::new(x=1.0, y=2.0)
  let v2 = Vec2::new(x=2.0, y=1.0)
  let result = v1.min(v2)
  inspect(result.x, content="1")
  inspect(result.y, content="1")
}

///|
test "@draw.min/equal-components" {
  let v1 = Vec2::new(x=1.0, y=1.0)
  let v2 = Vec2::new(x=1.0, y=1.0)
  let result = v1.min(v2)
  inspect(result.x, content="1")
  inspect(result.y, content="1")
}

///|
test "@draw.min/negative-values" {
  let v1 = Vec2::new(x=-2.0, y=1.0)
  let v2 = Vec2::new(x=2.0, y=-1.0)
  let result = v1.min(v2)
  inspect(result.x, content="-2")
  inspect(result.y, content="-1")
}

///|
test "@draw.Vec2::max/basic" {
  let v1 = vec2(1.0, 2.0)
  let v2 = vec2(2.0, 1.0)
  let result = v1.max(v2)
  inspect(result.x, content="2")
  inspect(result.y, content="2")
}

///|
test "@draw.Vec2::max/negative" {
  let v1 = vec2(-2.0, -3.0)
  let v2 = vec2(-3.0, -2.0)
  let result = v1.max(v2)
  inspect(result.x, content="-2")
  inspect(result.y, content="-2")
}

///|
test "@draw.Vec2::max/same-values" {
  let v1 = vec2(1.0, 1.0)
  let v2 = vec2(1.0, 1.0)
  let result = v1.max(v2)
  inspect(result.x, content="1")
  inspect(result.y, content="1")
}

///|
test "@draw.Vec2::max/basic_functionality" {
  let vec1 = Vec2::new(x=3.0, y=4.0)
  let vec2 = Vec2::new(x=2.0, y=5.0)
  let result = @draw.Vec2::max(vec1, vec2)
  inspect(result.x, content="3")
  inspect(result.y, content="5")
}

///|
test "@draw.Vec2::max/negative_values" {
  let vec1 = Vec2::new(x=-3.0, y=-4.0)
  let vec2 = Vec2::new(x=-2.0, y=-5.0)
  let result = @draw.Vec2::max(vec1, vec2)
  inspect(result.x, content="-2")
  inspect(result.y, content="-4")
}

///|
test "@draw.Vec2::max/boundary_case" {
  let vec1 = Vec2::new(x=0.0, y=@double.neg_infinity)
  let vec2 = Vec2::new(x=@double.infinity, y=0.0)
  let result = @draw.Vec2::max(vec1, vec2)
  inspect(result.x, content="\{@double.infinity}")
  inspect(result.y, content="0")
}

///|
test "@draw.mix/boundary_t_zero" {
  let v1 = vec2(1.0, 2.0)
  let v2 = vec2(3.0, 4.0)
  inspect(v1.mix(v2, 0.0), content="{x: 1, y: 2}")
}

///|
test "@draw.mix/boundary_t_one" {
  let v1 = vec2(1.0, 2.0)
  let v2 = vec2(3.0, 4.0)
  inspect(v1.mix(v2, 1.0), content="{x: 3, y: 4}")
}

///|
test "@draw.mix/mid_point" {
  let v1 = vec2(1.0, 2.0)
  let v2 = vec2(3.0, 4.0)
  inspect(v1.mix(v2, 0.5), content="{x: 2, y: 3}")
}

///|
test "@draw.Vec2::dot/basic" {
  let v1 = Vec2::new(x=3, y=4)
  let v2 = Vec2::new(x=1, y=2)
  // dot product should be 3*1 + 4*2 = 11
  inspect(@draw.Vec2::dot(v1, v2), content="11")
  let v3 = Vec2::new(x=-2, y=3)
  let v4 = Vec2::new(x=4, y=1)
  // dot product should be -2*4 + 3*1 = -5
  inspect(@draw.Vec2::dot(v3, v4), content="-5")
}

///|
test "@draw.Vec2::dot/zero_vector" {
  let v = Vec2::new(x=3, y=4)
  let zero = Vec2::new(x=0, y=0)
  // dot product with zero vector should be 0
  inspect(@draw.Vec2::dot(v, zero), content="0")
}

///|
test "@draw.Vec2::dot/perpendicular" {
  let v1 = Vec2::new(x=1, y=0)
  let v2 = Vec2::new(x=0, y=1)
  // dot product of perpendicular vectors should be 0
  inspect(@draw.Vec2::dot(v1, v2), content="0")
}

///|
test "@draw.Vec2::dot/basic_functionality" {
  // Test the dot product of two positive vectors with no zero values
  let v1 = vec2(1.0, 2.0)
  let v2 = vec2(3.0, 4.0)
  inspect(@draw.Vec2::dot(v1, v2), content="11")
}

///|
test "@draw.Vec2::dot/zero_vectors" {
  // Test the dot product of zero vectors
  let v1 = vec2(0.0, 0.0)
  let v2 = vec2(0.0, 0.0)
  inspect(@draw.Vec2::dot(v1, v2), content="0")
}

///|
test "@draw.Vec2::dot/negative_values" {
  // Test the dot product with negative values
  let v1 = vec2(-1.0, -2.0)
  let v2 = vec2(3.0, 4.0)
  inspect(@draw.Vec2::dot(v1, v2), content="-11")
}

///|
test "@draw.Vec2::cross/positive_coords" {
  let v1 = Vec2::new(x=3.0, y=4.0)
  let v2 = Vec2::new(x=1.0, y=2.0)
  inspect(@draw.Vec2::cross(v1, v2), content="2")
}

///|
test "@draw.Vec2::cross/negative_coords" {
  let v1 = Vec2::new(x=-3.0, y=-4.0)
  let v2 = Vec2::new(x=-1.0, y=-2.0)
  inspect(@draw.Vec2::cross(v1, v2), content="2")
}

///|
test "@draw.Vec2::cross/boundary_values" {
  let v1 = Vec2::new(x=1.0e-308, y=1.0e-308)
  let v2 = Vec2::new(x=1.0, y=1.0)
  inspect(@draw.Vec2::cross(v1, v2), content="0")
}

///|
test "@draw.Vec2::cross/perpendicular" {
  let v1 = vec2(1.0, 0.0)
  let v2 = vec2(0.0, 1.0)
  inspect(v1.cross(v2), content="1")
  inspect(v2.cross(v1), content="-1")
}

///|
test "@draw.Vec2::cross/parallel" {
  let v1 = vec2(2.0, 0.0)
  let v2 = vec2(3.0, 0.0)
  inspect(v1.cross(v2), content="0")
  let v3 = vec2(0.0, 2.0)
  let v4 = vec2(0.0, 4.0)
  inspect(v3.cross(v4), content="0")
}

///|
test "@draw.Vec2::cross/arbitrary" {
  let v1 = vec2(2.0, 3.0)
  let v2 = vec2(4.0, 1.0)
  inspect(v1.cross(v2), content="-10")
  inspect(v2.cross(v1), content="10")
}

///|
fn assert_approx_eq_vec(
  result : Vec2,
  expect : Vec2,
  error : Double
) -> Unit raise Error {
  if (result.x - expect.x).abs() < error && (result.y - expect.y).abs() < error {
    ()
  } else {
    fail(
      "Expecting (\{expect.x}, \{expect.y}), got (\{result.x}, \{result.y}) instead",
    )
  }
}

///|
test "@draw.normalize/non-zero" {
  let v = vec2(3.0, 4.0)
  let result = v.normalize()
  // For a 3-4-5 triangle, the normalized vector should be (0.6, 0.8)
  assert_approx_eq_vec(result, vec2(0.6, 0.8), 0.000001)
}

///|
test "@draw.normalize/zero-vector" {
  let v = vec2(0.0, 0.0)
  let result = v.normalize()
  assert_approx_eq_vec(result, vec2(0.0, 0.0), 0.000001)
}

///|
test "@draw.normalize/direction" {
  let v = vec2(-2.0, 2.0)
  let result = v.normalize()
  // The normalized vector should point in the same direction
  // Both x and y components should have same absolute value
  assert_approx_eq_vec(
    result,
    vec2(-0.7071067811865475, 0.7071067811865475),
    0.000001,
  )
}

///|
test "@draw.normalize" {
  // Test with a non-zero vector where length squared is 1
  let vec = Vec2::new(x=3.0, y=4.0)
  let normalized_vec = vec.normalize()
  inspect(normalized_vec, content="{x: 0.6000000000000001, y: 0.8}")

  // Test with a zero vector
  let zero_vec = Vec2::new(x=0.0, y=0.0)
  let normalized_zero_vec = zero_vec.normalize()
  inspect(normalized_zero_vec, content="{x: 0, y: 0}")

  // Test with a vector where length squared is not 1
  let vec_scaled = Vec2::new(x=5.0, y=-12.0)
  let normalized_vec_scaled = vec_scaled.normalize()
  inspect(
    normalized_vec_scaled,
    content="{x: 0.38461538461538464, y: -0.9230769230769231}",
  )
}

///|
test "@draw.normalize/inf" {
  // Test with an infinite component
  let inf_vec = Vec2::new(x=@double.infinity, y=0.0)
  inspect(inf_vec.normalize(), content="{x: NaN, y: 0}")
}

///|
test "@draw.normalize/nan" {
  // Test with a NaN component
  let nan_vec = Vec2::new(x=@double.not_a_number, y=0.0)
  inspect(nan_vec.normalize(), content="{x: NaN, y: 0}")
}

///|
test "@draw.normalize/negative_length" {
  // Test normalization of a vector with negative length
  let neg_len_vec = Vec2::new(x=-1.0, y=0.0)
  inspect(neg_len_vec.normalize(), content="{x: -1, y: 0}")
}

///|
test "@draw.rotate" {
  // Test 90-degree rotations
  let v = vec2(1.0, 0.0)
  inspect(v.rotate(90.0), content="{x: 6.123233995736766e-17, y: 1}")
  inspect(v.rotate(90.0), content="{x: -1, y: 1.2246467991473532e-16}")
  inspect(v.rotate(90.0), content="{x: -1.8369701987210297e-16, y: -1}")
  inspect(v.rotate(90.0), content="{x: 1, y: -2.4492935982947064e-16}")
}

///|
test "@draw.rotate90" {
  // Test 90-degree rotations
  let v = vec2(1.0, 0.0)
  inspect(v.rotate90(), content="{x: 0, y: 1}")
  inspect(v.rotate90(), content="{x: -1, y: 0}")
  inspect(v.rotate90(), content="{x: 0, y: -1}")
  inspect(v.rotate90(), content="{x: 1, y: 0}")
}

///|
test "@draw.rotate/zero" {
  // Test rotation of zero vector and zero angle
  let v = vec2(0.0, 0.0)
  inspect(v.rotate(45.0), content="{x: 0, y: 0}")
  let v2 = vec2(1.0, 1.0)
  inspect(v2.rotate(0.0), content="{x: 1, y: 1}")
}

///|
test "@draw.rotate/360-plus" {
  // Test angles greater than 360 degrees
  let v = vec2(1.0, 0.0)
  inspect(v.rotate(450.0), content="{x: 3.061616997868383e-16, y: 1}")
  inspect(v.rotate(-450.0), content="{x: 1, y: 0}")
}

///|
test "@draw.rotate/zero_rotation" {
  let v = Vec2::new(x=1.0, y=1.0)
  let rotated_v = v.rotate(0.0)
  inspect(rotated_v, content="{x: 1, y: 1}")
}

///|
test "@draw.rotate/180_rotation" {
  let v = Vec2::new(x=1.0, y=1.0)
  let rotated_v = v.rotate(180.0)
  inspect(rotated_v.x.abs().round(), content="1") // Due to floating-point precision
  inspect(rotated_v.y.abs().round(), content="1") // Due to floating-point precision
}

///|
test "@draw.rotate/boundary_values" {
  // Rotate by -360 degrees should result in the same vector
  let v1 = Vec2::new(x=1.0, y=1.0)
  let rotated_v1 = v1.rotate(-360.0)
  inspect(rotated_v1.x.abs().round(), content="1") // Due to floating-point precision
  inspect(rotated_v1.y.abs().round(), content="1") // Due to floating-point precision

  // Rotate by 360 degrees should result in the same vector
  let v2 = Vec2::new(x=1.0, y=1.0)
  let rotated_v2 = v2.rotate(360.0)
  inspect(rotated_v2.x.abs().round(), content="1") // Due to floating-point precision
  inspect(rotated_v2.y.abs().round(), content="1") // Due to floating-point precision
}

///|
fn assert_vec2_approx_eq3(
  v1 : Vec2,
  v2 : Vec2,
  epsilon : Double
) -> Unit raise Error {
  if (v1.x - v2.x).abs() > epsilon || (v1.y - v2.y).abs() > epsilon {
    fail("Expected (\{v2.x}, \{v2.y}), got (\{v1.x}, \{v1.y})")
  }
}

///|
test "@draw.Vec2::rotate_radians" {
  // No rotation (0 radians)
  let v1 = Vec2::new(x=1.0, y=0.0)
  assert_vec2_approx_eq3(
    v1.rotate_radians(0.0),
    Vec2::new(x=1.0, y=0.0),
    0.000001,
  )

  // 90-degree rotation (π/2 radians)
  let v2 = Vec2::new(x=1.0, y=0.0)
  assert_vec2_approx_eq3(
    v2.rotate_radians(@math.PI / 2.0),
    Vec2::new(x=0.0, y=1.0),
    0.000001,
  )

  // 180-degree rotation (π radians)
  let v3 = Vec2::new(x=1.0, y=0.0)
  assert_vec2_approx_eq3(
    v3.rotate_radians(@math.PI),
    Vec2::new(x=-1.0, y=0.0),
    0.000001,
  )
}

///|
fn assert_approx_eq4(
  result : Double,
  expect : Double,
  error : Double
) -> Unit raise Error {
  if (result - expect).abs() < error {
    ()
  } else {
    fail("Expecting \{expect}, got \{result} instead")
  }
}

///|
test "@draw.Vec2::rotate_radians/zero_rotation" {
  let v = Vec2::new(x=1, y=1)
  let rotated_v = @draw.Vec2::rotate_radians(v, 0)
  inspect(rotated_v.x, content="1")
  inspect(rotated_v.y, content="1")
}

///|
test "@draw.Vec2::rotate_radians/pi_rotation" {
  let v = Vec2::new(x=1, y=0)
  let rotated_v = @draw.Vec2::rotate_radians(v, @math.PI)
  assert_approx_eq4(rotated_v.x, -1.0, 0.0001)
  assert_approx_eq4(rotated_v.y, 0.0, 0.0001)
}

///|
test "@draw.Vec2::rotate_radians/half_pi_rotation" {
  let v = Vec2::new(x=0, y=1)
  let rotated_v = @draw.Vec2::rotate_radians(v, @math.PI / 2)
  assert_approx_eq4(rotated_v.x, -1.0, 0.0001)
  assert_approx_eq4(rotated_v.y, 0.0, 0.0001)
}

///|
test "@draw::rotate90/basic" {
  let v1 = Vec2::new(x=1.0, y=2.0)
  inspect(v1.rotate90(), content="{x: -2, y: 1}")
  let v2 = Vec2::new(x=-1.0, y=2.0)
  inspect(v2.rotate90(), content="{x: -2, y: -1}")
  let v3 = Vec2::new(x=0.0, y=0.0)
  inspect(v3.rotate90(), content="{x: 0, y: 0}")
}

///|
test "@draw::rotate90/boundary" {
  let v1 = Vec2::new(x=@int.max_value.to_double(), y=@int.min_value.to_double())
  inspect(v1.rotate90(), content="{x: 2147483648, y: 2147483647}")
  let v2 = Vec2::new(x=@int.min_value.to_double(), y=@int.max_value.to_double())
  inspect(v2.rotate90(), content="{x: -2147483647, y: -2147483648}")
}

///|
test "@draw::rotate90/zero" {
  let v = Vec2::new(x=0.0, y=0.0)
  inspect(v.rotate90(), content="{x: 0, y: 0}")
}

///|
test "@draw.rotate90" {
  // Test basic vector rotation
  let v = vec2(1.0, 1.0)
  inspect(v.rotate90(), content="{x: -1, y: 1}")

  // Test zero vector
  let zero = vec2(0.0, 0.0)
  inspect(zero.rotate90(), content="{x: 0, y: 0}")

  // Test vectors on axes
  let vx = vec2(1.0, 0.0)
  inspect(vx.rotate90(), content="{x: 0, y: 1}")
  let vy = vec2(0.0, 1.0)
  inspect(vy.rotate90(), content="{x: -1, y: 0}")
}

///|
test "@draw.rotate_neg90/basic" {
  let v = Vec2::new(x=1.0, y=2.0)
  inspect(v.rotate_neg90(), content="{x: 2, y: -1}")
}

///|
test "@draw.rotate_neg90/zero_vector" {
  let v = Vec2::new(x=0.0, y=0.0)
  inspect(v.rotate_neg90(), content="{x: 0, y: 0}")
}

///|
test "@draw.rotate_neg90/negative_components" {
  let v = Vec2::new(x=-3.0, y=-4.0)
  inspect(v.rotate_neg90(), content="{x: -4, y: 3}")
}

///|
test "@draw.rotate_neg90" {
  // Basic rotation of (1,0) should give (0,-1)
  let v1 = vec2(1.0, 0.0)
  inspect(v1.rotate_neg90(), content="{x: 0, y: -1}")

  // Zero vector should remain unchanged
  let v2 = vec2(0.0, 0.0)
  inspect(v2.rotate_neg90(), content="{x: 0, y: 0}")

  // Test with negative coordinates (-1,-1)
  let v3 = vec2(-1.0, -1.0)
  inspect(v3.rotate_neg90(), content="{x: -1, y: 1}")
}

///|
test "@draw.Vec2::project_onto" {
  // Test with general vectors
  let v1 = Vec2::new(x=3.0, y=4.0)
  let v2 = Vec2::new(x=1.0, y=2.0)
  let result = @draw.Vec2::project_onto(v1, v2)
  inspect(result, content="{x: 2.2, y: 4.4}")
}

///|
test "@draw.Vec2::project_onto/zero-vector" {
  // Test with a zero vector
  let v1 = Vec2::new(x=0.0, y=0.0)
  let v2 = Vec2::new(x=1.0, y=1.0)
  let result = @draw.Vec2::project_onto(v1, v2)
  inspect(result, content="{x: 0, y: 0}")
}

///|
fn assert_vec2_approx_eq5(
  result : Vec2,
  expect : Vec2,
  error : Double
) -> Unit raise Error {
  if (result.x - expect.x).abs() < error && (result.y - expect.y).abs() < error {
    ()
  } else {
    fail(
      "Expecting (\{expect.x}, \{expect.y}), got (\{result.x}, \{result.y}) instead",
    )
  }
}

///|
test "@draw.Vec2::project_onto/normal" {
  let v1 = vec2(3.0, 4.0)
  let v2 = vec2(1.0, 0.0) // unit vector along x-axis
  assert_approx_eq(v1.project_onto(v2).x, 3.0, 0.001) // projection should be 3.0 along x-axis
  assert_approx_eq(v1.project_onto(v2).y, 0.0, 0.001) // and 0 along y-axis
}

///|
test "@draw.Vec2::project_onto/onto_zero" {
  let v1 = vec2(3.0, 4.0)
  let v2 = vec2(0.0, 0.0)
  assert_vec2_approx_eq5(v1.project_onto(v2), v1, 0.001) // should return original vector unchanged
}

///|
test "@draw.Vec2::project_onto/zero_vector" {
  let v1 = vec2(0.0, 0.0)
  let v2 = vec2(1.0, 1.0)
  assert_vec2_approx_eq5(v1.project_onto(v2), v1, 0.001) // should return zero vector
}

///|
test "@draw.angle/zero_vector" {
  let v = Vec2::new(x=0, y=0)
  inspect(v.angle(), content="0")
}

///|
test "@draw.angle/x_axis_positive" {
  let v = Vec2::new(x=1, y=0)
  inspect(v.angle(), content="0")
}

///|
test "@draw.angle/y_axis_positive" {
  let v = Vec2::new(x=0, y=1)
  inspect(v.angle(), content="90")
}

///|
test "@draw.angle/cardinal-directions" {
  // Test all four cardinal directions (0°, 90°, 180°, -90°)
  let east = Vec2::new(x=1, y=0)
  let north = Vec2::new(x=0, y=1)
  let west = Vec2::new(x=-1, y=0)
  let south = Vec2::new(x=0, y=-1)
  assert_approx_eq(east.angle(), 0.0, 0.0001)
  assert_approx_eq(north.angle(), 90.0, 0.0001)
  assert_approx_eq(west.angle(), 180.0, 0.0001)
  assert_approx_eq(south.angle(), -90.0, 0.0001)
}

///|
test "@draw.angle/diagonal-directions" {
  // Test diagonal vectors (45°, 135°, -135°, -45°)
  let sqrt2_2 = 0.7071067811865476 // 1/√2
  let ne = Vec2::new(x=sqrt2_2, y=sqrt2_2)
  let nw = Vec2::new(x=-sqrt2_2, y=sqrt2_2)
  let sw = Vec2::new(x=-sqrt2_2, y=-sqrt2_2)
  let se = Vec2::new(x=sqrt2_2, y=-sqrt2_2)
  assert_approx_eq(ne.angle(), 45.0, 0.0001)
  assert_approx_eq(nw.angle(), 135.0, 0.0001)
  assert_approx_eq(sw.angle(), -135.0, 0.0001)
  assert_approx_eq(se.angle(), -45.0, 0.0001)
}

///|
test "@draw.angle/zero-vector" {
  // Test zero vector (0, 0)
  let zero = Vec2::new(x=0, y=0)
  assert_approx_eq(zero.angle(), 0.0, 0.0001) // Verify it returns a reasonable value
}

///|
fn assert_approx_eq7(
  result : Double,
  expect : Double,
  error : Double
) -> Unit raise Error {
  if (result - expect).abs() < error {
    ()
  } else {
    fail("Expecting \{expect}, got \{result} instead")
  }
}

///|
test "@draw.angle_radians" {
  // Testing angle for vector on positive x-axis
  let v1 = Vec2::new(x=10, y=0)
  inspect(v1.angle_radians(), content="0")

  // Testing angle for vector on positive y-axis
  let v2 = Vec2::new(x=0, y=10)
  inspect(v2.angle_radians(), content="1.5707963267948966")

  // Testing angle for vector on negative x-axis
  let v3 = Vec2::new(x=-10, y=0)
  inspect(v3.angle_radians(), content="3.141592653589793")

  // Testing angle for vector on negative y-axis
  let v4 = Vec2::new(x=0, y=-10)
  inspect(v4.angle_radians(), content="-1.5707963267948966")
}

///|
fn assert_approx_eq8(
  result : Double,
  expect : Double,
  error : Double
) -> Unit raise Error {
  if (result - expect).abs() < error {
    ()
  } else {
    fail("Expecting \{expect}, got \{result} instead")
  }
}

///|
test "@draw.angle_radians/cardinal_directions" {
  // Test cardinal directions (right, up, left, down)
  assert_approx_eq8(vec2(1, 0).angle_radians(), 0.0, 0.000001)
  assert_approx_eq8(vec2(0, 1).angle_radians(), @math.PI / 2.0, 0.000001)
  assert_approx_eq8(vec2(-1, 0).angle_radians(), @math.PI, 0.000001)
  assert_approx_eq8(vec2(0, -1).angle_radians(), -@math.PI / 2.0, 0.000001)
}

///|
test "@draw.angle_radians/diagonal_directions" {
  // Test diagonal directions (45°, 135°, -135°, -45°)
  let sqrt2_2 = 0.7071067811865476 // sqrt(2)/2
  assert_approx_eq7(
    vec2(sqrt2_2, sqrt2_2).angle_radians(),
    @math.PI / 4.0,
    0.000001,
  )
  assert_approx_eq7(
    vec2(-sqrt2_2, sqrt2_2).angle_radians(),
    3.0 * @math.PI / 4.0,
    0.000001,
  )
  assert_approx_eq7(
    vec2(-sqrt2_2, -sqrt2_2).angle_radians(),
    -3.0 * @math.PI / 4.0,
    0.000001,
  )
  assert_approx_eq7(
    vec2(sqrt2_2, -sqrt2_2).angle_radians(),
    -@math.PI / 4.0,
    0.000001,
  )
}

///|
test "@draw.angle_radians/zero_vector" {
  // The zero vector has an undefined angle
  inspect(vec2(0, 0).angle_radians(), content="0")
}

///|
test "@draw.is_clockwise_from" {
  let v1 = Vec2::new(x=0, y=1)
  let v2 = Vec2::new(x=1, y=0)
  inspect(v1.is_clockwise_from(v2), content="false")
  let v3 = Vec2::new(x=1, y=0)
  let v4 = Vec2::new(x=0, y=1)
  inspect(v3.is_clockwise_from(v4), content="true")
  let v5 = Vec2::new(x=0, y=0)
  let v6 = Vec2::new(x=0, y=0)
  inspect(v5.is_clockwise_from(v6), content="false")
}

///|
test "@draw.is_clockwise_from/perpendicular" {
  let v1 = Vec2::new(x=1, y=0) // pointing right
  let v2 = Vec2::new(x=0, y=1) // pointing up
  inspect(v1.is_clockwise_from(v2), content="true") // right is clockwise from up
  inspect(v2.is_clockwise_from(v1), content="false") // up is not clockwise from right
}

///|
test "@draw.is_clockwise_from/same_direction" {
  let v1 = Vec2::new(x=1, y=0)
  let v2 = Vec2::new(x=1, y=0)
  inspect(v1.is_clockwise_from(v2), content="false") // same direction vectors are not clockwise from each other
}

///|
test "@draw.is_clockwise_from/zero" {
  let v1 = Vec2::new(x=1, y=1)
  let zero = Vec2::new(x=0, y=0)
  inspect(v1.is_clockwise_from(zero), content="false") // zero vector has no direction
  inspect(zero.is_clockwise_from(v1), content="false")
}

///|
test "@draw.Vec2::length/zero_vector" {
  let v = Vec2::new(x=0.0, y=0.0)
  inspect(v.length(), content="0")
}

///|
test "@draw.Vec2::length/unit_vectors" {
  let vx = Vec2::new(x=1.0, y=0.0)
  let vy = Vec2::new(x=0.0, y=1.0)
  inspect(vx.length(), content="1")
  inspect(vy.length(), content="1")
}

///|
test "@draw.Vec2::length/general_vector" {
  let v = Vec2::new(x=3.0, y=4.0)
  inspect(v.length(), content="5")
}

///|
fn assert_approx_eq9(
  result : Double,
  expect : Double,
  error : Double
) -> Unit raise Error {
  if (result - expect).abs() < error {
    ()
  } else {
    fail("Expecting \{expect}, got \{result} instead")
  }
}

///|
test "@draw.Vec2::length" {
  let v = vec2(3.0, 4.0)
  assert_approx_eq9(@draw.Vec2::length(v), 5.0, 0.000001)
}

///|
test "@draw.Vec2::length/zero_vector" {
  let v = vec2(0.0, 0.0)
  assert_approx_eq9(@draw.Vec2::length(v), 0.0, 0.000001)
}

///|
test "@draw.Vec2::length/negative_components" {
  let v = vec2(-3.0, -4.0)
  assert_approx_eq9(@draw.Vec2::length(v), 5.0, 0.000001)
}

///|
test "@draw.Vec2::length_squared/zero_vector" {
  let v = Vec2::new(x=0, y=0)
  inspect(v.length_squared(), content="0")
}

///|
test "@draw.Vec2::length_squared/negative_coordinates" {
  let v = Vec2::new(x=-3, y=-4)
  inspect(v.length_squared(), content="25")
}

///|
test "@draw.Vec2::length_squared/large_coordinates" {
  let v = Vec2::new(x=1.0e10, y=1.0e10)
  inspect(v.length_squared(), content="200000000000000000000")
}

///|
fn assert_approx_eq10(
  result : Double,
  expect : Double,
  error : Double
) -> Unit raise Error {
  if (result - expect).abs() < error {
    ()
  } else {
    fail("Expecting \{expect}, got \{result} instead")
  }
}

///|
test "@draw.Vec2::length_squared" {
  // Basic functionality with positive coordinates
  assert_approx_eq10(
    @draw.Vec2::length_squared({ x: 3.0, y: 4.0 }),
    25.0,
    0.000001,
  )

  // Zero vector case
  assert_approx_eq10(
    @draw.Vec2::length_squared({ x: 0.0, y: 0.0 }),
    0.0,
    0.000001,
  )

  // Negative coordinates
  assert_approx_eq10(
    @draw.Vec2::length_squared({ x: -3.0, y: -4.0 }),
    25.0,
    0.000001,
  )
}

///|
test "@draw.Vec2::distance/intended_behavior" {
  let a = Vec2::new(x=3, y=4)
  let b = Vec2::new(x=0, y=0)
  inspect(@draw.Vec2::distance(a, b), content="5")
}

///|
test "@draw.Vec2::distance/both_vectors_zero" {
  let a = Vec2::new()
  let b = Vec2::new()
  inspect(@draw.Vec2::distance(a, b), content="0")
}

///|
test "@draw.Vec2::distance/distance_between_same_points" {
  let a = Vec2::new(x=2.5, y=3.5)
  inspect(@draw.Vec2::distance(a, a), content="0")
}

///|
test "@draw.Vec2::distance_squared/zero_vectors" {
  let v1 = Vec2::new(x=0.0, y=0.0)
  let v2 = Vec2::new(x=0.0, y=0.0)
  inspect(v1.distance_squared(v2), content="0")
}

///|
test "@draw.Vec2::distance_squared/identical_vectors" {
  let v1 = Vec2::new(x=2.3, y=-1.7)
  let v2 = Vec2::new(x=2.3, y=-1.7)
  inspect(v1.distance_squared(v2), content="0")
}

///|
test "@draw.Vec2::distance_squared/upper_bound" {
  let v1 = Vec2::new(x=1.0e9, y=1.0e9)
  let v2 = Vec2::new(x=-1.0e9, y=-1.0e9)
  let expected = 8.0e18
  inspect(v1.distance_squared(v2), content="\{expected}")
}

///|
fn assert_approx_eq11(
  result : Double,
  expect : Double,
  error : Double
) -> Unit raise Error {
  if (result - expect).abs() < error {
    ()
  } else {
    fail("Expecting \{expect}, got \{result} instead")
  }
}

///|
test "@draw.Vec2::distance_squared/zero_distance" {
  let v = vec2(1.0, 2.0)
  assert_approx_eq11(v.distance_squared(v), 0.0, 0.000001)
}

///|
test "@draw.Vec2::distance_squared/unit_distance" {
  let v1 = vec2(0.0, 0.0)
  let v2 = vec2(1.0, 0.0)
  assert_approx_eq11(v1.distance_squared(v2), 1.0, 0.000001)
  let v3 = vec2(0.0, 1.0)
  assert_approx_eq11(v1.distance_squared(v3), 1.0, 0.000001)
}

///|
test "@draw.Vec2::distance_squared/pythagorean" {
  let v1 = vec2(0.0, 0.0)
  let v2 = vec2(3.0, 4.0)
  assert_approx_eq11(v1.distance_squared(v2), 25.0, 0.000001)
}

///|
test "@draw.Vec2::is_zero/basic" {
  let v1 : Vec2 = Vec2::new()
  inspect(@draw.Vec2::is_zero(v1), content="true")
}

///|
test "@draw.Vec2::is_zero/non-zero-x" {
  let v1 : Vec2 = { x: 1.0, y: 0.0 }
  inspect(@draw.Vec2::is_zero(v1), content="false")
}

///|
test "@draw.Vec2::is_zero/non-zero-y" {
  let v1 : Vec2 = { x: 0.0, y: 1.0 }
  inspect(@draw.Vec2::is_zero(v1), content="false")
}

///|
test "@draw.Vec2::is_zero" {
  let zero = Vec2::new() // default constructor creates a zero vector
  let non_zero = Vec2::new(x=1.0, y=1.0)
  let neg_zero = Vec2::new(x=-0.0, y=-0.0)
  let almost_zero = Vec2::new(x=0.000000001, y=0.000000001)
  inspect(zero.is_zero(), content="true")
  inspect(non_zero.is_zero(), content="false")
  inspect(neg_zero.is_zero(), content="true")
  inspect(almost_zero.is_zero(), content="false")
}

///|
test "Vec2::is_nan" {
  // Test when neither component is NaN
  let v1 = vec2(1.0, 2.0)
  inspect(v1.is_nan(), content="false")

  // Test when x component is NaN
  let v2 = vec2(@double.not_a_number, 2.0)
  inspect(v2.is_nan(), content="true")

  // Test when y component is NaN
  let v3 = vec2(1.0, @double.not_a_number)
  inspect(v3.is_nan(), content="true")

  // Test when both components are NaN
  let v4 = vec2(@double.not_a_number, @double.not_a_number)
  inspect(v4.is_nan(), content="true")
}

///|
test "@draw.is_nan/with_nan_values" {
  let v1 = Vec2::new(x=@double.not_a_number)
  let v2 = Vec2::new(y=@double.not_a_number)
  inspect(v1.is_nan(), content="true")
  inspect(v2.is_nan(), content="true")
}

///|
test "@draw.is_nan/without_nan_values" {
  let v1 = Vec2::new(x=0.0, y=0.0)
  let v2 = Vec2::new(x=1.0, y=-1.0)
  inspect(v1.is_nan(), content="false")
  inspect(v2.is_nan(), content="false")
}

///|
test "Vec2::is_nan/with_inf_values" {
  let v1 = Vec2::new(x=@double.infinity)
  let v2 = Vec2::new(y=@double.neg_infinity)
  inspect(v1.is_nan(), content="false")
  inspect(v2.is_nan(), content="false")
}

///|
test "@draw.is_inf/positive_infinity" {
  let v = Vec2::new(x=@double.infinity)
  inspect(v.is_inf(), content="true")
}

///|
test "@draw.is_inf/negative_infinity" {
  let v = Vec2::new(x=@double.neg_infinity)
  inspect(v.is_inf(), content="true")
}

///|
test "@draw.is_inf/no_infinity" {
  let v = Vec2::new(x=1.0, y=2.0)
  inspect(v.is_inf(), content="false")
}

///|
test "@draw.is_inf" {
  let normal_vec = vec2(1.0, 2.0)
  inspect(normal_vec.is_inf(), content="false")
  let inf_x = vec2(@double.infinity, 0.0)
  inspect(inf_x.is_inf(), content="true")
  let inf_y = vec2(0.0, @double.infinity)
  inspect(inf_y.is_inf(), content="true")
  let neg_inf = vec2(@double.neg_infinity, @double.neg_infinity)
  inspect(neg_inf.is_inf(), content="true")
}

///|
test "@draw.Vec2::to_json" {
  let v = vec2(1.0, 2.0)
  let got = v.to_json().stringify()
  inspect(
    got,
    content=
      #|{"x":1,"y":2}
    ,
  )
}

///|
test "@draw.Vec2::from_json" {
  let json_str =
    #|{"x":1,"y":2}
  let json = @json.parse(json_str)
  let got : Vec2 = @json.from_json(json)
  inspect(got, content="{x: 1, y: 2}")
}
