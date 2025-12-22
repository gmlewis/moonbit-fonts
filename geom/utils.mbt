///|
/// `pt` is shorthand for `vec2(x, y)`.
pub fn pt(x : Double, y : Double) -> Vec2 {
  vec2(x, y)
}

///|
/// `rect` is shorthand for `@draw.bbox(x0, y0, x1, y1)`.
/// The returned bounding box has minimum and maximum coordinates swapped if necessary.
pub fn rect(x0 : Double, y0 : Double, x1 : Double, y1 : Double) -> BoundingBox {
  let (x0, x1) = if x0 > x1 { (x1, x0) } else { (x0, x1) }
  let (y0, y1) = if y0 > y1 { (y1, y0) } else { (y0, y1) }
  bbox(x0, y0, x1, y1)
}

///|
/// `round_to_fixed` rounds a `Double` to the provided number of digits.
pub fn round_to_fixed(val : Double, digits : Int) -> Double {
  let num = digits.to_double().abs()
  let exp = 10.0.pow(num)
  if digits < 0 {
    return (val / exp).round() * exp
  }
  (val * exp).round() / exp
}
