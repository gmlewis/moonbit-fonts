test "AffineMatrix::from_transform/identity" {
  // Test with identity transform (all default values)
  let transform = Transform::new()
  let result = AffineMatrix::from_transform(transform)
  inspect!(result.a, content="1")
  inspect!(result.b, content="0")
  inspect!(result.c, content="0")
  inspect!(result.d, content="1")
  inspect!(result.tx, content="0")
  inspect!(result.ty, content="0")
}

test "AffineMatrix::from_transform/translation" {
  // Test with only translation
  let transform = Transform::new(position=@draw.vec2(10, 20))
  let result = AffineMatrix::from_transform(transform)
  inspect!(result.tx, content="10")
  inspect!(result.ty, content="20")
}

test "AffineMatrix::from_transform/combined" {
  // Test with combined transformations
  let transform = Transform::new(
    position=@draw.vec2(1, 1),
    rotation=90,
    scale=@draw.vec2(2, 2),
    skew=45,
    origin=@draw.vec2(5, 5),
  )
  let result = AffineMatrix::from_transform(transform)
  // Result should be non-identity matrix with all components affected
  inspect!(result.is_identity(), content="false")
}

test "AffineMatrix::from_translation/basic" {
  let vec1 = @draw.vec2(10.0, 20.0)
  let mat1 = AffineMatrix::from_translation(vec1)
  inspect!(mat1.a, content="1")
  inspect!(mat1.b, content="0")
  inspect!(mat1.c, content="0")
  inspect!(mat1.d, content="1")
  inspect!(mat1.tx, content="10")
  inspect!(mat1.ty, content="20")
}

test "AffineMatrix::from_translation/zero_vector" {
  let vec2 = @draw.vec2(0.0, 0.0)
  let mat2 = AffineMatrix::from_translation(vec2)
  inspect!(mat2.a, content="1")
  inspect!(mat2.b, content="0")
  inspect!(mat2.c, content="0")
  inspect!(mat2.d, content="1")
  inspect!(mat2.tx, content="0")
  inspect!(mat2.ty, content="0")
}

test "AffineMatrix::from_translation/negative_vector" {
  let vec3 = @draw.vec2(-5.0, -15.0)
  let mat3 = AffineMatrix::from_translation(vec3)
  inspect!(mat3.a, content="1")
  inspect!(mat3.b, content="0")
  inspect!(mat3.c, content="0")
  inspect!(mat3.d, content="1")
  inspect!(mat3.tx, content="-5")
  inspect!(mat3.ty, content="-15")
}

test "AffineMatrix::from_translation_points/basic" {
  let p1 = @draw.vec2(1.0, 2.0)
  let p2 = @draw.vec2(4.0, 6.0)
  let m = AffineMatrix::from_translation_points(p1, p2)
  inspect!(m.a, content="1")
  inspect!(m.b, content="0")
  inspect!(m.c, content="0")
  inspect!(m.d, content="1")
  inspect!(m.tx, content="3") // 4 - 1
  inspect!(m.ty, content="4") // 6 - 2
}

test "AffineMatrix::from_translation_points/zero-translation" {
  let p = @draw.vec2(3.0, 4.0)
  let m = AffineMatrix::from_translation_points(p, p)
  inspect!(m.a, content="1")
  inspect!(m.b, content="0")
  inspect!(m.c, content="0")
  inspect!(m.d, content="1")
  inspect!(m.tx, content="0")
  inspect!(m.ty, content="0")
}

test "AffineMatrix::from_translation_points/negative" {
  let p1 = @draw.vec2(-2.0, -3.0)
  let p2 = @draw.vec2(-5.0, -8.0)
  let m = AffineMatrix::from_translation_points(p1, p2)
  inspect!(m.a, content="1")
  inspect!(m.b, content="0")
  inspect!(m.c, content="0")
  inspect!(m.d, content="1")
  inspect!(m.tx, content="-3") // -5 - (-2)
  inspect!(m.ty, content="-5") // -8 - (-3)
}

test "@draw.AffineMatrix::from_translation_points" {
  let p1 = vec2(1.0, 2.0)
  let p2 = vec2(4.0, 6.0)
  let translation = @draw.AffineMatrix::from_translation_points(p1, p2)
  inspect!(translation.tx, content="3")
  inspect!(translation.ty, content="4")
}

test "@draw.AffineMatrix::from_translation_points/zero_vector" {
  let p1 = vec2(0.0, 0.0)
  let p2 = vec2(0.0, 0.0)
  let translation = @draw.AffineMatrix::from_translation_points(p1, p2)
  inspect!(translation.tx, content="0")
  inspect!(translation.ty, content="0")
}

test "@draw.AffineMatrix::from_translation_points/negative_values" {
  let p1 = vec2(-3.0, 5.0)
  let p2 = vec2(2.0, -1.0)
  let translation = @draw.AffineMatrix::from_translation_points(p1, p2)
  inspect!(translation.tx, content="5")
  inspect!(translation.ty, content="-6")
}

test "AffineMatrix::from_center_scale/identity" {
  // Test identity transformation (scale = 1)
  let center = @draw.vec2(10.0, 10.0)
  let scale = @draw.vec2(1.0, 1.0)
  let m = AffineMatrix::from_center_scale(center, scale)
  inspect!(m.a, content="1")
  inspect!(m.b, content="0")
  inspect!(m.c, content="0")
  inspect!(m.d, content="1")
  inspect!(m.tx, content="0")
  inspect!(m.ty, content="0")
}

test "AffineMatrix::from_center_scale/uniform_scale" {
  // Test uniform scaling from origin
  let center = @draw.vec2(0.0, 0.0)
  let scale = @draw.vec2(2.0, 2.0)
  let m = AffineMatrix::from_center_scale(center, scale)
  inspect!(m.a, content="2")
  inspect!(m.d, content="2")
  inspect!(m.tx, content="0")
  inspect!(m.ty, content="0")
}

test "AffineMatrix::from_center_scale/non_uniform_scale" {
  // Test non-uniform scaling from non-origin center
  let center = @draw.vec2(1.0, 2.0)
  let scale = @draw.vec2(2.0, 3.0)
  let m = AffineMatrix::from_center_scale(center, scale)
  inspect!(m.a, content="2")
  inspect!(m.d, content="3")
  inspect!(m.tx, content="-1")
  inspect!(m.ty, content="-4")
}

test "@draw.AffineMatrix::clone/basic_functionality" {
  let matrix = AffineMatrix::new(a=1, b=2, c=3, d=4, tx=5, ty=6)
  let cloned_matrix = @draw.AffineMatrix::clone(matrix)
  inspect!(cloned_matrix, content="{a: 1, b: 2, c: 3, d: 4, tx: 5, ty: 6}")
}

test "@draw.AffineMatrix::clone/boundary_values" {
  // Test with zero values
  let matrix_zero = AffineMatrix::new(a=0, b=0, c=0, d=0, tx=0, ty=0)
  let cloned_matrix_zero = @draw.AffineMatrix::clone(matrix_zero)
  inspect!(cloned_matrix_zero, content="{a: 0, b: 0, c: 0, d: 0, tx: 0, ty: 0}")

  // Test with maximum Double values
  let matrix_max = AffineMatrix::new(
    a=@double.max_value,
    b=@double.max_value,
    c=@double.max_value,
    d=@double.max_value,
    tx=@double.max_value,
    ty=@double.max_value,
  )
  let cloned_matrix_max = @draw.AffineMatrix::clone(matrix_max)
  inspect!(
    cloned_matrix_max,
    content="{a: \{@double.max_value}, b: \{@double.max_value}, c: \{@double.max_value}, d: \{@double.max_value}, tx: \{@double.max_value}, ty: \{@double.max_value}}",
  )
}

test "@draw.AffineMatrix::clone/NaN_values" {
  // Test with NaN values
  let matrix_nan = AffineMatrix::new(
    a=@double.not_a_number,
    b=@double.not_a_number,
    c=@double.not_a_number,
    d=@double.not_a_number,
    tx=@double.not_a_number,
    ty=@double.not_a_number,
  )
  inspect!(
    matrix_nan,
    content="{a: NaN, b: NaN, c: NaN, d: NaN, tx: NaN, ty: NaN}",
  )
}

test "@draw.AffineMatrix::invert/basic" {
  let matrix = @draw.AffineMatrix::new(a=2, b=0, c=0, d=2, tx=1, ty=1)
  let inverted_matrix = @draw.invert(matrix)
  inspect!(
    inverted_matrix,
    content="{a: 0.5, b: 0, c: 0, d: 0.5, tx: -0.5, ty: -0.5}",
  )
}

test "@draw.AffineMatrix::invert/identity" {
  let identity_matrix = @draw.AffineMatrix::new()
  let inverted_identity = @draw.invert(identity_matrix)
  inspect!(inverted_identity, content="{a: 1, b: 0, c: 0, d: 1, tx: 0, ty: 0}")
}

test "@draw.AffineMatrix::invert/non_invertible_matrix" {
  let non_invertible_matrix = @draw.AffineMatrix::new(
    a=1,
    b=1,
    c=2,
    d=2,
    tx=1,
    ty=1,
  )
  ignore(@draw.invert(non_invertible_matrix))
}

test "@draw.op_mul/identity" {
  let id = AffineMatrix::new() // identity matrix
  let m = AffineMatrix::new(a=2, b=0, c=0, d=2, tx=1, ty=1) // scale + translate
  let result = m.op_mul(id)
  inspect!(result.a, content="2")
  inspect!(result.b, content="0")
  inspect!(result.c, content="0")
  inspect!(result.d, content="2")
  inspect!(result.tx, content="1")
  inspect!(result.ty, content="1")
}

test "@draw.op_mul/translation" {
  // Test translation composition
  let t1 = AffineMatrix::new(a=1, b=0, c=0, d=1, tx=2, ty=3) // translate(2,3)
  let t2 = AffineMatrix::new(a=1, b=0, c=0, d=1, tx=4, ty=5) // translate(4,5)
  let result = t1.op_mul(t2)
  inspect!(result.tx, content="6") // translations should add
  inspect!(result.ty, content="8")
}

test "@draw.op_mul/scale_rotate" {
  // Scale by 2 then rotate 90 degrees
  let s = AffineMatrix::new(a=2, b=0, c=0, d=2, tx=0, ty=0)
  let r = AffineMatrix::new(a=0, b=1, c=-1, d=0, tx=0, ty=0)
  let result = s.op_mul(r)
  inspect!(result.a, content="0")
  inspect!(result.b, content="2")
  inspect!(result.c, content="-2")
  inspect!(result.d, content="0")
}

test "@draw.mul_without_translation/identity" {
  // Multiplying by identity matrix should keep the original matrix unchanged except for translation
  let m1 = AffineMatrix::new(a=2, b=3, c=4, d=5, tx=10, ty=20)
  let identity = AffineMatrix::new()
  let result = m1.mul_without_translation(identity)
  inspect!(result.a, content="2")
  inspect!(result.b, content="3")
  inspect!(result.c, content="4")
  inspect!(result.d, content="5")
  // Translation components should remain unchanged from m1
  inspect!(result.tx, content="10")
  inspect!(result.ty, content="20")
}

test "@draw.mul_without_translation/rotation" {
  // Test multiplication of rotation matrices
  let m1 = AffineMatrix::new(a=0, b=1, c=-1, d=0, tx=5, ty=5) // 90-degree rotation
  let m2 = AffineMatrix::new(a=0, b=1, c=-1, d=0, tx=10, ty=10) // Another 90-degree rotation
  let result = m1.mul_without_translation(m2)
  // Result should be -1,0,0,-1 (180-degree rotation)
  inspect!(result.a, content="-1")
  inspect!(result.b, content="0")
  inspect!(result.c, content="0")
  inspect!(result.d, content="-1")
  // Original translation should be preserved
  inspect!(result.tx, content="5")
  inspect!(result.ty, content="5")
}

test "@draw.mul_without_translation/scale" {
  // Test multiplication with scaling matrices
  let m1 = AffineMatrix::new(a=2, b=0, c=0, d=3, tx=1, ty=1) // Scale by 2,3
  let m2 = AffineMatrix::new(a=4, b=0, c=0, d=5, tx=2, ty=2) // Scale by 4,5
  let result = m1.mul_without_translation(m2)
  // Result should be scaled by 8,15
  inspect!(result.a, content="8")
  inspect!(result.b, content="0")
  inspect!(result.c, content="0")
  inspect!(result.d, content="15")
  // Original translation should be preserved
  inspect!(result.tx, content="1")
  inspect!(result.ty, content="1")
}

test "@draw.pre_mul/basic_case" {
  let a = @draw.AffineMatrix::new(a=1, b=2, c=3, d=4, tx=5, ty=6)
  let b = @draw.AffineMatrix::new(a=7, b=8, c=9, d=10, tx=11, ty=12)
  let result = a.pre_mul(b)
  inspect!(result, content="{a: 25, b: 28, c: 57, d: 64, tx: 100, ty: 112}")
}

test "@draw.pre_mul/identity_matrix" {
  let a = @draw.AffineMatrix::new()
  let b = @draw.AffineMatrix::new(a=1, b=0, c=0, d=1, tx=0, ty=0)
  let result = a.pre_mul(b)
  inspect!(result, content="{a: 1, b: 0, c: 0, d: 1, tx: 0, ty: 0}")
}

test "@draw.pre_mul/zero_matrix" {
  let a = @draw.AffineMatrix::new(a=0, b=0, c=0, d=0, tx=0, ty=0)
  let b = @draw.AffineMatrix::new(a=1, b=2, c=3, d=4, tx=5, ty=6)
  let result = a.pre_mul(b)
  inspect!(result, content="{a: 0, b: 0, c: 0, d: 0, tx: 5, ty: 6}")
}

test "@draw.pre_mul_without_translation/basic_functionality" {
  let a = AffineMatrix::new(a=2, b=3, c=4, d=5)
  let b = AffineMatrix::new(a=1, b=0, c=0, d=1)
  let result = a.pre_mul_without_translation(b)
  inspect!(result.a, content="2")
  inspect!(result.b, content="3")
  inspect!(result.c, content="4")
  inspect!(result.d, content="5")
}

test "@draw.pre_mul_without_translation/identity_matrix" {
  let a = AffineMatrix::new(a=1, b=0, c=0, d=1)
  let b = AffineMatrix::new(a=6, b=7, c=8, d=9)
  let result = a.pre_mul_without_translation(b)
  inspect!(result.a, content="6")
  inspect!(result.b, content="7")
  inspect!(result.c, content="8")
  inspect!(result.d, content="9")
}

test "@draw/pre_mul_without_translation/near_zero_determinant" {
  let a = AffineMatrix::new(a=1, b=0, c=0, d=1)
  let b = AffineMatrix::new(a=0.0000001, b=0, c=0, d=0.0000001)
  let result = a.pre_mul_without_translation(b)
  inspect!(result.a, content="1e-7")
  inspect!(result.b, content="0")
  inspect!(result.c, content="0")
  inspect!(result.d, content="1e-7")
}

test "@draw.translate" {
  // Basic translation
  let m = AffineMatrix::new()
  let v = @draw.vec2(2.0, 3.0)
  let result = m.translate(v)
  inspect!(result.tx, content="2")
  inspect!(result.ty, content="3")

  // Translation with zero vector
  let m2 = AffineMatrix::new()
  let v2 = @draw.vec2(0.0, 0.0)
  let result2 = m2.translate(v2)
  inspect!(result2.tx, content="0")
  inspect!(result2.ty, content="0")

  // Translation with non-identity matrix
  let m3 = AffineMatrix::new(a=2.0, d=2.0, tx=1.0, ty=1.0)
  let v3 = @draw.vec2(1.0, 1.0)
  let result3 = m3.translate(v3)
  inspect!(result3.tx, content="3")
  inspect!(result3.ty, content="3")
}

test "@draw.translate/basic_movement" {
  let mat = AffineMatrix::new(a=2, b=3, c=4, d=5, tx=6, ty=7)
  let v = vec2(1, 1)
  inspect!(
    @draw.translate(mat, v),
    content="{a: 2, b: 3, c: 4, d: 5, tx: 12, ty: 15}",
  )
}

test "@draw.translate/zero_translation" {
  let mat = AffineMatrix::new(a=2, b=3, c=4, d=5, tx=6, ty=7)
  let v = vec2(0, 0)
  inspect!(
    @draw.translate(mat, v),
    content="{a: 2, b: 3, c: 4, d: 5, tx: 6, ty: 7}",
  )
}

test "@draw.translate/negative_translation" {
  let mat = AffineMatrix::new(a=2, b=3, c=4, d=5, tx=6, ty=7)
  let v = vec2(-1, -1)
  inspect!(
    @draw.translate(mat, v),
    content="{a: 2, b: 3, c: 4, d: 5, tx: 0, ty: -1}",
  )
}

test "AffineMatrix::rotate" {
  // Test rotation by 0 degrees (identity)
  let m0 = AffineMatrix::new()
  inspect!(m0.rotate(0), content="{a: 1, b: 0, c: 0, d: 1, tx: 0, ty: 0}")

  // Test rotation by 90 degrees
  let m90 = AffineMatrix::new()
  inspect!(
    m90.rotate(90),
    content="{a: 6.123351888008944e-17, b: 1, c: -1, d: 6.123351888008944e-17, tx: 0, ty: 0}",
  )

  // Test rotation by 180 degrees
  let m180 = AffineMatrix::new()
  inspect!(
    m180.rotate(180),
    content="{a: -1, b: 1.2246703776017889e-16, c: -1.2246703776017889e-16, d: -1, tx: 0, ty: 0}",
  )
}

test "AffineMatrix::rotate/360" {
  // Test rotation by 360 degrees (should be equivalent to identity)
  let m360 = AffineMatrix::new()
  inspect!(
    m360.rotate(360),
    content="{a: 1, b: -2.4493407552035777e-16, c: 2.4493407552035777e-16, d: 1, tx: 0, ty: 0}",
  )
}

test "AffineMatrix::rotate/negative" {
  // Test rotation by -90 degrees (should be equivalent to 270 degrees)
  let m_neg90 = AffineMatrix::new()
  inspect!(
    m_neg90.rotate(-90),
    content="{a: 6.123351888008944e-17, b: -1, c: 1, d: 6.123351888008944e-17, tx: 0, ty: 0}",
  )
}

test "AffineMatrix::skew/zero-angle" {
  let m = AffineMatrix::new(a=1, b=0, c=0, d=1)
  let result = m.skew(0)
  inspect!(result.a, content="1")
  inspect!(result.b, content="0")
  inspect!(result.c, content="0")
  inspect!(result.d, content="1")
}

test "AffineMatrix::skew/45-degrees" {
  let m = AffineMatrix::new(a=1, b=0, c=0, d=1)
  let result = m.skew(45)
  inspect!(result.a, content="1")
  inspect!(result.b, content="0")
  inspect!(result.c, content="1")
  inspect!(result.d, content="1")
}

test "AffineMatrix::skew/negative-angle" {
  let m = AffineMatrix::new(a=1, b=0, c=0, d=1)
  let result = m.skew(-90)
  inspect!(result.a, content="1")
  inspect!(result.b, content="0")
  inspect!(result.c, content="-16330924929502260")
  inspect!(result.d, content="1")
}

test "@draw.skew/zero_angle" {
  let matrix = @draw.AffineMatrix::new(a=1, b=2, c=3, d=4, tx=5, ty=6)
  let result = @draw.skew(matrix, 0)
  inspect!(result.c, content="3")
  inspect!(result.d, content="4")
}

test "@draw.skew/positive_angle" {
  let matrix = @draw.AffineMatrix::new(a=1, b=2, c=0, d=0, tx=5, ty=6)
  let result = @draw.skew(matrix, 45)
  inspect!(result.c, content="1")
  inspect!(result.d, content="2")
}

test "@draw.skew/negative_angle" {
  let matrix = @draw.AffineMatrix::new(a=1, b=2, c=0, d=0, tx=5, ty=6)
  let result = @draw.skew(matrix, -45)
  inspect!(result.c, content="-1")
  inspect!(result.d, content="-2")
}

test "@draw.scale/identity" {
  // Identity matrix scaled by (1,1) should remain identity
  let m = AffineMatrix::new()
  let v = @draw.vec2(1, 1)
  let result = m.scale(v)
  inspect!(result.a, content="1")
  inspect!(result.b, content="0")
  inspect!(result.c, content="0")
  inspect!(result.d, content="1")
}

test "@draw.scale/uniform" {
  // Uniform scaling by 2
  let m = AffineMatrix::new(a=1, b=1, c=1, d=1)
  let v = @draw.vec2(2, 2)
  let result = m.scale(v)
  inspect!(result.a, content="2")
  inspect!(result.b, content="2")
  inspect!(result.c, content="2")
  inspect!(result.d, content="2")
}

test "@draw.scale/non_uniform" {
  // Non-uniform scaling, scale x by 2 and y by 0.5
  let m = AffineMatrix::new(a=1, b=1, c=1, d=1)
  let v = @draw.vec2(2, 0.5)
  let result = m.scale(v)
  inspect!(result.a, content="2")
  inspect!(result.b, content="2")
  inspect!(result.c, content="0.5")
  inspect!(result.d, content="0.5")
}

test "@draw.scale_scalar" {
  // Test simple scaling case
  let matrix = AffineMatrix::new(a=1, b=2, c=3, d=4, tx=5, ty=6)
  let scaled_matrix = @draw.scale_scalar(matrix, 2.0)
  assert_eq!(scaled_matrix.a, 2)
  assert_eq!(scaled_matrix.b, 4)
  assert_eq!(scaled_matrix.c, 6)
  assert_eq!(scaled_matrix.d, 8)

  // Test scaling by zero
  let matrix_zero = AffineMatrix::new(a=1, b=2, c=3, d=4, tx=5, ty=6)
  let scaled_zero_matrix = @draw.scale_scalar(matrix_zero, 0.0)
  assert_eq!(scaled_zero_matrix.a, 0)
  assert_eq!(scaled_zero_matrix.b, 0)
  assert_eq!(scaled_zero_matrix.c, 0)
  assert_eq!(scaled_zero_matrix.d, 0)

  // Test scaling by negative number
  let matrix_negative = AffineMatrix::new(a=1, b=2, c=3, d=4, tx=5, ty=6)
  let scaled_negative_matrix = @draw.scale_scalar(matrix_negative, -1.5)
  assert_eq!(scaled_negative_matrix.a, -1.5)
  assert_eq!(scaled_negative_matrix.b, -3.0)
  assert_eq!(scaled_negative_matrix.c, -4.5)
  assert_eq!(scaled_negative_matrix.d, -6.0)
}

test "@draw.is_invertible/identity" {
  // Identity matrix should be invertible (determinant = 1)
  let m = AffineMatrix::new()
  inspect!(m.is_invertible(), content="true")
}

test "@draw.is_invertible/zero_determinant" {
  // Matrix with zero determinant (a*d - b*c = 0) should not be invertible
  let m = AffineMatrix::new(a=1, b=2, c=2, d=4) // determinant = 1*4 - 2*2 = 0
  inspect!(m.is_invertible(), content="false")
}

test "@draw.is_invertible/non_zero_determinant" {
  // Matrix with non-zero determinant should be invertible
  let m = AffineMatrix::new(a=2, b=1, c=1, d=1) // determinant = 2*1 - 1*1 = 1
  inspect!(m.is_invertible(), content="true")
}

test "@draw.is_invertible/identity_matrix" {
  let identity_matrix = AffineMatrix::new(a=1, b=0, c=0, d=1, tx=0, ty=0)
  inspect!(@draw.is_invertible(identity_matrix), content="true")
}

test "@draw.is_invertible/non-invertible_matrix" {
  let non_invertible_matrix = AffineMatrix::new(a=1, b=1, c=2, d=2, tx=0, ty=0)
  inspect!(@draw.is_invertible(non_invertible_matrix), content="false")
}

test "@draw.is_invertible/invertible_matrix" {
  let invertible_matrix = AffineMatrix::new(a=2, b=1, c=1, d=3, tx=0, ty=0)
  inspect!(@draw.is_invertible(invertible_matrix), content="true")
}

test "@draw.is_mirror" {
  // Identity matrix (no mirroring)
  let m1 = AffineMatrix::new()
  inspect!(m1.is_mirror(), content="false")

  // Mirror across X axis (y-scale is negative)
  let m2 = AffineMatrix::new(a=1, b=0, c=0, d=-1)
  inspect!(m2.is_mirror(), content="true")

  // Mirror across Y axis (x-scale is negative)
  let m3 = AffineMatrix::new(a=-1, b=0, c=0, d=1)
  inspect!(m3.is_mirror(), content="true")

  // No mirroring with translation
  let m4 = AffineMatrix::new(tx=10, ty=20)
  inspect!(m4.is_mirror(), content="false")

  // Mirror with rotation (90 degrees)
  let m5 = AffineMatrix::new(a=0, b=1, c=-1, d=0)
  inspect!(m5.is_mirror(), content="false")
}

test "AffineMatrix::is_identity" {
  // Test identity matrix
  let identity = AffineMatrix::new()
  inspect!(identity.is_identity(), content="true")

  // Test non-identity matrices
  let translated = AffineMatrix::new(tx=1.0)
  inspect!(translated.is_identity(), content="false")
  let rotated = AffineMatrix::new(a=0.0, b=1.0, c=-1.0, d=0.0)
  inspect!(rotated.is_identity(), content="false")
}

test "AffineMatrix::is_identity/scale" {
  // Test various scales
  let scale_x = AffineMatrix::new(a=2.0)
  inspect!(scale_x.is_identity(), content="false")
  let scale_y = AffineMatrix::new(d=2.0)
  inspect!(scale_y.is_identity(), content="false")
  let scale_neg = AffineMatrix::new(a=-1.0, d=-1.0)
  inspect!(scale_neg.is_identity(), content="false")
}

test "AffineMatrix::is_identity/zero" {
  // Test zero matrix
  let zero = AffineMatrix::new(a=0.0, b=0.0, c=0.0, d=0.0, tx=0.0, ty=0.0)
  inspect!(zero.is_identity(), content="false")
}

test "@draw.is_identity" {
  let matrix = AffineMatrix::new()
  inspect!(@draw.is_identity(matrix), content="true")
}

test "@draw.is_identity/non_identity" {
  let matrix = AffineMatrix::new(a=2, b=0, c=0, d=1, tx=0, ty=0)
  inspect!(@draw.is_identity(matrix), content="false")
}

test "@draw.is_identity/negative_values" {
  let matrix = AffineMatrix::new(a=1, b=-1, c=0, d=1, tx=0, ty=0)
  inspect!(@draw.is_identity(matrix), content="false")
}

test "@draw.to_transform/identity" {
  // Test identity matrix transformation
  let matrix = AffineMatrix::new() // Creates identity matrix
  let transform = matrix.to_transform()
  inspect!(transform.position, content="{x: 0, y: 0}")
  inspect!(transform.rotation, content="57.29577951308232")
  inspect!(transform.scale, content="{x: 1, y: 1}")
  inspect!(transform.skew, content="0")
  inspect!(transform.origin, content="{x: 0, y: 0}")
}

test "@draw.to_transform/translation" {
  // Test pure translation matrix
  let matrix = AffineMatrix::new(tx=5.0, ty=-3.0)
  let transform = matrix.to_transform()
  inspect!(transform.position, content="{x: 5, y: -3}")
  inspect!(transform.rotation, content="57.29577951308232")
  inspect!(transform.scale, content="{x: 1, y: 1}")
  inspect!(transform.skew, content="0")
}

test "@draw.to_transform/zero-scale" {
  // Test matrix with zero scale components
  let matrix = AffineMatrix::new(a=0.0, b=0.0, c=0.0, d=0.0)
  let transform = matrix.to_transform()
  inspect!(transform.position, content="{x: 0, y: 0}")
  inspect!(transform.rotation, content="0")
  inspect!(transform.scale, content="{x: 0, y: 0}")
  inspect!(transform.skew, content="0")
}
