///| Vec2 represents a 2D vector.
pub(all) struct Vec2 {
  mut x : Double
  mut y : Double
} derive(Show, Eq, FromJson, ToJson)

///| Vec2::new returns a new Vec2.
pub fn Vec2::new(x~ : Double = 0, y~ : Double = 0) -> Vec2 {
  { x, y }
}

///| Vec::infinity returns a new Vec2 with infinite x and y.
pub fn Vec2::infinity() -> Vec2 {
  { x: @double.infinity, y: @double.infinity }
}

///| Vec::neg_infinity returns a new Vec2 with negative infinite x and y.
pub fn Vec2::neg_infinity() -> Vec2 {
  { x: @double.neg_infinity, y: @double.neg_infinity }
}

///| vec2 returns a new Vec2.
pub fn vec2(x : Double, y : Double) -> Vec2 {
  { x, y }
}

///| Vec2::from_angle returns a new unit vec2 from an angle in degrees.
pub fn Vec2::from_angle(angle : Double) -> Vec2 {
  let rad = angle * @math.PI / 180
  from_angle_radians(rad)
}

///| Vec2::from_angle_radians returns a new unit vec2 from an angle in radians.
pub fn Vec2::from_angle_radians(rad : Double) -> Vec2 {
  let x = @math.cos(rad)
  let y = @math.sin(rad)
  { x, y }
}

///| clone returns a new copy of this Vec2.
pub fn clone(self : Vec2) -> Vec2 {
  { x: self.x, y: self.y }
}

///| set sets the x and y components of this Vec2.
pub fn set(self : Vec2, x : Double, y : Double) -> Vec2 {
  self.x = x
  self.y = y
  self
}

///| copy copies `v` into this Vec2.
pub fn copy(self : Vec2, v : Vec2) -> Vec2 {
  self.x = v.x
  self.y = v.y
  self
}

///| is_valid returns whether or not this Vec2 is valid.
pub fn is_valid(self : Vec2) -> Bool {
  not(self.x.is_inf() || self.x.is_nan() || self.y.is_inf() || self.y.is_nan())
}

///| affine_transform transforms this Vec2 by the `affine_matrix`.
/// This is used when transforming a point or position.
pub fn affine_transform(self : Vec2, affine_matrix : AffineMatrix) -> Vec2 {
  let { x: x0, y: y0 } = self
  let { a, b, c, d, tx, ty } = affine_matrix
  self.x = a * x0 + c * y0 + tx
  self.y = b * x0 + d * y0 + ty
  self
}

///| affine_transform_without_translation transforms this Vec2 by the `affine_matrix`
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

///| transform transforms this Vec2.
///| transform provides a convenient API for a common task.
pub fn transform(
  self : Vec2,
  position~ : Vec2 = vec2(0, 0),
  rotation~ : Double = 0,
  scale~ : Vec2 = vec2(1, 1),
  skew~ : Double = 0,
  origin~ : Vec2 = vec2(0, 0)
) -> Vec2 {
  let affine_matrix = AffineMatrix::from_transform(
    Transform::new(position~, rotation~, scale~, skew~, origin~),
  )
  self.affine_transform(affine_matrix)
}

///| add adds the vector `v` to this vector.
pub fn add(self : Vec2, v : Vec2) -> Vec2 {
  self.x += v.x
  self.y += v.y
  self
}

///| op_add adds vector `other` to this vector without modifying either one
/// and returns the result.
pub fn op_add(self : Vec2, other : Vec2) -> Vec2 {
  self.clone().add(other)
}

///| add_scalar adds scalar `s` to this vector.
pub fn add_scalar(self : Vec2, s : Double) -> Vec2 {
  self.x += s
  self.y += s
  self
}

///| sub subtracts the vector `v` from this vector.
pub fn sub(self : Vec2, v : Vec2) -> Vec2 {
  self.x -= v.x
  self.y -= v.y
  self
}

///| op_sub subtracts vector `other` from this vector without modifying either one
/// and returns the result.
pub fn op_sub(self : Vec2, other : Vec2) -> Vec2 {
  self.clone().sub(other)
}

///| sub_scalar subtracts scalar `s` from this vector.
pub fn sub_scalar(self : Vec2, s : Double) -> Vec2 {
  self.x -= s
  self.y -= s
  self
}

///| mul multiplies the vector `v` to this vector.
pub fn mul(self : Vec2, v : Vec2) -> Vec2 {
  self.x *= v.x
  self.y *= v.y
  self
}

///| op_mul multiplies vector `other` to this vector without modifying either one
/// and returns the result.
pub fn op_mul(self : Vec2, other : Vec2) -> Vec2 {
  self.clone().mul(other)
}

///| mul_scalar multiplies scalar `s` to this vector.
pub fn mul_scalar(self : Vec2, s : Double) -> Vec2 {
  self.x *= s
  self.y *= s
  self
}

///| div divides this vector by vector `v`.
pub fn div(self : Vec2, v : Vec2) -> Vec2 {
  self.x /= v.x
  self.y /= v.y
  self
}

///| op_div divides this vector by vector `other` without modifying either one
/// and returns the result.
pub fn op_div(self : Vec2, other : Vec2) -> Vec2 {
  self.clone().div(other)
}

///| div_scalar divides this vector by scalar `s`.
pub fn div_scalar(self : Vec2, s : Double) -> Vec2 {
  self.x /= s
  self.y /= s
  self
}

///| negate multiplies both components (in-place) by -1.
pub fn negate(self : Vec2) -> Vec2 {
  self.x *= -1
  self.y *= -1
  self
}

///| op_neg returns a negated copy of Vec2.
pub fn op_neg(self : Vec2) -> Vec2 {
  { x: -self.x, y: -self.y }
}

///|
fn almost_equal(v1 : Double, v2 : Double, tolerance : Double) -> Bool {
  let delta = (v2 - v1).abs()
  if delta <= tolerance {
    return true
  }
  let v1 = v1.abs()
  let v2 = v2.abs()
  delta <= @math.maximum(v1, v2) * tolerance
}

///| almost_equals returns true if the vectors are equal within the provided tolerance.
pub fn almost_equals(
  self : Vec2,
  other : Vec2,
  tolerance~ : Double = DEFAULT_TOLERANCE
) -> Bool {
  almost_equal(self.x, other.x, tolerance) &&
  almost_equal(self.y, other.y, tolerance)
}

///| apply applies the provided `func` to both components of this vector.
pub fn apply(self : Vec2, func : (Double) -> Double) -> Vec2 {
  self.x = func(self.x)
  self.y = func(self.y)
  self
}

///| floor rounds the components of this vector to the next-lower integer.
pub fn floor(self : Vec2) -> Vec2 {
  self.apply(@math.floor)
}

///| ceil rounds the components of this vector to the next-higher integer.
pub fn ceil(self : Vec2) -> Vec2 {
  self.apply(@math.ceil)
}

///| round rounds the components of this vector to the next-higher integer.
pub fn round(self : Vec2) -> Vec2 {
  self.apply(@math.round)
}

///| round_to_fixed rounds the components of this vector to the provided
/// number of digits.
pub fn round_to_fixed(self : Vec2, digits : Int) -> Vec2 {
  let num = digits.to_double().abs()
  let exp = @math.round(@math.exp(num * @math.ln(10.0)))
  if digits < 0 {
    self.x = @math.round(self.x / exp) * exp
    self.y = @math.round(self.y / exp) * exp
    return self
  }
  self.x = @math.round(self.x * exp) / exp
  self.y = @math.round(self.y * exp) / exp
  self
}

///| round_to_multiple rounds the components of this vector to the closes
/// multiple of `v`.
pub fn round_to_multiple(self : Vec2, v : Double) -> Vec2 {
  if 0.0 == v {
    return self
  }
  let t = 1.0 / v
  self.x = @math.round(self.x * t) * v
  self.y = @math.round(self.y * t) * v
  self
}

///| min compares the components of this vector and `v` and sets this vector's
/// components to the minimum of the two.
pub fn min(self : Vec2, v : Vec2) -> Vec2 {
  self.x = @math.minimum(self.x, v.x)
  self.y = @math.minimum(self.y, v.y)
  self
}

///| max compares the components of this vector and `v` and sets this vector's
/// components to the maximum of the two.
pub fn max(self : Vec2, v : Vec2) -> Vec2 {
  self.x = @math.maximum(self.x, v.x)
  self.y = @math.maximum(self.y, v.y)
  self
}

///| mix linearly interpolates this vector to the vector `v` by the mixing
/// factor `t` (0..1).
pub fn mix(self : Vec2, v : Vec2, t : Double) -> Vec2 {
  self.x += (v.x - self.x) * t
  self.y += (v.y - self.y) * t
  self
}

///| dot returns the dot product between this vector and the vector `v`.
pub fn dot(self : Vec2, v : Vec2) -> Double {
  self.x * v.x + self.y * v.y
}

///| cross returns the cross product between this vector and the vector `v`.
pub fn cross(self : Vec2, v : Vec2) -> Double {
  self.x * v.y - self.y * v.x
}

///| normalize scales this vector so that its length is 1.
/// Note that this vector must already have a non-zero length.
pub fn normalize(self : Vec2) -> Vec2 {
  let v = self.length_squared()
  if v > 0 {
    return self.mul_scalar(1.0 / v.sqrt())
  }
  self
}

///| rotate rotates this vector clockwise by `angle` in degrees.
pub fn rotate(self : Vec2, angle : Double) -> Vec2 {
  let rad = angle * @math.PI / 180
  self.rotate_radians(rad)
}

///| rotate_radians rotates this vector clockwise by `rad` in radians.
pub fn rotate_radians(self : Vec2, rad : Double) -> Vec2 {
  let rx = @math.cos(rad)
  let ry = @math.sin(rad)
  let { x: x0, y: y0 } = self
  self.x = x0 * rx - y0 * ry
  self.y = x0 * ry + y0 * rx
  self
}

///| rotate90 rotates this vector clockwise by 90°.
pub fn rotate90(self : Vec2) -> Vec2 {
  let { x: x0, y: y0 } = self
  self.x = -y0
  self.y = x0
  self
}

///| rotate_neg90 rotates this vector counter-clockwise by 90°.
pub fn rotate_neg90(self : Vec2) -> Vec2 {
  let { x: x0, y: y0 } = self
  self.x = y0
  self.y = -x0
  self
}

///| project_onto projects this vector onto a non-zero vector `v`.
pub fn project_onto(self : Vec2, v : Vec2) -> Vec2 {
  let t = v.length_squared()
  if t > 0 {
    let n = self.dot(v) / t
    self.x = v.x * n
    self.y = v.y * n
  }
  self
}

///| angle returns the angle of this vector in degrees.
pub fn angle(self : Vec2) -> Double {
  self.angle_radians() * 180 / @math.PI
}

///| angle_radians returns the angle of this vector in radians.
pub fn angle_radians(self : Vec2) -> Double {
  @math.atan2(self.y, self.x)
}

///| is_clockwise_from returns true if this vector lies in the 180° region
/// clockwise from `v`.
pub fn is_clockwise_from(self : Vec2, v : Vec2) -> Bool {
  self.cross(v) > 0
}

///| length returns the length of this vector.
pub fn length(self : Vec2) -> Double {
  self.length_squared().sqrt()
}

///| length_squared returns the squared length of this vector.
pub fn length_squared(self : Vec2) -> Double {
  self.x * self.x + self.y * self.y
}

///| distance returns the distance from this vector to `v`.
pub fn distance(self : Vec2, v : Vec2) -> Double {
  self.distance_squared(v).sqrt()
}

///| distance_squared returns the squared distance from this vector to `v`.
pub fn distance_squared(self : Vec2, v : Vec2) -> Double {
  let x = self.x - v.x
  let y = self.y - v.y
  x * x + y * y
}

///| is_zero returns true if both components of this vector are 0.
pub fn is_zero(self : Vec2) -> Bool {
  self.x == 0 && self.y == 0
}

///| is_nan returns true if either component is NaN (not a number).
pub fn is_nan(self : Vec2) -> Bool {
  self.x.is_nan() || self.y.is_nan()
}

///| is_inf returns true if either component is infinite.
pub fn is_inf(self : Vec2) -> Bool {
  self.x.is_inf() || self.y.is_inf()
}
