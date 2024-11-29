/// Group represents a collection of Graphics elements.
pub(all) struct Group {
  items : Array[Graphic]
}

/// Group::new returns a new group.
pub fn Group::new(items~ : Array[Graphic] = []) -> Group {
  { items, }
}

/// group is a convenience function.
pub fn group(items : Array[Graphic]) -> Group {
  { items, }
}

/// transform transforms this Group by `transform`.
pub fn transform(self : Group, transform : Transform) -> Group {
  let affine_matrix = AffineMatrix::from_transform(transform)
  self.affine_transform(affine_matrix)
}

/// clone returns a new copy of this Group.
pub fn clone(self : Group) -> Group {
  group(self.items.map(fn(item) { item.clone() }))
}

/// affine_transform transforms this Group by `affine_matrix`.
pub fn affine_transform(self : Group, affine_matrix : AffineMatrix) -> Group {
  for item in self.items {
    ignore(item.affine_transform(affine_matrix))
  }
  self
}

/// affine_transform_without_translation transforms this Group by `affine_matrix`
/// without affecting the translation.
pub fn affine_transform_without_translation(
  self : Group,
  affine_matrix : AffineMatrix
) -> Group {
  for item in self.items {
    ignore(item.affine_transform_without_translation(affine_matrix))
  }
  self
}

/// loose_bounding_box returns an approximate bounding box for all items
/// in the Group. It may not be the smallest possible bounding box, but
/// is cheaper to compute.
pub fn loose_bounding_box(self : Group) -> BoundingBox {
  Graphic::loose_bounding_box(self.items)
}

/// bounding_box returns the bounding box for all items in the Group.
pub fn bounding_box(self : Group) -> BoundingBox {
  Graphic::bounding_box(self.items)
}

/// is_contained_by_bounding_box returns true if no part of the Group
/// lies beyond the box's min and max.
pub fn is_contained_by_bounding_box(self : Group, box : BoundingBox) -> Bool {
  self.items.length() != 0 &&
  Graphic::every(self.items, Graphic::is_contained_by_bounding_box(box))
}

/// is_intersected_by_bounding_box returns true if any part of the Group
/// crosses the boundary between the inside and outside of `box`.
pub fn is_intersected_by_bounding_box(self : Group, box : BoundingBox) -> Bool {
  Graphic::some(self.items, Graphic::is_intersected_by_bounding_box(box))
}

/// is_overlapped_by_bounding_box returns true if a point can be found that
/// is inside both the Graphic and the box.
pub fn is_overlapped_by_bounding_box(self : Group, box : BoundingBox) -> Bool {
  Graphic::some(self.items, Graphic::is_overlapped_by_bounding_box(box))
}

/// closest_point returns the closest Anchor to `point` that lies on this Group
/// or None.
pub fn closest_point(
  self : Group,
  point : Vec2,
  area_of_interest : BoundingBox?
) -> Anchor? {
  let { items } = self
  match items.length() {
    0 => return None
    1 => return items[0].closest_point(point, area_of_interest)
    _ => ()
  }

  //
  let mut closest_point : Anchor? = None
  let mut closest_distance = @double.infinity
  for item in items {
    match item.closest_point(point, area_of_interest) {
      None => continue
      Some(anchor) => {
        let dist = point.distance_squared(anchor.position)
        if dist < closest_distance {
          closest_point = Some(anchor)
          closest_distance = dist
        }
      }
    }
  }
  closest_point
}
