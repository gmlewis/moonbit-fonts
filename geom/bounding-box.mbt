///|
/// `BoundingBox` represents a minimum bounding box as an axis-aligned rectangle.
pub(all) struct BoundingBox {
  mut min : Vec2
  mut max : Vec2
} derive(Show, Eq)

///|
/// BoundingBox::new returns a new empty BoundingBox.
pub fn BoundingBox::new(
  min? : Vec2 = vec2(0, 0),
  max? : Vec2 = vec2(0, 0),
) -> BoundingBox {
  { min, max }
}

///|
/// `is_empty` returns true if the bounding box has no area.
pub fn BoundingBox::is_empty(self : BoundingBox) -> Bool {
  self.min.x >= self.max.x || self.min.y >= self.max.y
}

///|
/// bbox is a convenience function.
pub fn bbox(
  minx : Double,
  miny : Double,
  maxx : Double,
  maxy : Double,
) -> BoundingBox {
  let min = vec2(minx, miny)
  let max = vec2(maxx, maxy)
  { min, max }
}

///|
/// BoundingBox::max_reversed returns a new BoundingBox with min=+infinity
/// and max=-infinity.
pub fn BoundingBox::max_reversed() -> BoundingBox {
  let min = Vec2::infinity()
  let max = Vec2::neg_infinity()
  { min, max }
}

///|
/// BoundingBox::from_points constructs the minimum bounding box containing `points`.
pub fn BoundingBox::from_points(points : Array[Vec2]) -> BoundingBox {
  guard points.length() > 0
  let bbox = BoundingBox::new(min=points[0].clone(), max=points[0].clone())
  for i in 1..<points.length() {
    bbox.expand_to_include_point(points[i])
  }
  bbox
}

///|
/// clone makes a new copy of the bounding box.
pub fn BoundingBox::clone(self : BoundingBox) -> BoundingBox {
  BoundingBox::new(min=self.min.clone(), max=self.max.clone())
}

///|
// copy copies the values from other into self.
pub fn BoundingBox::copy(self : BoundingBox, other : BoundingBox) -> Unit {
  self.min = other.min.clone()
  self.max = other.max.clone()
}

///|
/// center returns the center point of the bounding box (the average of min and max).
pub fn BoundingBox::center(self : BoundingBox) -> Vec2 {
  self.min.add(self.max).mul_scalar(0.5)
}

///|
/// size returns a vector representing the (width,height) of the bounding box.
pub fn BoundingBox::size(self : BoundingBox) -> Vec2 {
  self.max.sub(self.min)
}

///|
/// width returns the width of the bounding box.
pub fn BoundingBox::width(self : BoundingBox) -> Double {
  self.max.x - self.min.x
}

///|
/// height returns the height of the bounding box.
pub fn BoundingBox::height(self : BoundingBox) -> Double {
  self.max.y - self.min.y
}

///|
/// area represents the signed area of the bounding box (width*height).
/// If min > max, the area will be negative.
pub fn BoundingBox::area(self : BoundingBox) -> Double {
  self.width() * self.height()
}

///|
/// is_inf returns true if either min or max is_inf.
pub fn BoundingBox::is_inf(self : BoundingBox) -> Bool {
  self.min.is_inf() || self.max.is_inf()
}

///|
/// is_nan returns true if either min or max is_nan.
pub fn BoundingBox::is_nan(self : BoundingBox) -> Bool {
  self.min.is_nan() || self.max.is_nan()
}

///|
/// canonicalize ensures that min < max.
pub fn BoundingBox::canonicalize(self : BoundingBox) -> Unit {
  let { x: xmin, y: ymin } = self.min
  let { x: xmax, y: ymax } = self.max
  self.min.set(@cmp.minimum(xmin, xmax), @cmp.minimum(ymin, ymax))
  self.max.set(@cmp.maximum(xmin, xmax), @cmp.maximum(ymin, ymax))
}

///|
/// expand_to_include_point expands this bounding box to include `point`.
pub fn BoundingBox::expand_to_include_point(
  self : BoundingBox,
  point : Vec2,
) -> Unit {
  self.min.min(point)
  self.max.max(point)
}

///|
/// expand_to_include_bounding_box expands this bounding box to also cover `box`.
pub fn BoundingBox::expand_to_include_bounding_box(
  self : BoundingBox,
  box : BoundingBox,
) -> Unit {
  self.expand_to_include_point(box.min)
  self.expand_to_include_point(box.max)
}

///|
/// expand_scalar expands this bounding box by a scalar distance on all sides.
pub fn BoundingBox::expand_scalar(
  self : BoundingBox,
  distance : Double,
) -> Unit {
  self.min.self_sub_scalar(distance)
  self.max.self_add_scalar(distance)
}

///|
/// contains_point returns true if `point` is contained within this bounding box.
pub fn BoundingBox::contains_point(self : BoundingBox, point : Vec2) -> Bool {
  let { x, y } = point
  x >= self.min.x && x <= self.max.x && y >= self.min.y && y <= self.max.y
}

///|
/// contains_bounding_box returns true if `box` is contained within this bounding box.
pub fn BoundingBox::contains_bounding_box(
  self : BoundingBox,
  box : BoundingBox,
) -> Bool {
  let { min, max } = box
  min.x >= self.min.x &&
  max.x <= self.max.x &&
  min.y >= self.min.y &&
  max.y <= self.max.y
}

///|
/// is_in reports whether every point in self is in s.
pub fn BoundingBox::is_in(self : BoundingBox, s : BoundingBox) -> Bool {
  if self.is_empty() {
    return true
  }
  // note that self.max is an exclusive bound for r, so that self.in(s)
  // does not require that self.max.in(s).
  s.min.x <= self.min.x &&
  self.max.x <= s.max.x &&
  s.min.y <= self.min.y &&
  self.max.y <= s.max.y
}

///|
/// overlaps_bounding_box returns true if any part of `box` overlaps this bounding box.
pub fn BoundingBox::overlaps_bounding_box(
  self : BoundingBox,
  box : BoundingBox,
) -> Bool {
  let r = self
  r.min.x < box.max.x &&
  box.min.x < r.max.x &&
  r.min.y < box.max.y &&
  box.min.y < r.max.y
}

///|
/// boolean_intersect returns a new BoundingBox representing the intersection
/// of this bounding box with one or more boxes if one exists.
pub fn BoundingBox::boolean_intersect(
  self : BoundingBox,
  boxes : Array[BoundingBox],
) -> BoundingBox? {
  guard boxes.length() > 0
  let mut xmin = self.min.x
  let mut ymin = self.min.y
  let mut xmax = self.max.x
  let mut ymax = self.max.y
  for box in boxes {
    xmin = @cmp.maximum(xmin, box.min.x)
    xmax = @cmp.minimum(xmax, box.max.x)
    if xmin > xmax {
      return None
    }
    ymin = @cmp.maximum(ymin, box.min.y)
    ymax = @cmp.minimum(ymax, box.max.y)
    if ymin > ymax {
      return None
    }
  }
  Some(BoundingBox::new(min=vec2(xmin, ymin), max=vec2(xmax, ymax)))
}

///|
/// `bounds` returns the tuple `(xmin, ymin, xmax, ymax)`.
pub fn BoundingBox::bounds(
  self : BoundingBox,
) -> (Double, Double, Double, Double) {
  (self.min.x, self.min.y, self.max.x, self.max.y)
}

///|
/// dx returns the width of the bounding box.
pub fn BoundingBox::dx(self : BoundingBox) -> Double {
  self.max.x - self.min.x
}

///|
/// dy returns the height of the bounding box.
pub fn BoundingBox::dy(self : BoundingBox) -> Double {
  self.max.y - self.min.y
}

///|
/// inset returns the bounding box inset by n, which may be negative. If either
/// of the dimensions is less than 2*n then an empty bounding box near the center
/// will be returned.
pub fn BoundingBox::inset(self : BoundingBox, n : Double) -> BoundingBox {
  let r = self.clone()
  if r.width() < 2.0 * n {
    r.min.x = (r.min.x + r.max.x) / 2
    r.max.x = r.min.x
  } else {
    r.min.x += n
    r.max.x -= n
  }
  if r.height() < 2.0 * n {
    r.min.y = (r.min.y + r.max.y) / 2
    r.max.y = r.min.y
  } else {
    r.min.y += n
    r.max.y -= n
  }
  r
}

///|
/// union returns the smallest bounding box that contains both self and s.
pub fn BoundingBox::union(self : BoundingBox, s : BoundingBox) -> BoundingBox {
  let r = self.clone()
  if r.is_empty() {
    return s
  }
  if s.is_empty() {
    return r
  }
  if r.min.x > s.min.x {
    r.min.x = s.min.x
  }
  if r.min.y > s.min.y {
    r.min.y = s.min.y
  }
  if r.max.x < s.max.x {
    r.max.x = s.max.x
  }
  if r.max.y < s.max.y {
    r.max.y = s.max.y
  }
  r
}

///|
/// overlaps reports whether self and s have a non-empty intersection.
pub fn BoundingBox::overlaps(self : BoundingBox, s : BoundingBox) -> Bool {
  not(self.is_empty()) &&
  not(s.is_empty()) &&
  self.min.x < s.max.x &&
  s.min.x < self.max.x &&
  self.min.y < s.max.y &&
  s.min.y < self.max.y
}

///|
/// intersect returns the largest rectangle contained by both self and s. If the
/// two rectangles do not overlap then an empty rectangle will be returned.
pub fn BoundingBox::intersect(
  self : BoundingBox,
  s : BoundingBox,
) -> BoundingBox {
  let r = self.clone()
  if r.min.x < s.min.x {
    r.min.x = s.min.x
  }
  if r.min.y < s.min.y {
    r.min.y = s.min.y
  }
  if r.max.x > s.max.x {
    r.max.x = s.max.x
  }
  if r.max.y > s.max.y {
    r.max.y = s.max.y
  }
  // Letting r0 and s0 be the values of r and s at the time that the method
  // is called, this next line is equivalent to:
  //
  // if max(r0.Min.X, s0.Min.X) >= min(r0.Max.X, s0.Max.X) || likewiseForY { etc }
  if r.is_empty() {
    return BoundingBox::new()
  }
  r
}
