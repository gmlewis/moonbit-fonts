///|
/// Path represents an open or closed path that can be stroked as an outline
/// or filled. A 'clear' path is sub-path of a Path that defines
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
/// Path::new creates a new Path.
pub fn Path::new(
  anchors~ : Array[Anchor] = [],
  closed~ : Bool = false,
  clear~ : Bool = false,
  fill? : Fill,
  stroke? : Stroke,
) -> Path {
  { anchors, closed, clear, fill, stroke }
}

///|
/// as_graphic returns a Path as a Graphic.
pub fn Path::as_graphic(self : Path) -> Graphic {
  Path(self)
}

///|
/// op_get is a convenience function.
pub fn Path::op_get(self : Path, index : Int) -> Anchor {
  self.anchors[index]
}

///|
/// op_set is a convenience function.
pub fn Path::op_set(self : Path, index : Int, anchor : Anchor) -> Unit {
  self.anchors[index] = anchor
}

///|
/// Path::from_points connects a series of points with lines to form a Path.
pub fn Path::from_points(points : Array[Vec2], closed~ : Bool = false) -> Path {
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
/// clone makes a new copy of this Path.
pub fn Path::clone(self : Path) -> Path {
  let anchors = self.anchors.map(fn(anchor) { anchor.clone() })
  let closed = self.closed
  let clear = self.clear
  let fill = clone_option(self.fill)
  let stroke = clone_option(self.stroke)
  { anchors, closed, clear, fill, stroke }
}

///|
/// affine_transform transforms this Path by `affine_matrix`.
pub fn Path::affine_transform(
  self : Path,
  affine_matrix : AffineMatrix,
) -> Path {
  for anchor in self.anchors {
    ignore(anchor.affine_transform(affine_matrix))
  }
  self
}

///|
/// affine_transform_without_translation transforms this Path by `affine_matrix`
/// without affecting translation.
pub fn Path::affine_transform_without_translation(
  self : Path,
  affine_matrix : AffineMatrix,
) -> Path {
  for anchor in self.anchors {
    ignore(anchor.affine_transform_without_translation(affine_matrix))
  }
  self
}

///|
/// transform provides a convenient API for a common task.
pub fn Path::transform(
  self : Path,
  position~ : Vec2 = vec2(0, 0),
  rotation~ : Double = 0,
  scale~ : Vec2 = vec2(1, 1),
  skew~ : Double = 0,
  origin~ : Vec2 = vec2(0, 0),
) -> Path {
  let affine_matrix = AffineMatrix::from_transform(
    Transform::new(position~, rotation~, scale~, skew~, origin~),
  )
  self.affine_transform(affine_matrix)
}

///|
/// assign_fill assigns a fill to this Path.
pub fn Path::assign_fill(self : Path, fill : Fill?) -> Path {
  self.fill = fill
  self
}

///|
/// assign_stroke assigns a stroke to this Path.
pub fn Path::assign_stroke(self : Path, stroke : Stroke?) -> Path {
  self.stroke = stroke
  self
}

///|
/// assign_style assigns a stroke and fill style to this Path.
pub fn Path::assign_style(self : Path, fill : Fill?, stroke : Stroke?) -> Path {
  self.fill = fill
  self.stroke = stroke
  self
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
  ignore(lower_left.copy(p1).min(p2))
  ignore(upper_right.copy(p1).max(p2))
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
/// bounding_box returns the smallest axis-aligned bounding box that contains
/// this Path or None.
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
    ignore(handle1.copy(last_anchor.position).add(last_anchor.handle_out))
    ignore(handle2.copy(current_anchor.position).add(current_anchor.handle_in))
    segment_extents(
      last_anchor.position,
      handle1,
      handle2,
      current_anchor.position,
      lower_left,
      upper_right,
    )
    ignore(bbox.min.min(lower_left))
    ignore(bbox.max.max(upper_right))
  }
  if closed {
    let last_anchor = anchors[anchors.length() - 1]
    let current_anchor = anchors[0]
    ignore(handle1.copy(last_anchor.position).add(last_anchor.handle_out))
    ignore(handle2.copy(current_anchor.position).add(current_anchor.handle_in))
    segment_extents(
      last_anchor.position,
      handle1,
      handle2,
      current_anchor.position,
      lower_left,
      upper_right,
    )
    ignore(bbox.min.min(lower_left))
    ignore(bbox.max.max(upper_right))
  }
  Some(bbox)
}

///|
/// closest_point returns the closest point to `point` that lies on this Path or None.
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
/// contains_point returns true if this Path contains `point`.
pub fn Path::contains_point(_self : Path, _point : Vec2) -> Bool {
  false // TODO
}

///|
/// copy_style copies the fill and stroke from `graphic`.
pub fn Path::copy_style(self : Path, graphic : Graphic) -> Path {
  self.fill = graphic.first_fill()
  self.stroke = graphic.first_stroke()
  self
}

///|
/// first_styled returns this Path if it is styled or None.
pub fn Path::first_styled(self : Path) -> Graphic? {
  if self.has_style() {
    Some(Path(self))
  } else {
    None
  }
}

///|
/// has_style returns true if this Path has fill or stroke.
pub fn Path::has_style(self : Path) -> Bool {
  self.fill != None || self.stroke != None
}

///|
/// is_contained_by_bounding_box returns true if no part of this Path
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
/// is_overlapped_by_bounding_box returns if true if a point can be chosen
/// that is inside both the Path and `box`.
pub fn Path::is_overlapped_by_bounding_box(
  self : Path,
  box : BoundingBox,
) -> Bool {
  self.is_contained_by_bounding_box(box) ||
  self.is_intersected_by_bounding_box(box)
}

///|
/// loose_bounding_box returns an approximate bounding box for this Path.
/// It may not be the smallest possible bounding box, but is cheaper to compute.
pub fn Path::loose_bounding_box(self : Path) -> BoundingBox? {
  let { anchors, closed, .. } = self
  match anchors.length() {
    0 => return None
    1 => return anchors[0].loose_bounding_box()
    _ => ()
  }
  let vec = Vec2::new()
  let mut current_anchor = anchors[0]
  let bbox = BoundingBox::new(
    min=current_anchor.position.clone(),
    max=current_anchor.position.clone(),
  )
  ignore(
    bbox.expand_to_include_point(
      vec.copy(current_anchor.position).add(current_anchor.handle_out),
    ),
  )
  if closed {
    ignore(
      bbox.expand_to_include_point(
        vec.copy(current_anchor.position).add(current_anchor.handle_in),
      ),
    )
  }
  let last_index = anchors.length() - 1
  for i in 1..<last_index {
    current_anchor = anchors[i]
    ignore(bbox.expand_to_include_point(current_anchor.position))
    ignore(
      bbox.expand_to_include_point(
        vec.copy(current_anchor.position).add(current_anchor.handle_in),
      ),
    )
    ignore(
      bbox.expand_to_include_point(
        vec.copy(current_anchor.position).add(current_anchor.handle_out),
      ),
    )
  }
  current_anchor = anchors[last_index]
  ignore(bbox.expand_to_include_point(current_anchor.position))
  ignore(
    bbox.expand_to_include_point(
      vec.copy(current_anchor.position).add(current_anchor.handle_in),
    ),
  )
  if closed {
    ignore(
      bbox.expand_to_include_point(
        vec.copy(current_anchor.position).add(current_anchor.handle_out),
      ),
    )
  }
  Some(bbox)
}

///|
/// primitives returns a flattened array of Graphics primitives.
pub fn Path::primitives(self : Path) -> Array[Graphic] {
  [Path(self)]
}

///|
/// remove_fill removes fill styling from this Path.
pub fn Path::remove_fill(self : Path) -> Path {
  self.fill = None
  self
}

///|
/// remove_stroke removes stroke styling from this Path.
pub fn Path::remove_stroke(self : Path) -> Path {
  self.stroke = None
  self
}

///|
/// reverse reverses this Path.
pub fn Path::reverse(self : Path) -> Path {
  for anchor in self.anchors {
    ignore(anchor.reverse())
  }
  self.anchors = self.anchors.rev()
  self
}

///|
/// scale_stroke scales the width of this stroke by `scale_factor`.
pub fn Path::scale_stroke(self : Path, scale_factor : Double) -> Path {
  match self.stroke {
    Some(stroke) => stroke.width *= scale_factor
    _ => ()
  }
  self
}

///|
/// style_contains_point returns true if this path's style contains `point`.
pub fn Path::style_contains_point(_self : Path, _point : Vec2) -> Bool {
  // TODO
  false
}

///|
/// translate translates a Path by `v`.
pub fn Path::translate(self : Path, v : Vec2) -> Path {
  let affine_matrix = AffineMatrix::from_translation(v)
  self.affine_transform(affine_matrix)
}

///|
/// scale scales a Path by `v`.
pub fn Path::scale(self : Path, v : Vec2) -> Path {
  let affine_matrix = AffineMatrix::from_scale(v)
  self.affine_transform(affine_matrix)
}

///|
/// rotate rotates a Path clockwise by `angle` in degrees.
pub fn Path::rotate(self : Path, angle : Double) -> Path {
  let affine_matrix = AffineMatrix::from_rotation(angle)
  self.affine_transform(affine_matrix)
}
