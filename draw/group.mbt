///|
/// `Group` represents a collection of `Graphic` elements.
pub(all) struct Group {
  mut items : Array[Graphic]
} derive(Show, FromJson, ToJson)

///|
/// `Group::new` returns a new `Group`.
pub fn Group::new(items? : Array[Graphic] = []) -> Group {
  { items, }
}

///|
/// `as_graphic` returns a `Group` as a `Graphic`.
pub fn Group::as_graphic(self : Group) -> Graphic {
  Group(self)
}

///|
/// `op_get` is a convenience function.
pub fn Group::op_get(self : Group, index : Int) -> Graphic {
  self.items[index]
}

///|
/// `op_set` is a convenience function.
pub fn Group::op_set(self : Group, index : Int, graphic : Graphic) -> Unit {
  self.items[index] = graphic
}

///|
/// `group` is a convenience function.
pub fn group(items : Array[Graphic]) -> Group {
  { items, }
}

///|
/// `clone` returns a new copy of this `Group`.
pub fn Group::clone(self : Group) -> Group {
  group(self.items.map(fn(item) { item.clone() }))
}

///|
/// `affine_transform` transforms this `Group` by `affine_matrix`, returning a new `Group`.
pub fn Group::affine_transform(
  self : Group,
  affine_matrix : AffineMatrix,
) -> Group {
  { items: self.items.map(fn(item) { item.affine_transform(affine_matrix) }) }
}

///|
/// affine_transform_without_translation transforms this Group by `affine_matrix`
/// without affecting the translation.
pub fn Group::affine_transform_without_translation(
  self : Group,
  affine_matrix : AffineMatrix,
) -> Group {
  {
    items: self.items.map(fn(item) {
      item.affine_transform_without_translation(affine_matrix)
    }),
  }
}

///|
/// `transform` provides a convenient API for a common task, returning a new `Group`.
pub fn Group::transform(
  self : Group,
  position? : Vec2 = vec2(0, 0),
  rotation? : Double = 0,
  scale? : Vec2 = vec2(1, 1),
  skew? : Double = 0,
  origin? : Vec2 = vec2(0, 0),
) -> Group {
  let affine_matrix = AffineMatrix::from_transform(
    Transform::new(position~, rotation~, scale~, skew~, origin~),
  )
  self.affine_transform(affine_matrix)
}

///|
/// `self_transform` provides a convenient API for a common task, modifying the group in-place.
pub fn Group::self_transform(
  self : Group,
  position? : Vec2 = vec2(0, 0),
  rotation? : Double = 0,
  scale? : Vec2 = vec2(1, 1),
  skew? : Double = 0,
  origin? : Vec2 = vec2(0, 0),
) -> Unit {
  let new_group = self.transform(position~, rotation~, scale~, skew~, origin~)
  self.items = new_group.items
}

///|
/// `loose_bounding_box` returns an approximate bounding box for all items
/// in the `Group`. It may not be the smallest possible bounding box, but
/// is cheaper to compute.
pub fn Group::loose_bounding_box(self : Group) -> BoundingBox? {
  let bbox = BoundingBox::max_reversed()

  // Expand bbox to include all other items
  for item in self.items {
    match item {
      CompoundPath(compound_path) => {
        let item_bbox = match compound_path.loose_bounding_box() {
          None => continue
          Some(bbox) => bbox
        }
        bbox.expand_to_include_bounding_box(item_bbox)
      }
      Group(group) => {
        let item_bbox = match group.loose_bounding_box() {
          None => continue
          Some(bbox) => bbox
        }
        bbox.expand_to_include_bounding_box(item_bbox)
      }
      Path(path) => {
        let item_bbox = match path.loose_bounding_box() {
          None => continue
          Some(bbox) => bbox
        }
        bbox.expand_to_include_bounding_box(item_bbox)
      }
    }
  }
  match bbox.is_inf() {
    true => None
    false => Some(bbox)
  }
}

///|
/// `bounding_box` returns the bounding box for all items in the `Group`.
pub fn Group::bounding_box(self : Group) -> BoundingBox? {
  let bbox = BoundingBox::max_reversed()

  // Expand bbox to include all other items
  for item in self.items {
    match item {
      CompoundPath(compound_path) => {
        let item_bbox = match compound_path.bounding_box() {
          None => continue
          Some(bbox) => bbox
        }
        bbox.expand_to_include_bounding_box(item_bbox)
      }
      Group(group) => {
        let item_bbox = match group.bounding_box() {
          None => continue
          Some(bbox) => bbox
        }
        bbox.expand_to_include_bounding_box(item_bbox)
      }
      Path(path) => {
        let item_bbox = match path.bounding_box() {
          None => continue
          Some(bbox) => bbox
        }
        bbox.expand_to_include_bounding_box(item_bbox)
      }
    }
  }
  match bbox.is_inf() {
    true => None
    false => Some(bbox)
  }
}

///|
/// `is_contained_by_bounding_box` returns true if no part of the `Group`
/// lies beyond the box's min and max.
pub fn Group::is_contained_by_bounding_box(
  self : Group,
  box : BoundingBox,
) -> Bool {
  self.items.length() != 0 &&
  Graphic::every(self.items, Graphic::is_contained_by_bounding_box(box))
}

///|
/// `is_intersected_by_bounding_box` returns true if any part of the `Group`
/// crosses the boundary between the inside and outside of `box`.
pub fn Group::is_intersected_by_bounding_box(
  self : Group,
  box : BoundingBox,
) -> Bool {
  Graphic::some(self.items, Graphic::is_intersected_by_bounding_box(box))
}

///|
/// `is_overlapped_by_bounding_box` returns true if a point can be found that
/// is inside both the `Graphic` and the box.
pub fn Group::is_overlapped_by_bounding_box(
  self : Group,
  box : BoundingBox,
) -> Bool {
  Graphic::some(self.items, Graphic::is_overlapped_by_bounding_box(box))
}

///|
/// `closest_point` returns the closest `Anchor` to `point` that lies on this `Group`
/// or `None`.
pub fn Group::closest_point(
  self : Group,
  point : Vec2,
  area_of_interest : BoundingBox?,
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

///|
/// `primitives` returns a flattened array of all `Graphic` primitives in this `Group`.
pub fn Group::primitives(self : Group) -> Array[Graphic] {
  self.items.iter().flat_map(fn(item) { item.primitives().iter() }).collect()
}

///|
/// `reverse` reverses this `Group`.
pub fn Group::reverse(self : Group) -> Group {
  let items = self.items.iter().map(fn(item) { item.reverse() }).collect().rev()
  { items, }
}

///|
/// `all_compound_paths` returns all compound paths in this `Group`.
pub fn Group::all_compound_paths(self : Group) -> Array[CompoundPath] {
  self.items
  .iter()
  .flat_map(fn(item) { item.all_compound_paths().iter() })
  .collect()
}

///|
/// `all_paths` returns all `Path`s in this `Group`.
pub fn Group::all_paths(self : Group) -> Array[Path] {
  self.items.iter().flat_map(fn(item) { item.all_paths().iter() }).collect()
}

///|
/// `all_anchors` returns all `Anchor`s in this `Group`.
pub fn Group::all_anchors(self : Group) -> Array[Anchor] {
  self.items.iter().flat_map(fn(item) { item.all_anchors().iter() }).collect()
}

///|
/// `all_paths_and_compound_paths` returns all `Path`s and `CompoundPath`s in this `Group`.
pub fn Group::all_paths_and_compound_paths(self : Group) -> Array[Graphic] {
  self.items
  .iter()
  .flat_map(fn(item) { item.all_paths_and_compound_paths().iter() })
  .collect()
}

///|
/// `has_style` returns true if this `Group` has either a stroke or a fill.
pub fn Group::has_style(self : Group) -> Bool {
  Graphic::some(self.items, Graphic::has_style)
}

///|
/// `with_fill` returns a new `Group` with the provided fill applied.
pub fn Group::with_fill(self : Group, fill : Fill?) -> Group {
  { items: self.items.map(fn(item) { item.with_fill(fill) }) }
}

///|
/// `remove_fill` removes a fill style from this `Group`.
pub fn Group::remove_fill(self : Group) -> Group {
  { items: self.items.map(fn(item) { item.remove_fill() }) }
}

///|
/// `with_stroke` returns a new `Group` with the provided stroke applied.
pub fn Group::with_stroke(self : Group, stroke : Stroke?) -> Group {
  { items: self.items.map(fn(item) { item.with_stroke(stroke) }) }
}

///|
/// `remove_stroke` removes a stroke style from this `Group`.
pub fn Group::remove_stroke(self : Group) -> Group {
  { items: self.items.map(fn(item) { item.remove_stroke() }) }
}

///|
/// `with_style` returns a new `Group` with the provided fill and stroke applied.
pub fn Group::with_style(self : Group, fill? : Fill, stroke? : Stroke) -> Group {
  { items: self.items.map(fn(item) { item.with_style(fill?, stroke?) }) }
}

///|
/// `copy_style` copies the fill and stroke style from `graphic`.
pub fn Group::copy_style(self : Group, graphic : Graphic) -> Group {
  { items: self.items.map(fn(item) { item.copy_style(graphic) }) }
}

///|
/// `scale_stroke` scales the stroke width of this `Group` by `scale_factor`.
pub fn Group::scale_stroke(self : Group, scale_factor : Double) -> Group {
  { items: self.items.map(fn(item) { item.scale_stroke(scale_factor) }) }
}

///|
/// `first_styled` returns the first `Path` or `CompoundPath` in this `Group`
/// that has either a fill or a stroke, or `None`.
pub fn Group::first_styled(self : Group) -> Graphic? {
  let found = self.items
    .iter()
    .flat_map(fn(item) { item.first_styled().iter() })
    .collect()
  match found.length() {
    0 => None
    _ => Some(found[0])
  }
}

///|
/// `contains_point` returns true if this `Group` contains `point`.
pub fn Group::contains_point(self : Group, point : Vec2) -> Bool {
  Graphic::some(self.items, Graphic::contains_point(point))
}

///|
/// `style_contains_point` returns true if this `Group`'s style contains `point`.
pub fn Group::style_contains_point(self : Group, point : Vec2) -> Bool {
  Graphic::some(self.items, Graphic::style_contains_point(point))
}

///|
/// `first_fill` returns the first fill from this `Group`.
pub fn Group::first_fill(self : Group) -> Fill? {
  let found = self.items
    .iter()
    .flat_map(fn(item) { item.first_fill().iter() })
    .collect()
  match found.length() {
    0 => None
    _ => Some(found[0])
  }
}

///|
/// `first_stroke` returns the first stroke from this `Group`.
pub fn Group::first_stroke(self : Group) -> Stroke? {
  let found = self.items
    .iter()
    .flat_map(fn(item) { item.first_stroke().iter() })
    .collect()
  match found.length() {
    0 => None
    _ => Some(found[0])
  }
}

///|
/// `translate` translates a `Group` by `v`.
pub fn Group::translate(self : Group, v : Vec2) -> Group {
  let affine_matrix = AffineMatrix::from_translation(v)
  self.affine_transform(affine_matrix)
}

///|
/// `scale` scales a `Group` by `v`.
pub fn Group::scale(self : Group, v : Vec2) -> Group {
  let affine_matrix = AffineMatrix::from_scale(v)
  self.affine_transform(affine_matrix)
}

///|
/// `rotate` rotates a `Group` clockwise by `angle` in degrees.
pub fn Group::rotate(self : Group, angle : Double) -> Group {
  let affine_matrix = AffineMatrix::from_rotation(angle)
  self.affine_transform(affine_matrix)
}
