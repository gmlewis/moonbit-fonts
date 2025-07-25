///|
const DEFAULT_TOLERANCE = 0.001

///|
/// AffineMatrix represents a 2D affine transform that preserves parallel lines.
/// See: https://en.wikipedia.org/wiki/Affine_transformation
pub(all) struct AffineMatrix {
  mut a : Double
  mut b : Double
  mut c : Double
  mut d : Double
  mut tx : Double
  mut ty : Double
} derive(Show, Eq)

///|
/// AffineMatrix::new returns a new 2D affine matrix.
pub fn AffineMatrix::new(
  a~ : Double = 1,
  b~ : Double = 0,
  c~ : Double = 0,
  d~ : Double = 1,
  tx~ : Double = 0,
  ty~ : Double = 0,
) -> AffineMatrix {
  { a, b, c, d, tx, ty }
}

///|
/// AffineMatrix::from_transform returns a new 2D affine matrix from a Transform.
pub fn AffineMatrix::from_transform(transform : Transform) -> AffineMatrix {
  let { position, rotation, scale, skew, origin } = transform
  AffineMatrix::new()
  .translate(position)
  .rotate(rotation)
  .skew(skew)
  .scale(scale)
  .origin(origin)
}

///|
/// AffineMatrix::from_translation returns a new 2D affine matrix from translation `v`.
pub fn AffineMatrix::from_translation(v : Vec2) -> AffineMatrix {
  AffineMatrix::new(tx=v.x, ty=v.y)
}

///|
/// AffineMatrix::from_translation_points returns a new 2D affine matrix that
/// translates from p1 to p2.
pub fn AffineMatrix::from_translation_points(
  p1 : Vec2,
  p2 : Vec2,
) -> AffineMatrix {
  AffineMatrix::new(tx=p2.x - p1.x, ty=p2.y - p1.y)
}

///|
/// AffineMatrix::from_rotation returns a new 2D affine matrix from a rotation `angle`
/// in degrees.
pub fn AffineMatrix::from_rotation(angle : Double) -> AffineMatrix {
  let rad = angle * @math.PI / 180
  let x = @math.cos(rad)
  let y = @math.sin(rad)
  AffineMatrix::new(a=x, b=y, c=-y, d=x)
}

///|
/// AffineMatrix::from_scale returns a new 2D affine matrix from scale `v`.
pub fn AffineMatrix::from_scale(v : Vec2) -> AffineMatrix {
  AffineMatrix::new(a=v.x, d=v.y)
}

///|
/// AffineMatrix::from_scale_scalar returns a new 2D affine matrix from uniform scale `s`.
pub fn AffineMatrix::from_scale_scalar(s : Double) -> AffineMatrix {
  AffineMatrix::new(a=s, d=s)
}

///|
/// AffineMatrix::from_center_scale returns a new 2D affine matrix that scales
/// from the provided center point.
pub fn AffineMatrix::from_center_scale(
  center : Vec2,
  scale : Vec2,
) -> AffineMatrix {
  let { x, y } = center
  AffineMatrix::new(
    a=scale.x,
    d=scale.y,
    tx=x - x * scale.x,
    ty=y - y * scale.y,
  )
}

///|
/// clone returns a copy of this 2D affine matrix.
pub fn clone(self : AffineMatrix) -> AffineMatrix {
  let { a, b, c, d, tx, ty } = self
  { a, b, c, d, tx, ty }
}

///|
/// copy copies another 2D affine matrix into itself and returns itself.
pub fn copy(self : AffineMatrix, other : AffineMatrix) -> AffineMatrix {
  self.a = other.a
  self.b = other.b
  self.c = other.c
  self.d = other.d
  self.tx = other.tx
  self.ty = other.ty
  self
}

///|
/// invert inverts this 2D affine matrix.
pub fn invert(self : AffineMatrix) -> AffineMatrix {
  let { a: a0, b: b0, c: c0, d: d0, tx: tx0, ty: ty0 } = self
  let cross = a0 * d0 - b0 * c0
  let dot = b0 * c0 - a0 * d0
  self.a = d0 / cross
  self.b = b0 / dot
  self.c = c0 / dot
  self.d = a0 / cross
  self.tx = (d0 * tx0 - c0 * ty0) / dot
  self.ty = (b0 * tx0 - a0 * ty0) / cross
  self
}

///|
/// mul multiplies this 2D affine matrix with another.
pub fn mul(self : AffineMatrix, m : AffineMatrix) -> AffineMatrix {
  let { a: m0a, b: m0b, c: m0c, d: m0d, tx: m0tx, ty: m0ty } = self
  let { a: m1a, b: m1b, c: m1c, d: m1d, tx: m1tx, ty: m1ty } = m
  self.a = m0a * m1a + m0c * m1b
  self.b = m0b * m1a + m0d * m1b
  self.c = m0a * m1c + m0c * m1d
  self.d = m0b * m1c + m0d * m1d
  self.tx = m0a * m1tx + m0c * m1ty + m0tx
  self.ty = m0b * m1tx + m0d * m1ty + m0ty
  self
}

///|
/// op_mul multiplies two 2D affine matrices together, returning a new one.
pub fn op_mul(self : AffineMatrix, b : AffineMatrix) -> AffineMatrix {
  let am = self.clone()
  am.mul(b)
}

///|
/// mul_without_translation multiplies this 2D affine matrix with another,
/// discarding the transation.
pub fn mul_without_translation(
  self : AffineMatrix,
  m : AffineMatrix,
) -> AffineMatrix {
  let { a: m0a, b: m0b, c: m0c, d: m0d, .. } = self
  let { a: m1a, b: m1b, c: m1c, d: m1d, .. } = m
  self.a = m0a * m1a + m0c * m1b
  self.b = m0b * m1a + m0d * m1b
  self.c = m0a * m1c + m0c * m1d
  self.d = m0b * m1c + m0d * m1d
  self
}

///|
/// pre_mul multiplies another matrix `m` by this 2D affine matrix, then
/// stores and returns the result.
pub fn pre_mul(self : AffineMatrix, m : AffineMatrix) -> AffineMatrix {
  let { a: m0a, b: m0b, c: m0c, d: m0d, tx: m0tx, ty: m0ty } = m
  let { a: m1a, b: m1b, c: m1c, d: m1d, tx: m1tx, ty: m1ty } = self
  self.a = m0a * m1a + m0c * m1b
  self.b = m0b * m1a + m0d * m1b
  self.c = m0a * m1c + m0c * m1d
  self.d = m0b * m1c + m0d * m1d
  self.tx = m0a * m1tx + m0c * m1ty + m0tx
  self.ty = m0b * m1tx + m0d * m1ty + m0ty
  self
}

///|
/// pre_mul_without_translation multiplies another matrix `m` by this 2D affine matrix,
/// discarding the translate, then stores and returns the result.
pub fn pre_mul_without_translation(
  self : AffineMatrix,
  m : AffineMatrix,
) -> AffineMatrix {
  let { a: m0a, b: m0b, c: m0c, d: m0d, .. } = m
  let { a: m1a, b: m1b, c: m1c, d: m1d, .. } = self
  self.a = m0a * m1a + m0c * m1b
  self.b = m0b * m1a + m0d * m1b
  self.c = m0a * m1c + m0c * m1d
  self.d = m0b * m1c + m0d * m1d
  self
}

///|
/// translate translates this 2D affine matrix by position `v`.
pub fn translate(self : AffineMatrix, v : Vec2) -> AffineMatrix {
  let { a, b, c, d, .. } = self
  self.tx += a * v.x + c * v.y
  self.ty += b * v.x + d * v.y
  self
}

///|
/// rotate rotates this 2D affine matrix by `angle` degrees.
pub fn rotate(self : AffineMatrix, angle : Double) -> AffineMatrix {
  self.mul(AffineMatrix::from_rotation(angle))
}

///|
/// skew skews the Y basis vector of this 2D affine matrix by `angle` degrees.
pub fn skew(self : AffineMatrix, angle : Double) -> AffineMatrix {
  let rad = angle * @math.PI / 180
  let t = @math.tan(rad)
  self.c += t * self.a
  self.d += t * self.b
  self
}

///|
/// scale scales this 2D affine matrix by `v`.
pub fn scale(self : AffineMatrix, v : Vec2) -> AffineMatrix {
  self.a *= v.x
  self.b *= v.x
  self.c *= v.y
  self.d *= v.y
  self
}

///|
/// scale_scalar scales this 2D affine matrix uniformly by `s`.
pub fn scale_scalar(self : AffineMatrix, s : Double) -> AffineMatrix {
  self.a *= s
  self.b *= s
  self.c *= s
  self.d *= s
  self
}

///|
/// origin translates the matrix such that the center of future
/// scale, rotate, and skew transformations will be `v`.
pub fn origin(self : AffineMatrix, v : Vec2) -> AffineMatrix {
  let { x, y } = v
  self.tx += self.a * x + self.c * y
  self.ty += self.b * x + self.d * y
  self
}

///|
/// normalize scales the basis vectors of this 2D affine matrix
/// so that they have unit length.
pub fn normalize(self : AffineMatrix) -> AffineMatrix {
  let { a, b, c, d, .. } = self
  let x = a * a + b * b
  if x > 0 {
    let f = 1.0 / x.sqrt()
    self.a *= f
    self.b *= f
  }
  let y = c * c + d * d
  if y > 0 {
    let f = 1.0 / y.sqrt()
    self.c *= f
    self.d *= f
  }
  self
}

///|
/// determinant returns the determinant of the 2D affine matrix.
pub fn determinant(self : AffineMatrix) -> Double {
  let { a, b, c, d, .. } = self
  a * d - b * c
}

///|
/// is_orthogonal returns true if the two basis vectors of the 2D affine matrix
/// are orthogonal within the provided tolerance.
pub fn is_orthogonal(
  self : AffineMatrix,
  tolerance~ : Double = DEFAULT_TOLERANCE,
) -> Bool {
  let { a, b, c, d, .. } = self
  return (a * c + b * d).abs() <= tolerance
}

///|
/// is_invertible returns true if this 2D affine matrix is invertible.
pub fn is_invertible(self : AffineMatrix) -> Bool {
  self.determinant() != 0
}

///|
/// is_uniform_scale returns true if both basis vectors of this 2D affine matrix
/// are of the same length.
pub fn is_uniform_scale(
  self : AffineMatrix,
  tolerance~ : Double = DEFAULT_TOLERANCE,
) -> Bool {
  let { a, b, c, d, .. } = self
  (a * a + b * b - (c * c + d * d)).abs() <= tolerance
}

///|
/// is_mirror returns true if this 2D affine matrix mirrors either axis.
pub fn is_mirror(self : AffineMatrix) -> Bool {
  self.determinant() < 0
}

///|
/// is_identity returns true if this 2D affine matrix is the identity matrix.
pub fn is_identity(self : AffineMatrix) -> Bool {
  self.a == 1 &&
  self.b == 0 &&
  self.c == 0 &&
  self.d == 1 &&
  self.tx == 0 &&
  self.ty == 0
}

///|
/// is_nan returns true if any elements of this 2D affine matrix are NaN (not a number).
pub fn is_nan(self : AffineMatrix) -> Bool {
  self.a.is_nan() ||
  self.b.is_nan() ||
  self.c.is_nan() ||
  self.d.is_nan() ||
  self.tx.is_nan() ||
  self.ty.is_nan()
}

///|
/// is_inf returns true if any elements of this 2D affine matrix are infinite.
pub fn is_inf(self : AffineMatrix) -> Bool {
  self.a.is_inf() ||
  self.b.is_inf() ||
  self.c.is_inf() ||
  self.d.is_inf() ||
  self.tx.is_inf() ||
  self.ty.is_inf()
}

///|
fn mod(a : Double, b : Double) -> Double {
  // let mut n = a % b
  let tmp = @math.floor(a / b)
  let mut n = a - tmp * b
  if n < 0.0 {
    n += b
  }
  if n == b {
    return 0
  }
  n
}

///|
/// to_transform converts this 2D affine matrix to a Transform.
pub fn to_transform(
  self : AffineMatrix,
  origin~ : Vec2 = vec2(0, 0),
) -> Transform {
  let { a, b, c, d, tx, ty } = self
  let xnz = a * a + b * b > 0.00000001
  let ynz = c * c + d * d > 0.00000001
  let mut rad = 0.0
  let mut skew = 0.0
  if xnz {
    rad = @math.atan2(b, a)
    if ynz {
      skew = (rad - @math.atan2(-c, d)) * 180 / @math.PI
      skew = mod(skew, 180)
      if skew > 90 {
        skew -= 180
      }
    }
  } else if ynz {
    rad = @math.atan2(-c, d)
  }
  let position = vec2(tx, ty)
  let rotation = mod(a * 180 / @math.PI, 360)
  let x = @math.cos(-rad)
  let y = @math.sin(-rad)
  let scale = vec2(a * x - b * y, c * y + d * x)
  { position, rotation, scale, skew, origin }
}
