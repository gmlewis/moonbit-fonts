///|
/// Anchor represents a single point in a path. Two anchors form a segment.
/// The position of an Anchor is absolute and the handles are both relative.
pub(all) struct Anchor {
  mut position : Vec2 // absolute
  mut handle_in : Vec2 // relative
  mut handle_out : Vec2 // relative
} derive(Show, Eq, FromJson, ToJson)

///|
/// Anchor::new returns a new anchor. You must either create new Vec2 points
/// or clone them before passing them in.
pub fn Anchor::new(
  position~ : Vec2 = vec2(0, 0),
  handle_in~ : Vec2 = vec2(0, 0),
  handle_out~ : Vec2 = vec2(0, 0)
) -> Anchor {
  { position, handle_in, handle_out }
}

///|
/// clone makes a new copy of this Anchor.
pub fn Anchor::clone(self : Anchor) -> Anchor {
  Anchor::new(
    position=self.position.clone(),
    handle_in=self.handle_in.clone(),
    handle_out=self.handle_out.clone(),
  )
}

///|
/// affine_transform transforms this Anchor by the provided `affine_matrix`.
pub fn affine_transform(self : Anchor, affine_matrix : AffineMatrix) -> Anchor {
  let _ = self.position.affine_transform(affine_matrix)
  let _ = self.handle_in.affine_transform_without_translation(affine_matrix)
  let _ = self.handle_out.affine_transform_without_translation(affine_matrix)
  self
}

///|
/// affine_transform_without_translation transforms this Anchor's rotation, scale,
/// and skew, without affecting its translation.
pub fn affine_transform_without_translation(
  self : Anchor,
  affine_matrix : AffineMatrix
) -> Anchor {
  let _ = self.position.affine_transform_without_translation(affine_matrix)
  let _ = self.handle_in.affine_transform_without_translation(affine_matrix)
  let _ = self.handle_out.affine_transform_without_translation(affine_matrix)
  self
}

///|
/// transform provides a convenient API for a common task.
pub fn transform(
  self : Anchor,
  position~ : Vec2 = vec2(0, 0),
  rotation~ : Double = 0,
  scale~ : Vec2 = vec2(1, 1),
  skew~ : Double = 0,
  origin~ : Vec2 = vec2(0, 0)
) -> Anchor {
  let affine_matrix = AffineMatrix::from_transform(
    Transform::new(position~, rotation~, scale~, skew~, origin~),
  )
  self.affine_transform(affine_matrix)
}

///|
/// loose_bounding_box is a simple computation that returns a BoundingBox which
/// may not be the smallest possible.
pub fn loose_bounding_box(self : Anchor) -> BoundingBox? {
  Some(BoundingBox::new(min=self.position.clone(), max=self.position.clone()))
}

///|
/// bounding_box returns a BoundingBox for this Anchor.
pub fn bounding_box(self : Anchor) -> BoundingBox? {
  Some(BoundingBox::new(min=self.position.clone(), max=self.position.clone()))
}

///|
/// is_contained_by_bounding_box returns true if this Anchor lies within `box`.
pub fn is_contained_by_bounding_box(self : Anchor, box : BoundingBox) -> Bool {
  box.contains_point(self.position)
}

///|
/// is_intersected_by_bounding_box returns true if the Anchor lies on the
/// boundary of `box`.
pub fn is_intersected_by_bounding_box(self : Anchor, box : BoundingBox) -> Bool {
  let { min, max } = box
  let { x, y } = self.position
  (x >= min.x && x <= max.x && (y == min.y || y == max.y)) ||
  (y >= min.y && y <= max.y && (x == min.x || x == max.x))
}

///|
/// is_overlapped_by_bounding_box returns true if the Anchor is within `box`.
pub fn is_overlapped_by_bounding_box(self : Anchor, box : BoundingBox) -> Bool {
  box.contains_point(self.position)
}

///|
/// closest_point returns the closest point to `point` or None if no point is found.
/// area_of_interest is used to focus the computation within a smaller region.
pub fn closest_point(
  self : Anchor,
  point : Vec2,
  area_of_interest? : BoundingBox
) -> Vec2? {
  let { position, .. } = self
  match area_of_interest {
    Some(box) =>
      if box.contains_point(position) {
        return Some(position.clone())
      }
    _ => if position == point { return Some(position.clone()) }
  }
  None
}

///|
/// reverse reverses this Anchor.
pub fn reverse(self : Anchor) -> Anchor {
  let { handle_in, handle_out, .. } = self
  self.handle_in = handle_out
  self.handle_out = handle_in
  self
}

///|
let tmp1 : Vec2 = Vec2::new()

///|
let tmp2 : Vec2 = Vec2::new()

///|
/// has_tangent_handles returns true if this Anchor has handles that
/// are tangent to each other.
pub fn has_tangent_handles(
  self : Anchor,
  tolerance~ : Double = DEFAULT_TOLERANCE
) -> Bool {
  let _ = tmp1.copy(self.handle_in).normalize()
  let _ = tmp2.copy(self.handle_out).normalize()
  tmp1.dot(tmp2) <= tolerance - 1
}

///|
/// has_zero_handles returns true if this Anchor has handles that are both zero.
pub fn has_zero_handles(self : Anchor) -> Bool {
  self.handle_in.is_zero() && self.handle_out.is_zero()
}

///|
/// all_anchors returns all anchors.
pub fn all_anchors(self : Anchor) -> Array[Anchor] {
  [self]
}
