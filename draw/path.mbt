///|
/// `Path` represents an open or closed path that can be stroked as an outline
/// or filled. A 'clear' path is sub-path of a `Path` that defines
/// regions of the filled path where no fill is added, for example in the
/// center of the letter 'O'.
pub(all) struct Path {
  mut anchors : Array[Anchor]
  mut closed : Bool
  mut clear : Bool
  mut fill : Fill?
  mut stroke : Stroke?
} derive(Show, FromJson, ToJson)

///|
/// `Path::new` creates a new `Path`.
pub fn Path::new(
  anchors? : Array[Anchor] = [],
  closed? : Bool = false,
  clear? : Bool = false,
  fill? : Fill,
  stroke? : Stroke,
) -> Path {
  { anchors, closed, clear, fill, stroke }
}

///|
/// `as_graphic` returns a `Path` as a `Graphic`.
pub fn Path::as_graphic(self : Path) -> Graphic {
  Path(self)
}

///|
/// `op_get` is a convenience function.
pub fn Path::op_get(self : Path, index : Int) -> Anchor {
  self.anchors[index]
}

///|
/// `op_set` is a convenience function.
pub fn Path::op_set(self : Path, index : Int, anchor : Anchor) -> Unit {
  self.anchors[index] = anchor
}

///|
/// `Path::from_points` connects a series of points with lines to form a `Path`.
pub fn Path::from_points(points : Array[Vec2], closed? : Bool = false) -> Path {
  let anchors = points.map(fn(pt) { Anchor::new(position=pt) })
  { anchors, closed, clear: false, fill: None, stroke: None }
}

///|
pub(open) trait Clonable {
  clone(Self) -> Self
}

///|
fn[T : Clonable] clone_option(v : T?) -> T? {
  v.map_or(None, fn(v) { Some(v.clone()) })
}

///|
/// `clone` makes a new copy of this `Path`.
pub fn Path::clone(self : Path) -> Path {
  let anchors = self.anchors.map(fn(anchor) { anchor.clone() })
  let closed = self.closed
  let clear = self.clear
  let fill = clone_option(self.fill)
  let stroke = clone_option(self.stroke)
  { anchors, closed, clear, fill, stroke }
}

///|
/// `affine_transform` transforms this `Path` by `affine_matrix`.
pub fn Path::affine_transform(
  self : Path,
  affine_matrix : AffineMatrix,
) -> Path {
  let new_anchors = self.anchors.map(fn(anchor) {
    anchor.affine_transform(affine_matrix)
  })
  { ..self, anchors: new_anchors }
}

///|
/// `affine_transform_without_translation` transforms this `Path` by `affine_matrix`
/// without affecting translation.
pub fn Path::affine_transform_without_translation(
  self : Path,
  affine_matrix : AffineMatrix,
) -> Path {
  let new_anchors = self.anchors.map(fn(anchor) {
    anchor.affine_transform_without_translation(affine_matrix)
  })
  { ..self, anchors: new_anchors }
}

///|
/// `transform` provides a convenient API for a common task.
pub fn Path::transform(
  self : Path,
  position? : Vec2 = vec2(0, 0),
  rotation? : Double = 0,
  scale? : Vec2 = vec2(1, 1),
  skew? : Double = 0,
  origin? : Vec2 = vec2(0, 0),
) -> Path {
  let affine_matrix = AffineMatrix::from_transform(
    Transform::new(position~, rotation~, scale~, skew~, origin~),
  )
  self.affine_transform(affine_matrix)
}

///|
/// `with_fill` returns a new `Path` with the provided fill applied.
pub fn Path::with_fill(self : Path, fill : Fill?) -> Path {
  { ..self, fill, }
}

///|
/// `with_stroke` returns a new `Path` with the provided stroke applied.
pub fn Path::with_stroke(self : Path, stroke : Stroke?) -> Path {
  { ..self, stroke, }
}

///|
/// `with_style` returns a new `Path` with the provided fill and stroke applied.
pub fn Path::with_style(self : Path, fill? : Fill, stroke? : Stroke) -> Path {
  { ..self, fill, stroke }
}

///|
fn segment_extents(
  p1 : Vec2,
  h1 : Vec2,
  h2 : Vec2,
  p2 : Vec2,
  lower_left : Vec2,
  upper_right : Vec2,
) -> Unit {
  lower_left..copy(p1).min(p2)
  upper_right..copy(p1).max(p2)
  let d1x = h1.x - p1.x
  let d1y = h1.y - p1.y
  let v1x = p1.x - h1.x * 2 + h2.x
  let v1y = p1.y - h1.y * 2 + h2.y
  let v2x = h1.x * 3 - h2.x * 3 + p2.x - p1.x
  let v2y = h1.y * 3 - h2.y * 3 + p2.y - p1.y
  let mut dist1 = v1x * v1x - v2x * d1x
  let d1_is_zero = d1x == 0 && d1y == 0
  if dist1 > 0 {
    dist1 = dist1.sqrt()
    let mut a = if d1_is_zero {
      (-v1x - dist1) / v2x
    } else {
      d1x / (-v1x - dist1)
    }
    if a > 0 && a < 1 {
      let s = 1.0 - a
      let l = s * s * s * p1.x +
        s * s * a * h1.x * 3 +
        s * a * a * h2.x * 3 +
        a * a * a * p2.x
      lower_left.x = @cmp.minimum(lower_left.x, l)
      upper_right.x = @cmp.maximum(upper_right.x, l)
    }
    a = if d1_is_zero { (-v1x + dist1) / v2x } else { d1x / (-v1x + dist1) }
    if a > 0 && a < 1 {
      let s = 1.0 - a
      let l = s * s * s * p1.x +
        s * s * a * h1.x * 3 +
        s * a * a * h2.x * 3 +
        a * a * a * p2.x
      lower_left.x = @cmp.minimum(lower_left.x, l)
      upper_right.x = @cmp.maximum(upper_right.x, l)
    }
  }
  let mut dist2 = v1y * v1y - v2y * d1y
  if dist2 > 0 {
    dist2 = dist2.sqrt()
    let mut s = if d1_is_zero {
      (-v1y - dist2) / v2y
    } else {
      d1y / (-v1y - dist2)
    }
    if s > 0 && s < 1 {
      let a = 1.0 - s
      let l = a * a * a * p1.y +
        a * a * s * h1.y * 3 +
        a * s * s * h2.y * 3 +
        s * s * s * p2.y
      lower_left.y = @cmp.minimum(lower_left.y, l)
      upper_right.y = @cmp.maximum(upper_right.y, l)
    }
    s = if d1_is_zero { (-v1y + dist2) / v2y } else { d1y / (-v1y + dist2) }
    if s > 0 && s < 1 {
      let a = 1.0 - s
      let l = a * a * a * p1.y +
        a * a * s * h1.y * 3 +
        a * s * s * h2.y * 3 +
        s * s * s * p2.y
      lower_left.y = @cmp.minimum(lower_left.y, l)
      upper_right.y = @cmp.maximum(upper_right.y, l)
    }
  }
}

///|
/// `bounding_box` returns the smallest axis-aligned bounding box that contains
/// this `Path` or `None`.
pub fn Path::bounding_box(self : Path) -> BoundingBox? {
  let { anchors, closed, .. } = self
  let n = anchors.length()
  if n == 0 {
    return None
  }
  if n == 1 {
    return anchors[0].bounding_box()
  }
  let bbox = BoundingBox::max_reversed()
  let handle1 = Vec2::new()
  let handle2 = Vec2::new()
  let lower_left = Vec2::new()
  let upper_right = Vec2::new()
  for i in 1..<n {
    let last_anchor = anchors[i - 1]
    let current_anchor = anchors[i]
    handle1..copy(last_anchor.position).self_add(last_anchor.handle_out)
    handle2..copy(current_anchor.position).self_add(current_anchor.handle_in)
    segment_extents(
      last_anchor.position,
      handle1,
      handle2,
      current_anchor.position,
      lower_left,
      upper_right,
    )
    bbox.min.min(lower_left)
    bbox.max.max(upper_right)
  }
  if closed {
    let last_anchor = anchors[anchors.length() - 1]
    let current_anchor = anchors[0]
    handle1..copy(last_anchor.position).self_add(last_anchor.handle_out)
    handle2..copy(current_anchor.position).self_add(current_anchor.handle_in)
    segment_extents(
      last_anchor.position,
      handle1,
      handle2,
      current_anchor.position,
      lower_left,
      upper_right,
    )
    bbox.min.min(lower_left)
    bbox.max.max(upper_right)
  }
  Some(bbox)
}

///|
/// `closest_point` returns the closest point to `point` that lies on this `Path` or `None`.
pub fn Path::closest_point(
  self : Path,
  point : Vec2,
  area_of_interest : BoundingBox?,
) -> Anchor? {
  let { anchors, closed, .. } = self
  let num_anchors = anchors.length()
  match num_anchors {
    0 => return None
    1 => return Some(Anchor::new(position=anchors[0].position))
    _ => ()
  }
  let mut best_anchor = None
  let mut best_distance = @double.infinity
  let last_anchor = if closed { num_anchors } else { num_anchors - 1 }
  for i in 0..<last_anchor {
    let anchor = anchors[i]
    let next_anchor = anchors[(i + 1) % num_anchors]
    let new_anchor = if anchor.handle_out.is_zero() &&
      next_anchor.handle_in.is_zero() {
      closest_point_to_line(anchor, next_anchor, point, area_of_interest)
    } else {
      // closest_point_to_cubic(anchor, next_anchor, point, area_of_interest)
      closest_point_to_line(anchor, next_anchor, point, area_of_interest)
    }
    if None == new_anchor {
      continue
    }
    let distance = point.distance_squared(new_anchor.unwrap().position)
    if distance < best_distance {
      best_anchor = new_anchor
      best_distance = distance
    }
  }
  best_anchor
}

///|
fn closest_point_to_line(
  a1 : Anchor,
  a2 : Anchor,
  point : Vec2,
  area_of_interest : BoundingBox?,
) -> Anchor? {
  let p1 = a1.closest_point(point, area_of_interest?)
  let p2 = a2.closest_point(point, area_of_interest?)
  match (p1, p2) {
    (Some(p1), Some(p2)) => {
      let d1 = p1.distance_squared(point)
      let d2 = p2.distance_squared(point)
      if d1 < d2 {
        Some(a1)
      } else {
        Some(a2)
      }
    }
    (Some(_p1), None) => Some(a1)
    (None, Some(_p2)) => Some(a2)
    _ => None
  }
}

// TODO:
// fn closest_point_to_cubic(
//   a1 : Anchor,
//   a2 : Anchor,
//   point : Vec2,
//   area_of_interest : BoundingBox?
// ) -> Anchor? {
// }

///|
/// `contains_point` returns true if this `Path` contains `point`.
pub fn Path::contains_point(_self : Path, _point : Vec2) -> Bool {
  false // TODO
}

///|
/// `copy_style` copies the fill and stroke from `graphic` and returns a new `Path`.
pub fn Path::copy_style(self : Path, graphic : Graphic) -> Path {
  let fill = graphic.first_fill()
  let stroke = graphic.first_stroke()
  { ..self, fill, stroke }
}

///|
/// `first_styled` returns this `Path` if it is styled or `None`.
pub fn Path::first_styled(self : Path) -> Graphic? {
  if self.has_style() {
    Some(Path(self))
  } else {
    None
  }
}

///|
/// `has_style` returns true if this `Path` has fill or stroke.
pub fn Path::has_style(self : Path) -> Bool {
  self.fill != None || self.stroke != None
}

///|
/// `is_contained_by_bounding_box` returns true if no part of this `Path`
/// lies beyond its min or max.
pub fn Path::is_contained_by_bounding_box(
  self : Path,
  box : BoundingBox,
) -> Bool {
  let bbox = self.bounding_box()
  if None == bbox {
    return false
  }
  let bbox = bbox.unwrap()
  bbox.contains_bounding_box(box)
}

///|
/// is_intersected_by_bounding_box returns true if part of this Path crosses
/// the boundary between inside and outside of `box`.
pub fn Path::is_intersected_by_bounding_box(
  _self : Path,
  _box : BoundingBox,
) -> Bool {
  // TODO
  false
  // let lbb = self.loose_bounding_box()
  // if None == lbb {
  //   return false
  // }
  // let lbb = lbb.unwrap()
  // if not(lbb.overlaps_bounding_box(box)) {
  //   return false
  // }
  // let { min, max } = box
  // let ll = vec2(min.x, min.y)
  // let lr = vec2(max.x, min.y)
  // let ur = vec2(max.x, max.y)
  // let ul = vec2(min.x, max.y)
  // self
  // .intersections_with(
  //   [
  //     LineSegment::new(ll, lr),
  //     LineSegment::new(lr, ur),
  //     LineSegment::new(ur, ul),
  //     LineSegment::new(ul, ll),
  //   ],
  // )
  // .length() >
  // 0
}

///|
/// `is_overlapped_by_bounding_box` returns if true if a point can be chosen
/// that is inside both the `Path` and `box`.
pub fn Path::is_overlapped_by_bounding_box(
  self : Path,
  box : BoundingBox,
) -> Bool {
  self.is_contained_by_bounding_box(box) ||
  self.is_intersected_by_bounding_box(box)
}

///|
/// `loose_bounding_box` returns an approximate bounding box for this `Path`.
/// It may not be the smallest possible bounding box, but is cheaper to compute.
pub fn Path::loose_bounding_box(self : Path) -> BoundingBox? {
  let { anchors, closed, .. } = self
  match anchors.length() {
    0 => return None
    1 => return anchors[0].loose_bounding_box()
    _ => ()
  }
  let mut current_anchor = anchors[0]
  let bbox = BoundingBox::new(
    min=current_anchor.position.clone(),
    max=current_anchor.position.clone(),
  )
  bbox.expand_to_include_point(
    current_anchor.position.add(current_anchor.handle_out),
  )
  if closed {
    bbox.expand_to_include_point(
      current_anchor.position.add(current_anchor.handle_in),
    )
  }
  let last_index = anchors.length() - 1
  for i in 1..<last_index {
    current_anchor = anchors[i]
    bbox.expand_to_include_point(current_anchor.position)
    bbox.expand_to_include_point(
      current_anchor.position.add(current_anchor.handle_in),
    )
    bbox.expand_to_include_point(
      current_anchor.position.add(current_anchor.handle_out),
    )
  }
  current_anchor = anchors[last_index]
  bbox.expand_to_include_point(current_anchor.position)
  bbox.expand_to_include_point(
    current_anchor.position.add(current_anchor.handle_in),
  )
  if closed {
    bbox.expand_to_include_point(
      current_anchor.position.add(current_anchor.handle_out),
    )
  }
  Some(bbox)
}

///|
/// `primitives` returns a flattened array of `Graphic` primitives.
pub fn Path::primitives(self : Path) -> Array[Graphic] {
  [Path(self)]
}

///|
/// `remove_fill` returns a new `Path` without fill styling.
pub fn Path::remove_fill(self : Path) -> Path {
  { ..self, fill: None }
}

///|
/// `remove_stroke` returns a new `Path` without stroke styling.
pub fn Path::remove_stroke(self : Path) -> Path {
  { ..self, stroke: None }
}

///|
/// `reverse` returns a new `Path` with all anchors reversed.
pub fn Path::reverse(self : Path) -> Path {
  let anchors = self.anchors
    .iter()
    .map(fn(anchor) { anchor.reverse() })
    .collect()
    .rev()
  { ..self, anchors, }
}

///|
/// `scale_stroke` returns a new `Path` with the width of its stroke (if any) scaled by `scale_factor`.
pub fn Path::scale_stroke(self : Path, scale_factor : Double) -> Path {
  match self.stroke {
    Some(stroke) => {
      let width = stroke.width * scale_factor
      let new_stroke = { ..stroke, width, }
      { ..self, stroke: Some(new_stroke) }
    }
    _ => self
  }
}

///|
/// `style_contains_point` returns true if this path's style contains `point`.
pub fn Path::style_contains_point(_self : Path, _point : Vec2) -> Bool {
  // TODO
  false
}

///|
/// `translate` translates a `Path` by `v`.
pub fn Path::translate(self : Path, v : Vec2) -> Path {
  let affine_matrix = AffineMatrix::from_translation(v)
  self.affine_transform(affine_matrix)
}

///|
/// `scale` scales a `Path` by `v`.
pub fn Path::scale(self : Path, v : Vec2) -> Path {
  let affine_matrix = AffineMatrix::from_scale(v)
  self.affine_transform(affine_matrix)
}

///|
/// `rotate` rotates a `Path` clockwise by `angle` in degrees.
pub fn Path::rotate(self : Path, angle : Double) -> Path {
  let affine_matrix = AffineMatrix::from_rotation(angle)
  self.affine_transform(affine_matrix)
}

///|
/// `to_polygon` converts a closed path with Bézier curves into a polygon (array of `Vec2` points).
/// Returns an empty array for open paths.
pub fn Path::to_polygon(
  self : Path,
  curve_segments : Int,
  epsilon? : Double,
) -> Array[Vec2] {
  if !self.closed {
    return []
  }
  let points : Array[Vec2] = []
  let len = self.anchors.length()
  if len < 2 {
    return []
  }
  for i in 0..<len {
    let a1 = self.anchors[i]
    let a2 = self.anchors[(i + 1) % len]
    let p0 = a1.position
    let p3 = a2.position
    let p1 = p0.add(a1.handle_out)
    let p2 = p3.add(a2.handle_in)
    // Check if it's a line (handles are zero)
    if a1.handle_out.x == 0.0 &&
      a1.handle_out.y == 0.0 &&
      a2.handle_in.x == 0.0 &&
      a2.handle_in.y == 0.0 {
      // Line segment, add the start point (end will be added as start of next)
      points.push(p0)
    } else {
      // Curve segment, sample points
      for j in 0..<curve_segments {
        let t = j.to_double() / (curve_segments - 1).to_double()
        let point = cubic_bezier_at(p0, p1, p2, p3, t)
        points.push(point)
      }
    }
  }
  let poly = dedupe_points(points, epsilon?)
  let eps = match epsilon {
    None => 1.e-9
    Some(v) => v
  }
  let eps_sq = eps * eps
  if poly.length() > 1 {
    let last_idx = poly.length() - 1
    if poly[0].distance_squared(poly[last_idx]) <= eps_sq {
      ignore(poly.pop())
    }
  }
  poly
}

///|
/// `cubic_bezier_at` evaluates a cubic Bézier curve at parameter t.
/// P(t) = (1-t)^3 P0 + 3(1-t)^2 t P1 + 3(1-t) t^2 P2 + t^3 P3
pub fn cubic_bezier_at(
  p0 : Vec2,
  p1 : Vec2,
  p2 : Vec2,
  p3 : Vec2,
  t : Double,
) -> Vec2 {
  let u = 1.0 - t
  let uu = u * u
  let tt = t * t
  let uuu = uu * u
  let ttt = tt * t
  let ut3 = 3.0 * uu * t
  let tu3 = 3.0 * u * tt
  p0
  .clone()
  ..self_mul_scalar(uuu)
  .add(p1.mul_scalar(ut3))
  .add(p2.mul_scalar(tu3))
  .add(p3.mul_scalar(ttt))
}
