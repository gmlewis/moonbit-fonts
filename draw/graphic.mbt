/// Graphic represents a drawable graphic element.
pub(all) enum Graphic {
  CompoundPath(CompoundPath)
  Group(Group)
  Path(Path)
} derive(Show)

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
pub fn Graphic::loose_bounding_box(items : Array[Graphic]) -> BoundingBox? {
  if items.length() == 0 {
    return None
  }
  let bbox = BoundingBox::max_reversed()

  // Expand bbox to include all other items
  for i in 0..<items.length() {
    match items[i] {
      CompoundPath(compound_path) => {
        let item_bbox = match compound_path.loose_bounding_box() {
          None => continue
          Some(bbox) => bbox
        }
        ignore(bbox.expand_to_include_bounding_box(item_bbox))
      }
      Group(group) => {
        let item_bbox = match group.loose_bounding_box() {
          None => continue
          Some(bbox) => bbox
        }
        ignore(bbox.expand_to_include_bounding_box(item_bbox))
      }
      Path(path) => {
        let item_bbox = match path.loose_bounding_box() {
          None => continue
          Some(bbox) => bbox
        }
        ignore(bbox.expand_to_include_bounding_box(item_bbox))
      }
    }
  }
  match bbox.is_inf() {
    true => None
    false => Some(bbox)
  }
}

/// Graphic::bounding_box returns the bounding box for all items.
pub fn Graphic::bounding_box(items : Array[Graphic]) -> BoundingBox? {
  if items.length() == 0 {
    return None
  }
  let bbox = BoundingBox::max_reversed()

  // Expand bbox to include all other items
  for i in 0..<items.length() {
    match items[i] {
      CompoundPath(compound_path) => {
        let item_bbox = match compound_path.bounding_box() {
          None => continue
          Some(bbox) => bbox
        }
        ignore(bbox.expand_to_include_bounding_box(item_bbox))
      }
      Group(group) => {
        let item_bbox = match group.bounding_box() {
          None => continue
          Some(bbox) => bbox
        }
        ignore(bbox.expand_to_include_bounding_box(item_bbox))
      }
      Path(path) => {
        let item_bbox = match path.bounding_box() {
          None => continue
          Some(bbox) => bbox
        }
        ignore(bbox.expand_to_include_bounding_box(item_bbox))
      }
    }
  }
  match bbox.is_inf() {
    true => None
    false => Some(bbox)
  }
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

/// primitives returns an array of primitives.
pub fn primitives(self : Graphic) -> Array[Graphic] {
  match self {
    CompoundPath(compound_path) => compound_path.primitives()
    Group(group) => group.primitives()
    Path(path) => path.primitives()
  }
}

/// reverse reverses this Graphic.
pub fn reverse(self : Graphic) -> Graphic {
  match self {
    CompoundPath(compound_path) => CompoundPath(compound_path.reverse())
    Group(group) => Group(group.reverse())
    Path(path) => Path(path.reverse())
  }
}

/// all_compound_paths returns all CompoundPaths in this Graphic.
pub fn all_compound_paths(self : Graphic) -> Array[CompoundPath] {
  match self {
    CompoundPath(compound_path) => [compound_path]
    Group(group) => group.all_compound_paths()
    Path(_path) => []
  }
}

/// all_paths returns all Paths in this Graphic.
pub fn all_paths(self : Graphic) -> Array[Path] {
  match self {
    CompoundPath(path) => path.paths
    Group(group) => group.all_paths()
    Path(path) => [path]
  }
}

/// all_anchors returns all Anchors in this Graphic.
pub fn all_anchors(self : Graphic) -> Array[Anchor] {
  match self {
    CompoundPath(path) => path.all_anchors()
    Group(group) => group.all_anchors()
    Path(path) => path.anchors
  }
}

/// all_paths_and_compound_paths returns all Paths and CompoundPaths in this Graphic.
pub fn all_paths_and_compound_paths(self : Graphic) -> Array[Graphic] {
  match self {
    CompoundPath(_path) => [self]
    Group(group) => group.all_paths_and_compound_paths()
    Path(_path) => [self]
  }
}

/// has_style returns true if this Graphic has either a stroke or a fill.
pub fn has_style(self : Graphic) -> Bool {
  match self {
    CompoundPath(path) => path.has_style()
    Group(group) => group.has_style()
    Path(path) => path.has_style()
  }
}

/// assign_fill assigns a fill to this Graphic.
pub fn assign_fill(self : Graphic, fill : Fill?) -> Graphic {
  match self {
    CompoundPath(path) => ignore(path.assign_fill(fill))
    Group(group) => ignore(group.assign_fill(fill))
    Path(path) => ignore(path.assign_fill(fill))
  }
  self
}

/// remove_fill a fill style from this Graphic.
pub fn remove_fill(self : Graphic) -> Graphic {
  match self {
    CompoundPath(path) => ignore(path.remove_fill())
    Group(group) => ignore(group.remove_fill())
    Path(path) => ignore(path.remove_fill())
  }
  self
}

/// assign_stroke assigns a stroke to this Graphic.
pub fn assign_stroke(self : Graphic, stroke : Stroke?) -> Graphic {
  match self {
    CompoundPath(path) => ignore(path.assign_stroke(stroke))
    Group(group) => ignore(group.assign_stroke(stroke))
    Path(path) => ignore(path.assign_stroke(stroke))
  }
  self
}

/// remove_stroke a stroke style from this Graphic.
pub fn remove_stroke(self : Graphic) -> Graphic {
  match self {
    CompoundPath(path) => ignore(path.remove_stroke())
    Group(group) => ignore(group.remove_stroke())
    Path(path) => ignore(path.remove_stroke())
  }
  self
}

/// assign_style assigns a fill and stroke style to this Graphic.
pub fn assign_style(self : Graphic, fill : Fill?, stroke : Stroke?) -> Graphic {
  match self {
    CompoundPath(path) => ignore(path.assign_style(fill, stroke))
    Group(group) => ignore(group.assign_style(fill, stroke))
    Path(path) => ignore(path.assign_style(fill, stroke))
  }
  self
}

/// copy_style copies the fill and stroke style from `graphic`.
pub fn copy_style(self : Graphic, graphic : Graphic) -> Graphic {
  match self {
    CompoundPath(path) => ignore(path.copy_style(graphic))
    Group(group) => ignore(group.copy_style(graphic))
    Path(path) => ignore(path.copy_style(graphic))
  }
  self
}

/// scale_stroke scales the stroke width of this Graphic by `scale_factor`.
pub fn scale_stroke(self : Graphic, scale_factor : Double) -> Graphic {
  match self {
    CompoundPath(path) => ignore(path.scale_stroke(scale_factor))
    Group(group) => ignore(group.scale_stroke(scale_factor))
    Path(path) => ignore(path.scale_stroke(scale_factor))
  }
  self
}

/// first_styled returns the first Path or CompoundPath in this Graphic
/// that has either a fill or a stroke, or None.
pub fn first_styled(self : Graphic) -> Graphic? {
  match self {
    CompoundPath(path) => path.first_styled()
    Group(group) => group.first_styled()
    Path(path) => path.first_styled()
  }
}

/// Graphic::contains_point returns a function that returns true if this
/// Graphic contains `point`.
pub fn Graphic::contains_point(point : Vec2) -> (Graphic) -> Bool {
  fn(graphic) {
    match graphic {
      CompoundPath(path) => path.contains_point(point)
      Group(group) => group.contains_point(point)
      Path(path) => path.contains_point(point)
    }
  }
}

/// Graphic::style_contains_point returns a function that returns true if this
/// Graphic's style contains `point`.
pub fn Graphic::style_contains_point(point : Vec2) -> (Graphic) -> Bool {
  fn(graphic) {
    match graphic {
      CompoundPath(path) => path.style_contains_point(point)
      Group(group) => group.style_contains_point(point)
      Path(path) => path.style_contains_point(point)
    }
  }
}

/// first_fill returns the first fill from this Graphic.
pub fn first_fill(self : Graphic) -> Fill? {
  match self {
    CompoundPath(path) => path.fill
    Group(group) => group.first_fill()
    Path(path) => path.fill
  }
}

/// first_stroke returns the first stroke from this Graphic.
pub fn first_stroke(self : Graphic) -> Stroke? {
  match self {
    CompoundPath(path) => path.stroke
    Group(group) => group.first_stroke()
    Path(path) => path.stroke
  }
}
