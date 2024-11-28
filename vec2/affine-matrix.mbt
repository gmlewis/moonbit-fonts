/// AffineMatrix represents a 2D affine transform that preserves parallel lines.
/// See: https://en.wikipedia.org/wiki/Affine_transformation
pub(all) struct AffineMatrix {
  mut a : Double
  mut b : Double
  mut c : Double
  mut d : Double
  mut tx : Double
  mut ty : Double
}

/// AffineMatrix::new returns a new 2D affine matrix.
pub fn AffineMatrix::new(
  a~ : Double = 1,
  b~ : Double = 0,
  c~ : Double = 0,
  d~ : Double = 1,
  tx~ : Double = 0,
  ty~ : Double = 0
) -> AffineMatrix {
  { a, b, c, d, tx, ty }
}

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

/// AffineMatrix::from_translation returns a new 2D affine matrix from translation `v`.
pub fn AffineMatrix::from_translation(v : Vec2) -> AffineMatrix {
  AffineMatrix::new(tx=v.x, ty=v.y)
}

/// AffineMatrix::from_translation_points returns a new 2D affine matrix that
/// translates from p1 to p2.
pub fn AffineMatrix::from_translation_points(
  p1 : Vec2,
  p2 : Vec2
) -> AffineMatrix {
  AffineMatrix::new(tx=p2.x - p1.x, ty=p2.y - p1.y)
}

/// AffineMatrix::from_rotation returns a new 2D affine matrix from a rotation `angle`
/// in degrees.
pub fn AffineMatrix::from_rotation(angle : Double) -> AffineMatrix {
  let rad = angle * @math.PI / 180
  let x = @math.cos(rad)
  let y = @math.sin(rad)
  AffineMatrix::new(a=x, b=y, c=-y, d=x)
}

/// AffineMatrix::from_scale returns a new 2D affine matrix from scale `v`.
pub fn AffineMatrix::from_scale(v : Vec2) -> AffineMatrix {
  AffineMatrix::new(a=v.x, d=v.y)
}

/// AffineMatrix::from_scale_scalar returns a new 2D affine matrix from uniform scale `s`.
pub fn AffineMatrix::from_scale_scalar(s : Double) -> AffineMatrix {
  AffineMatrix::new(a=s, d=s)
}

/// AffineMatrix::from_center_scale returns a new 2D affine matrix that scales
/// from the provided center point.
pub fn AffineMatrix::from_center_scale(
  center : Vec2,
  scale : Vec2
) -> AffineMatrix {
  let { x, y } = center
  AffineMatrix::new(
    a=scale.x,
    d=scale.y,
    tx=x - x * scale.x,
    ty=y - y * scale.y,
  )
}

/// clone returns a copy of this 2D affine matrix.
pub fn clone(self : AffineMatrix) -> AffineMatrix {
  let { a, b, c, d, tx, ty } = self
  { a, b, c, d, tx, ty }
}

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

/// mul_without_translation multiplies this 2D affine matrix with another,
/// discarding the transation.
pub fn mul_without_translation(
  self : AffineMatrix,
  m : AffineMatrix
) -> AffineMatrix {
  let { a: m0a, b: m0b, c: m0c, d: m0d, .. } = self
  let { a: m1a, b: m1b, c: m1c, d: m1d, .. } = m
  self.a = m0a * m1a + m0c * m1b
  self.b = m0b * m1a + m0d * m1b
  self.c = m0a * m1c + m0c * m1d
  self.d = m0b * m1c + m0d * m1d
  self
}

/// translate translates this 2D affine matrix by position `v`.
pub fn translate(self : AffineMatrix, v : Vec2) -> AffineMatrix {
  let { a, b, c, d, .. } = self
  self.tx += a * v.x + c * v.y
  self.ty += b * v.x + d * v.y
  self
}

/// rotate rotates this 2D affine matrix by `angle` degrees.
pub fn rotate(self : AffineMatrix, angle : Double) -> AffineMatrix {
  self.mul(AffineMatrix::from_rotation(angle))
}

/// skew skews the Y basis vector of this 2D affine matrix by `angle` degrees.
pub fn skew(self : AffineMatrix, angle : Double) -> AffineMatrix {
  let rad = angle * @math.PI / 180
  let t = @math.tan(rad)
  self.c += t * self.a
  self.d += t * self.b
  self
}

/// scale scales this 2D affine matrix by `v`.
pub fn scale(self : AffineMatrix, v : Vec2) -> AffineMatrix {
  self.a *= v.x
  self.b *= v.x
  self.c *= v.y
  self.d *= v.y
  self
}

/// scale_scalar scales this 2D affine matrix uniformly by `s`.
pub fn scale_scalar(self : AffineMatrix, s : Double) -> AffineMatrix {
  self.a *= s
  self.b *= s
  self.c *= s
  self.d *= s
  self
}

/// origin translates the matrix such that the center of future
/// scale, rotate, and skew transformations will be `v`.
pub fn origin(self : AffineMatrix, v : Vec2) -> AffineMatrix {
  let { x, y } = v
  self.tx += self.a * x + self.c * y
  self.ty += self.b * x + self.d * y
  self
}
