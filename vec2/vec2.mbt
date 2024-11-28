/// Vec2 represents a 2D vector.
pub(all) struct Vec2 {
  mut x : Double
  mut y : Double
}

/// Vec2::new returns a new Vec2.
pub fn Vec2::new(x~ : Double = 0, y~ : Double = 0) -> Vec2 {
  { x, y }
}

/// vec2 returns a new Vec2.
pub fn vec2(x : Double, y : Double) -> Vec2 {
  { x, y }
}

/// Vec2::from_angle returns a new unit vec2 from an angle in degrees.
pub fn Vec2::from_angle(angle : Double) -> Vec2 {
  let rad = angle * @math.PI / 180
  from_angle_radians(rad)
}

/// Vec2::from_angle_radians returns a new unit vec2 from an angle in radians.
pub fn Vec2::from_angle_radians(rad : Double) -> Vec2 {
  let x = @math.cos(rad)
  let y = @math.sin(rad)
  { x, y }
}

/// clone returns a new copy of this Vec2.
pub fn clone(self : Vec2) -> Vec2 {
  { x: self.x, y: self.y }
}

/// copy copies `v` into this Vec2.
pub fn copy(self : Vec2, v : Vec2) -> Vec2 {
  self.x = v.x
  self.y = v.y
  self
}

/// is_valid returns whether or not this Vec2 is valid.
pub fn is_valid(self : Vec2) -> Bool {
  not(self.x.is_inf() || self.x.is_nan() || self.y.is_inf() || self.y.is_nan())
}

/// affine_transform transforms this Vec2 by the `affine_matrix`.
/// This is used when transforming a point or position.
pub fn affine_transform(self : Vec2, affine_matrix : AffineMatrix) -> Vec2 {
  let { x: x0, y: y0 } = self
  let { a, b, c, d, tx, ty } = affine_matrix
  self.x = a * x0 + c * y0 + tx
  self.y = b * x0 + d * y0 + ty
  self
}

/// affine_transform_without_translation transforms this Vec2 by the `affine_matrix`
/// but without performing translation.
/// This is used when transforming a normal or tangent.
pub fn affine_transform_without_translation(
  self : Vec2,
  affine_matrix : AffineMatrix
) -> Vec2 {
  let { x: x0, y: y0 } = self
  let { a, b, c, d, .. } = affine_matrix
  self.x = a * x0 + c * y0
  self.y = b * x0 + d * y0
  self
}

/// transform transforms this Vec2.
pub fn transform(self : Vec2, transform : Transform) -> Vec2 {
  self.affine_transform(AffineMatrix::from_transform(transform))
}
