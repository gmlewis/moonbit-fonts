/// BoundingBox represents a minimum bounding box as an axis-aligned rectangle.
pub(all) struct BoundingBox {
  mut min : Vec2
  mut max : Vec2
} derive(Show, Eq)

/// BoundingBox::new returns a new empty BoundingBox.
pub fn BoundingBox::new(
  min~ : Vec2 = vec2(0, 0),
  max~ : Vec2 = vec2(0, 0)
) -> BoundingBox {
  { min, max }
}

/// BoundingBox::max_reversed returns a new BoundingBox with min=+infinity
/// and max=-infinity.
pub fn BoundingBox::max_reversed() -> BoundingBox {
  let min = Vec2::infinity()
  let max = Vec2::neg_infinity()
  { min, max }
}

/// BoundingBox::from_points constructs the minimum bounding box containing `points`.
pub fn BoundingBox::from_points(points : Array[Vec2]) -> BoundingBox {
  guard points.length() > 0
  let bbox = BoundingBox::new(min=points[0].clone(), max=points[0].clone())
  for i in 1..<points.length() {
    let _ = bbox.expand_to_include_point(points[i])

  }
  bbox
}

/// clone makes a copy of the bounding box.
pub fn clone(self : BoundingBox) -> BoundingBox {
  BoundingBox::new(min=self.min.clone(), max=self.max.clone())
}

/// center returns the center point of the bounding box (the average of min and max).
pub fn center(self : BoundingBox) -> Vec2 {
  self.min.clone().add(self.max).mul_scalar(0.5)
}

/// size returns a vector representing the (width,height) of the bounding box.
pub fn size(self : BoundingBox) -> Vec2 {
  self.max.clone().sub(self.min)
}

/// width returns the width of the bounding box.
pub fn width(self : BoundingBox) -> Double {
  self.max.x - self.min.x
}

/// height returns the height of the bounding box.
pub fn height(self : BoundingBox) -> Double {
  self.max.y - self.min.y
}

/// area represents the signed area of the bounding box (width*height).
/// If min > max, the area will be negative.
pub fn area(self : BoundingBox) -> Double {
  self.width() * self.height()
}

/// is_inf returns true if either min or max is_inf.
pub fn is_inf(self : BoundingBox) -> Bool {
  self.min.is_inf() || self.max.is_inf()
}

/// is_nan returns true if either min or max is_nan.
pub fn is_nan(self : BoundingBox) -> Bool {
  self.min.is_nan() || self.max.is_nan()
}

/// canonicalize ensures that min < max.
pub fn canonicalize(self : BoundingBox) -> BoundingBox {
  let { x: xmin, y: ymin } = self.min
  let { x: xmax, y: ymax } = self.max
  let _ = self.min.set(@math.minimum(xmin, xmax), @math.minimum(ymin, ymax))
  let _ = self.max.set(@math.maximum(xmin, xmax), @math.maximum(ymin, ymax))
  self
}

/// expand_to_include_point expands this bounding box to include `point`.
pub fn expand_to_include_point(self : BoundingBox, point : Vec2) -> BoundingBox {
  let _ = self.min.min(point)
  let _ = self.max.max(point)
  self
}

/// expand_to_include_bounding_box expands this bounding box to also cover `box`.
pub fn expand_to_include_bounding_box(
  self : BoundingBox,
  box : BoundingBox
) -> BoundingBox {
  self.expand_to_include_point(box.min).expand_to_include_point(box.max)
}

/// expand_scalar expands this bounding box by a scalar distance on all sides.
pub fn expand_scalar(self : BoundingBox, distance : Double) -> BoundingBox {
  let _ = self.min.sub_scalar(distance)
  let _ = self.max.add_scalar(distance)
  self
}

/// contains_point returns true if `point` is contained within this bounding box.
pub fn contains_point(self : BoundingBox, point : Vec2) -> Bool {
  let { x, y } = point
  x >= self.min.x && x <= self.max.x && y >= self.min.y && y <= self.max.y
}

/// contains_bounding_box returns true if `box` is contained within this bounding box.
pub fn contains_bounding_box(self : BoundingBox, box : BoundingBox) -> Bool {
  let { min, max } = box
  min.x >= self.min.x &&
  max.x <= self.max.x &&
  min.y >= self.min.y &&
  max.y <= self.max.y
}

/// overlaps_bounding_box returns true if any part of `box` overlaps this bounding box.
pub fn overlaps_bounding_box(self : BoundingBox, box : BoundingBox) -> Bool {
  // TODO: is this correct?
  let { min, max } = box
  min.x >= self.min.x &&
  max.x <= self.max.x &&
  min.y >= self.min.y &&
  max.y <= self.max.y
}

/// boolean_intersect returns a new BoundingBox representing the intersection
/// of this bounding box with one or more boxes if one exists.
pub fn boolean_intersect(
  self : BoundingBox,
  boxes : Array[BoundingBox]
) -> BoundingBox? {
  guard boxes.length() > 0
  let mut xmin = self.min.x
  let mut ymin = self.min.y
  let mut xmax = self.max.x
  let mut ymax = self.max.y
  for box in boxes {
    xmin = @math.maximum(xmin, box.min.x)
    xmax = @math.minimum(xmax, box.max.x)
    if xmin > xmax {
      return None
    }
    ymin = @math.maximum(ymin, box.min.y)
    ymax = @math.minimum(ymax, box.max.y)
    if ymin > ymax {
      return None
    }
  }
  Some(BoundingBox::new(min=vec2(xmin, ymin), max=vec2(xmax, ymax)))
}
