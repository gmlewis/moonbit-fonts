///|
/// Vec2 represents a 2D vector.
pub(all) struct Vec2 {
  mut x : Double
  mut y : Double
} derive(Show, Eq, FromJson, ToJson)

///|
/// `DEFAULT_TOLERANCE` is the default tolerance used for floating point comparisons.
pub const DEFAULT_TOLERANCE = 0.001

///|
/// Vec2::new returns a new Vec2.
pub fn Vec2::new(x? : Double = 0, y? : Double = 0) -> Vec2 {
  { x, y }
}

///|
/// Vec::infinity returns a new Vec2 with infinite x and y.
pub fn Vec2::infinity() -> Vec2 {
  { x: @double.infinity, y: @double.infinity }
}

///|
/// Vec::neg_infinity returns a new Vec2 with negative infinite x and y.
pub fn Vec2::neg_infinity() -> Vec2 {
  { x: @double.neg_infinity, y: @double.neg_infinity }
}

///|
/// vec2 returns a new Vec2.
pub fn vec2(x : Double, y : Double) -> Vec2 {
  { x, y }
}

///|
/// Vec2::from_angle returns a new unit vec2 from an angle in degrees.
pub fn Vec2::from_angle(angle : Double) -> Vec2 {
  let rad = angle * @math.PI / 180
  Vec2::from_angle_radians(rad)
}

///|
/// Vec2::from_angle_radians returns a new unit vec2 from an angle in radians.
pub fn Vec2::from_angle_radians(rad : Double) -> Vec2 {
  let x = @math.cos(rad)
  let y = @math.sin(rad)
  { x, y }
}

///|
/// clone returns a new copy of this Vec2.
pub fn Vec2::clone(self : Vec2) -> Vec2 {
  { x: self.x, y: self.y }
}

///|
/// set sets the x and y components of this Vec2.
pub fn Vec2::set(self : Vec2, x : Double, y : Double) -> Unit {
  self.x = x
  self.y = y
}

///|
/// copy copies `v` into this Vec2.
pub fn Vec2::copy(self : Vec2, v : Vec2) -> Unit {
  self.x = v.x
  self.y = v.y
}

///|
/// is_valid returns whether or not this Vec2 is valid.
pub fn Vec2::is_valid(self : Vec2) -> Bool {
  not(self.x.is_inf() || self.x.is_nan() || self.y.is_inf() || self.y.is_nan())
}

///|
/// affine_transform transforms this Vec2 by the `affine_matrix`.
/// This is used when transforming a point or position.
pub fn Vec2::affine_transform(
  self : Vec2,
  affine_matrix : AffineMatrix,
) -> Vec2 {
  let { x: x0, y: y0 } = self
  let { a, b, c, d, tx, ty } = affine_matrix
  let x = a * x0 + c * y0 + tx
  let y = b * x0 + d * y0 + ty
  { x, y }
}

///|
/// affine_transform_without_translation transforms this Vec2 by the `affine_matrix`
/// but without performing translation.
/// This is used when transforming a normal or tangent.
pub fn Vec2::affine_transform_without_translation(
  self : Vec2,
  affine_matrix : AffineMatrix,
) -> Vec2 {
  let { x: x0, y: y0 } = self
  let { a, b, c, d, .. } = affine_matrix
  let x = a * x0 + c * y0
  let y = b * x0 + d * y0
  { x, y }
}

///|
/// transform provides a convenient API for a common task.
pub fn Vec2::transform(
  self : Vec2,
  position? : Vec2 = vec2(0, 0),
  rotation? : Double = 0,
  scale? : Vec2 = vec2(1, 1),
  skew? : Double = 0,
  origin? : Vec2 = vec2(0, 0),
) -> Vec2 {
  let affine_matrix = AffineMatrix::from_transform(
    Transform::new(position~, rotation~, scale~, skew~, origin~),
  )
  self.affine_transform(affine_matrix)
}

///|
/// self_add adds the vector `v` to this vector.
pub fn Vec2::self_add(self : Vec2, v : Vec2) -> Unit {
  self.x += v.x
  self.y += v.y
}

///|
/// add adds vector `other` to this vector without modifying either one
/// and returns the result.
pub impl Add for Vec2 with add(self, other) {
  let result = self.clone()
  result.self_add(other)
  result
}

///|
/// add_scalar adds scalar `s` to self and returns a new vector.
pub fn Vec2::add_scalar(self : Vec2, s : Double) -> Vec2 {
  vec2(self.x + s, self.y + s)
}

///|
/// self_add_scalar adds scalar `s` to this vector.
pub fn Vec2::self_add_scalar(self : Vec2, s : Double) -> Unit {
  self.x += s
  self.y += s
}

///|
/// self_sub subtracts the vector `v` from this vector.
pub fn Vec2::self_sub(self : Vec2, v : Vec2) -> Unit {
  self.x -= v.x
  self.y -= v.y
}

///|
/// sub subtracts vector `other` from this vector without modifying either one
/// and returns the result.
pub impl Sub for Vec2 with sub(self, other) {
  let result = self.clone()
  result.self_sub(other)
  result
}

///|
/// self_sub_scalar subtracts scalar `s` from this vector.
pub fn Vec2::self_sub_scalar(self : Vec2, s : Double) -> Unit {
  self.x -= s
  self.y -= s
}

///|
/// self_mul multiplies the vector `v` to this vector.
pub fn Vec2::self_mul(self : Vec2, v : Vec2) -> Unit {
  self.x *= v.x
  self.y *= v.y
}

///|
/// mul multiplies vector `other` to this vector without modifying either one
/// and returns the result.
pub impl Mul for Vec2 with mul(self, other) {
  let result = self.clone()
  result.self_mul(other)
  result
}

///|
/// mul_scalar multiplies scalar `s` to self and returns a new vector.
pub fn Vec2::mul_scalar(self : Vec2, s : Double) -> Vec2 {
  vec2(self.x * s, self.y * s)
}

///|
/// self_mul_scalar multiplies scalar `s` to this vector.
pub fn Vec2::self_mul_scalar(self : Vec2, s : Double) -> Unit {
  self.x *= s
  self.y *= s
}

///|
/// self_div divides this vector by vector `v`.
pub fn Vec2::self_div(self : Vec2, v : Vec2) -> Unit {
  self.x /= v.x
  self.y /= v.y
}

///|
/// div divides this vector by vector `other` without modifying either one
/// and returns the result.
pub impl Div for Vec2 with div(self, other) {
  let result = self.clone()
  result.self_div(other)
  result
}

///|
/// self_div_scalar divides this vector by scalar `s`.
pub fn Vec2::self_div_scalar(self : Vec2, s : Double) -> Unit {
  self.x /= s
  self.y /= s
}

///|
/// negate multiplies both components (in-place) by -1.
pub fn Vec2::negate(self : Vec2) -> Unit {
  self.x *= -1
  self.y *= -1
}

///|
/// neg returns a negated copy of Vec2.
pub impl Neg for Vec2 with neg(self) {
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
  delta <= @cmp.maximum(v1, v2) * tolerance
}

///|
/// almost_equals returns true if the vectors are equal within the provided tolerance.
pub fn Vec2::almost_equals(
  self : Vec2,
  other : Vec2,
  tolerance? : Double = DEFAULT_TOLERANCE,
) -> Bool {
  almost_equal(self.x, other.x, tolerance) &&
  almost_equal(self.y, other.y, tolerance)
}

///|
/// apply applies the provided `func` to both components of this vector and returns a new one.
pub fn Vec2::apply(self : Vec2, func : (Double) -> Double) -> Vec2 {
  let x = func(self.x)
  let y = func(self.y)
  { x, y }
}

///|
/// floor rounds the components of this vector to the next-lower integer.
pub fn Vec2::floor(self : Vec2) -> Vec2 {
  self.apply(@math.floor)
}

///|
/// ceil rounds the components of this vector to the next-higher integer.
pub fn Vec2::ceil(self : Vec2) -> Vec2 {
  self.apply(@math.ceil)
}

///|
/// round rounds the components of this vector to the next-higher integer.
pub fn Vec2::round(self : Vec2) -> Vec2 {
  self.apply(@math.round)
}

///|
/// round_to_fixed rounds the components of this vector to the provided
/// number of digits and returns a new one.
pub fn Vec2::round_to_fixed(self : Vec2, digits : Int) -> Vec2 {
  let x = round_to_fixed(self.x, digits)
  let y = round_to_fixed(self.y, digits)
  { x, y }
}

///|
/// round_to_multiple rounds the components of this vector to the closest
/// multiple of `v` and returns a new one.
pub fn Vec2::round_to_multiple(self : Vec2, v : Double) -> Vec2 {
  if 0.0 == v {
    return self
  }
  let t = 1.0 / v
  let x = @math.round(self.x * t) * v
  let y = @math.round(self.y * t) * v
  { x, y }
}

///|
/// min compares the components of this vector and `v` and sets this vector's
/// components to the minimum of the two.
pub fn Vec2::min(self : Vec2, v : Vec2) -> Unit {
  self.x = @cmp.minimum(self.x, v.x)
  self.y = @cmp.minimum(self.y, v.y)
}

///|
/// max compares the components of this vector and `v` and sets this vector's
/// components to the maximum of the two.
pub fn Vec2::max(self : Vec2, v : Vec2) -> Unit {
  self.x = @cmp.maximum(self.x, v.x)
  self.y = @cmp.maximum(self.y, v.y)
}

///|
/// mix linearly interpolates this vector to the vector `v` by the mixing
/// factor `t` (0..1) and returns a new one.
pub fn Vec2::mix(self : Vec2, v : Vec2, t : Double) -> Vec2 {
  let x = self.x + (v.x - self.x) * t
  let y = self.y + (v.y - self.y) * t
  { x, y }
}

///|
/// dot returns the dot product between this vector and the vector `v`.
pub fn Vec2::dot(self : Vec2, v : Vec2) -> Double {
  self.x * v.x + self.y * v.y
}

///|
/// cross returns the cross product between this vector and the vector `v`.
pub fn Vec2::cross(self : Vec2, v : Vec2) -> Double {
  self.x * v.y - self.y * v.x
}

///|
/// normalize scales this vector so that its length is 1.
/// Note that this vector must already have a non-zero length.
pub fn Vec2::normalize(self : Vec2) -> Unit {
  let v = self.length_squared()
  if v > 0 {
    self.self_mul_scalar(1.0 / v.sqrt())
  }
}

///|
/// rotate rotates this vector clockwise by `angle` in degrees.
pub fn Vec2::rotate(self : Vec2, angle : Double) -> Vec2 {
  let rad = angle * @math.PI / 180
  self.rotate_radians(rad)
}

///|
/// rotate_radians rotates this vector clockwise by `rad` in radians and returns a new one.
pub fn Vec2::rotate_radians(self : Vec2, rad : Double) -> Vec2 {
  let rx = @math.cos(rad)
  let ry = @math.sin(rad)
  let { x: x0, y: y0 } = self
  let x = x0 * rx - y0 * ry
  let y = x0 * ry + y0 * rx
  { x, y }
}

///|
/// rotate90 rotates this vector clockwise by 90° and returns a new one.
pub fn Vec2::rotate90(self : Vec2) -> Vec2 {
  let { x: x0, y: y0 } = self
  let x = -y0
  let y = x0
  { x, y }
}

///|
/// rotate_neg90 rotates this vector counter-clockwise by 90° and returns a new one.
pub fn Vec2::rotate_neg90(self : Vec2) -> Vec2 {
  let { x: x0, y: y0 } = self
  let x = y0
  let y = -x0
  { x, y }
}

///|
/// project_onto projects this vector onto a non-zero vector `v` and returns a new one.
pub fn Vec2::project_onto(self : Vec2, v : Vec2) -> Vec2 {
  let t = v.length_squared()
  if t > 0 {
    let n = self.dot(v) / t
    let x = v.x * n
    let y = v.y * n
    { x, y }
  } else {
    self
  }
}

///|
/// angle returns the angle of this vector in degrees.
pub fn Vec2::angle(self : Vec2) -> Double {
  self.angle_radians() * 180 / @math.PI
}

///|
/// angle_radians returns the angle of this vector in radians.
pub fn Vec2::angle_radians(self : Vec2) -> Double {
  @math.atan2(self.y, self.x)
}

///|
/// is_clockwise_from returns true if this vector lies in the 180° region
/// clockwise from `v`.
pub fn Vec2::is_clockwise_from(self : Vec2, v : Vec2) -> Bool {
  self.cross(v) > 0
}

///|
/// length returns the length of this vector.
pub fn Vec2::length(self : Vec2) -> Double {
  self.length_squared().sqrt()
}

///|
/// length_squared returns the squared length of this vector.
pub fn Vec2::length_squared(self : Vec2) -> Double {
  self.x * self.x + self.y * self.y
}

///|
/// distance returns the distance from this vector to `v`.
pub fn Vec2::distance(self : Vec2, v : Vec2) -> Double {
  self.distance_squared(v).sqrt()
}

///|
/// distance_squared returns the squared distance from this vector to `v`.
pub fn Vec2::distance_squared(self : Vec2, v : Vec2) -> Double {
  let x = self.x - v.x
  let y = self.y - v.y
  x * x + y * y
}

///|
/// is_zero returns true if both components of this vector are 0.
pub fn Vec2::is_zero(self : Vec2) -> Bool {
  self.x == 0 && self.y == 0
}

///|
/// is_nan returns true if either component is NaN (not a number).
pub fn Vec2::is_nan(self : Vec2) -> Bool {
  self.x.is_nan() || self.y.is_nan()
}

///|
/// is_inf returns true if either component is infinite.
pub fn Vec2::is_inf(self : Vec2) -> Bool {
  self.x.is_inf() || self.y.is_inf()
}

///|
/// to_tuple returns this Vec2 as a (Double, Double) tuple.
pub fn Vec2::to_tuple(self : Vec2) -> (Double, Double) {
  (self.x, self.y)
}

///|
/// from_tuple creates a Vec2 from a tuple.
pub fn Vec2::from_tuple(t : (Double, Double)) -> Vec2 {
  Vec2::new(x=t.0, y=t.1)
}

///|
/// distance_squared_tuple returns the squared distance between two tuples.
pub fn Vec2::distance_squared_tuple(
  a : (Double, Double),
  b : (Double, Double),
) -> Double {
  Vec2::distance_squared(Vec2::from_tuple(a), Vec2::from_tuple(b))
}

///|
pub fn Vec2::is_in(self : Vec2, box : BoundingBox) -> Bool {
  box.contains_point(self)
}
