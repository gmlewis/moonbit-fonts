/// Graphic represents a drawable graphic element.
pub(all) enum Graphic {
  CompoundPath(CompoundPath)
  Group(Group)
  Path(Path)
}

/// clone returns a new copy of Graphic.
pub fn clone(self : Graphic) -> Graphic {
  match self {
    CompoundPath(compound_path) => CompoundPath(compound_path.clone())
    Group(group) => Group(group.clone())
    Path(path) => Path(path.clone())
  }
}

/// affine_transform transforms this graphic by `affine_matrix`.
pub fn affine_transform(
  self : Graphic,
  affine_matrix : AffineMatrix
) -> Graphic {
  match self {
    CompoundPath(compound_path) =>
      CompoundPath(compound_path.affine_transform(affine_matrix))
    Group(group) => Group(group.affine_transform(affine_matrix))
    Path(path) => Path(path.affine_transform(affine_matrix))
  }
}

/// affine_transform_without_translation transforms this graphic by `affine_matrix`
/// without affecting the translation.
pub fn affine_transform_without_translation(
  self : Graphic,
  affine_matrix : AffineMatrix
) -> Graphic {
  match self {
    CompoundPath(compound_path) =>
      CompoundPath(
        compound_path.affine_transform_without_translation(affine_matrix),
      )
    Group(group) =>
      Group(group.affine_transform_without_translation(affine_matrix))
    Path(path) => Path(path.affine_transform_without_translation(affine_matrix))
  }
}

/// Graphic::loose_bounding_box returns an approximate bounding box for all items.
/// It may not be the smallest possible bounding box, but is cheaper to compute.
pub fn Graphic::loose_bounding_box(items : Array[Graphic]) -> BoundingBox {
  if items.length() == 0 {
    return BoundingBox::new()
  }

  // Initialize bbox with the first item's bounding box
  let mut bbox = match items[0] {
    CompoundPath(compound_path) => compound_path.loose_bounding_box()
    Group(group) => group.loose_bounding_box()
    Path(path) => path.loose_bounding_box()
  }

  // Expand bbox to include all other items
  for i in 0..<items.length() {
    match items[i] {
      CompoundPath(compound_path) => {
        let item_bbox = compound_path.loose_bounding_box()
        ignore(bbox.expand_to_include_bounding_box(item_bbox))
      }
      Group(group) => {
        let item_bbox = group.loose_bounding_box()
        ignore(bbox.expand_to_include_bounding_box(item_bbox))
      }
      Path(path) => {
        let item_bbox = path.loose_bounding_box()
        ignore(bbox.expand_to_include_bounding_box(item_bbox))
      }
    }
  }
  bbox
}

/// Graphic::bounding_box returns the bounding box for all items.
pub fn Graphic::bounding_box(items : Array[Graphic]) -> BoundingBox {
  if items.length() == 0 {
    return BoundingBox::new()
  }

  // Initialize bbox with the first item's bounding box
  let mut bbox = match items[0] {
    CompoundPath(compound_path) => compound_path.bounding_box()
    Group(group) => group.bounding_box()
    Path(path) => path.bounding_box()
  }

  // Expand bbox to include all other items
  for i in 0..<items.length() {
    match items[i] {
      CompoundPath(compound_path) => {
        let item_bbox = compound_path.bounding_box()
        ignore(bbox.expand_to_include_bounding_box(item_bbox))
      }
      Group(group) => {
        let item_bbox = group.bounding_box()
        ignore(bbox.expand_to_include_bounding_box(item_bbox))
      }
      Path(path) => {
        let item_bbox = path.bounding_box()
        ignore(bbox.expand_to_include_bounding_box(item_bbox))
      }
    }
  }
  bbox
}

/// Graphic::every returns true if all tests of `func` are true.
pub fn Graphic::every(items : Array[Graphic], func : (Graphic) -> Bool) -> Bool {
  for i in 0..<items.length() {
    if not(func(items[i])) {
      return false
    }
  }
  true
}

/// Graphic::some returns true if any calls to `func` are true.
pub fn Graphic::some(items : Array[Graphic], func : (Graphic) -> Bool) -> Bool {
  for i in 0..<items.length() {
    if func(items[i]) {
      return true
    }
  }
  false
}

/// Graphic::is_contained_by_bounding_box returns a function that tests
/// if a graphic is contained by the box.
pub fn Graphic::is_contained_by_bounding_box(
  box : BoundingBox
) -> (Graphic) -> Bool {
  fn(graphic) {
    match graphic {
      CompoundPath(compound_path) =>
        compound_path.is_contained_by_bounding_box(box)
      Group(group) => group.is_contained_by_bounding_box(box)
      Path(path) => path.is_contained_by_bounding_box(box)
    }
  }
}

/// Graphic::is_intersected_by_bounding_box returns a function that tests
/// if a graphic is intersected by the box.
pub fn Graphic::is_intersected_by_bounding_box(
  box : BoundingBox
) -> (Graphic) -> Bool {
  fn(graphic) {
    match graphic {
      CompoundPath(compound_path) =>
        compound_path.is_intersected_by_bounding_box(box)
      Group(group) => group.is_intersected_by_bounding_box(box)
      Path(path) => path.is_intersected_by_bounding_box(box)
    }
  }
}

/// Graphic::is_overlapped_by_bounding_box returns a function that tests
/// if a graphic is overlapped by the box.
pub fn Graphic::is_overlapped_by_bounding_box(
  box : BoundingBox
) -> (Graphic) -> Bool {
  fn(graphic) {
    match graphic {
      CompoundPath(compound_path) =>
        compound_path.is_overlapped_by_bounding_box(box)
      Group(group) => group.is_overlapped_by_bounding_box(box)
      Path(path) => path.is_overlapped_by_bounding_box(box)
    }
  }
}

/// closest_point returns the closest Anchor to `point` that lies on this Graphic
/// or None.
pub fn closest_point(
  self : Graphic,
  point : Vec2,
  area_of_interest : BoundingBox?
) -> Anchor? {
  match self {
    CompoundPath(compound_path) =>
      compound_path.closest_point(point, area_of_interest)
    Group(group) => group.closest_point(point, area_of_interest)
    Path(path) => path.closest_point(point, area_of_interest)
  }
}
