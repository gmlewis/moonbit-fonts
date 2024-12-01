/// Group represents a collection of Graphics elements.
pub(all) struct Group {
  mut items : Array[Graphic]
} derive(Show)

/// Group::new returns a new group.
pub fn Group::new(items~ : Array[Graphic] = []) -> Group {
  { items, }
}

/// as_graphic returns a Group as a Graphic.
pub fn as_graphic(self : Group) -> Graphic {
  Group(self)
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
pub fn loose_bounding_box(self : Group) -> BoundingBox? {
  Graphic::loose_bounding_box(self.items)
}

/// bounding_box returns the bounding box for all items in the Group.
pub fn bounding_box(self : Group) -> BoundingBox? {
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

/// primitives returns a flattened array of all Graphic primitives in this Group.
pub fn primitives(self : Group) -> Array[Graphic] {
  self.items.iter().flat_map(fn(item) { item.primitives().iter() }).collect()
}

/// reverse reverses this Group.
pub fn reverse(self : Group) -> Group {
  for item in self.items {
    ignore(item.reverse())
  }
  self.items = self.items.rev()
  self
}

/// all_compound_paths returns all compound paths in this Group.
pub fn all_compound_paths(self : Group) -> Array[CompoundPath] {
  self.items
  .iter()
  .flat_map(fn(item) { item.all_compound_paths().iter() })
  .collect()
}

/// all_paths returns all Paths in this Group.
pub fn all_paths(self : Group) -> Array[Path] {
  self.items.iter().flat_map(fn(item) { item.all_paths().iter() }).collect()
}

/// all_anchors returns all Anchors in this Group.
pub fn all_anchors(self : Group) -> Array[Anchor] {
  self.items.iter().flat_map(fn(item) { item.all_anchors().iter() }).collect()
}

/// all_paths_and_compound_paths returns all Paths and CompoundPaths in this Group.
pub fn all_paths_and_compound_paths(self : Group) -> Array[Graphic] {
  self.items
  .iter()
  .flat_map(fn(item) { item.all_paths_and_compound_paths().iter() })
  .collect()
}

/// has_style returns true if this Group has either a stroke or a fill.
pub fn has_style(self : Group) -> Bool {
  for item in self.items {
    if item.has_style() {
      return true
    }
  }
  false
}

/// assign_fill assigns a fill to this Group.
pub fn assign_fill(self : Group, fill : Fill?) -> Group {
  for item in self.items {
    ignore(item.assign_fill(fill))
  }
  self
}

/// remove_fill removes a fill style from this Group.
pub fn remove_fill(self : Group) -> Group {
  for item in self.items {
    ignore(item.remove_fill())
  }
  self
}

/// assign_stroke assigns a stroke to this Group.
pub fn assign_stroke(self : Group, stroke : Stroke?) -> Group {
  for item in self.items {
    ignore(item.assign_stroke(stroke))
  }
  self
}

/// remove_stroke removes a stroke style from this Group.
pub fn remove_stroke(self : Group) -> Group {
  for item in self.items {
    ignore(item.remove_stroke())
  }
  self
}

/// assign_style assigns a fill and stroke style to this Group.
pub fn assign_style(self : Group, fill : Fill?, stroke : Stroke?) -> Group {
  for item in self.items {
    ignore(item.assign_style(fill, stroke))
  }
  self
}

/// copy_style copies the fill and stroke style from `graphic`.
pub fn copy_style(self : Group, graphic : Graphic) -> Group {
  for item in self.items {
    ignore(item.copy_style(graphic))
  }
  self
}

/// scale_stroke scales the stroke width of this Group by `scale_factor`.
pub fn scale_stroke(self : Group, scale_factor : Double) -> Group {
  for item in self.items {
    ignore(item.scale_stroke(scale_factor))
  }
  self
}

/// first_styled returns the first Path or CompoundPath in this Group
/// that has either a fill or a stroke, or None.
pub fn first_styled(self : Group) -> Graphic? {
  for item in self.items {
    match item.first_styled() {
      Some(graphic) => return Some(graphic)
      _ => ()
    }
  }
  None
}

/// contains_point returns true if this Group contains `point`.
pub fn contains_point(self : Group, point : Vec2) -> Bool {
  Graphic::some(self.items, Graphic::contains_point(point))
}

/// style_contains_point returns true if this Group's style contains `point`.
pub fn style_contains_point(self : Group, point : Vec2) -> Bool {
  Graphic::some(self.items, Graphic::style_contains_point(point))
}

/// first_fill returns the first fill from this Group.
pub fn first_fill(self : Group) -> Fill? {
  for item in self.items {
    match item.first_fill() {
      Some(fill) => return Some(fill)
      _ => ()
    }
  }
  None
}

/// first_stroke returns the first stroke from this Group.
pub fn first_stroke(self : Group) -> Stroke? {
  for item in self.items {
    match item.first_stroke() {
      Some(stroke) => return Some(stroke)
      _ => ()
    }
  }
  None
}
