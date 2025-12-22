///|
/// `Graphic` represents a drawable graphic element.
pub(all) enum Graphic {
  CompoundPath(CompoundPath)
  Group(Group)
  Path(Path)
} derive(Show)

///|
/// `op_add` allows composing two `Graphic`s into a `Group` using the `+` operator.
pub impl Add for Graphic with add(self, other) {
  let items = match (self, other) {
    (Group(g1), Group(g2)) => g1.items + g2.items
    (Group(g1), _) => g1.items + [other]
    (_, Group(g2)) => [self] + g2.items
    _ => [self, other]
  }
  Group({ items, })
}

///|
/// `clone` returns a new copy of `Graphic`.
pub fn Graphic::clone(self : Graphic) -> Graphic {
  match self {
    CompoundPath(compound_path) => CompoundPath(compound_path.clone())
    Group(group) => Group(group.clone())
    Path(path) => Path(path.clone())
  }
}

///|
/// `affine_transform` transforms this graphic by `affine_matrix`.
pub fn Graphic::affine_transform(
  self : Graphic,
  affine_matrix : AffineMatrix,
) -> Graphic {
  match self {
    CompoundPath(compound_path) =>
      CompoundPath(compound_path.affine_transform(affine_matrix))
    Group(group) => Group(group.affine_transform(affine_matrix))
    Path(path) => Path(path.affine_transform(affine_matrix))
  }
}

///|
/// `transform` provides a convenient API for a common task.
pub fn Graphic::transform(
  self : Graphic,
  position? : Vec2 = vec2(0, 0),
  rotation? : Double = 0,
  scale? : Vec2 = vec2(1, 1),
  skew? : Double = 0,
  origin? : Vec2 = vec2(0, 0),
) -> Graphic {
  let affine_matrix = AffineMatrix::from_transform(
    Transform::new(position~, rotation~, scale~, skew~, origin~),
  )
  self.affine_transform(affine_matrix)
}

///|
/// `affine_transform_without_translation` transforms this graphic by `affine_matrix`
/// without affecting the translation.
pub fn Graphic::affine_transform_without_translation(
  self : Graphic,
  affine_matrix : AffineMatrix,
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

///|
/// `loose_bounding_box` returns an approximate bounding box for all items.
/// It may not be the smallest possible bounding box, but is cheaper to compute.
pub fn Graphic::loose_bounding_box(self : Graphic) -> BoundingBox? {
  match self {
    CompoundPath(compound_path) => compound_path.bounding_box()
    Group(group) => group.bounding_box()
    Path(path) => path.bounding_box()
  }
}

///|
/// `bounding_box` returns the bounding box for this `Graphic`.
pub fn Graphic::bounding_box(self : Graphic) -> BoundingBox? {
  match self {
    CompoundPath(compound_path) => compound_path.bounding_box()
    Group(group) => group.bounding_box()
    Path(path) => path.bounding_box()
  }
}

///|
/// `Graphic::every` returns true if all tests of `func` are true.
pub fn Graphic::every(items : Array[Graphic], func : (Graphic) -> Bool) -> Bool {
  for item in items {
    if not(func(item)) {
      return false
    }
  }
  true
}

///|
/// `Graphic::some` returns true if any calls to `func` are true.
pub fn Graphic::some(items : Array[Graphic], func : (Graphic) -> Bool) -> Bool {
  for item in items {
    if func(item) {
      return true
    }
  }
  false
}

///|
/// `Graphic::is_contained_by_bounding_box` returns a function that tests
/// if a graphic is contained by the box.
pub fn Graphic::is_contained_by_bounding_box(
  box : BoundingBox,
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

///|
/// `Graphic::is_intersected_by_bounding_box` returns a function that tests
/// if a graphic is intersected by the box.
pub fn Graphic::is_intersected_by_bounding_box(
  box : BoundingBox,
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

///|
/// `Graphic::is_overlapped_by_bounding_box` returns a function that tests
/// if a graphic is overlapped by the box.
pub fn Graphic::is_overlapped_by_bounding_box(
  box : BoundingBox,
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

///|
/// `closest_point` returns the closest `Anchor` to `point` that lies on this `Graphic`
/// or `None`.
pub fn Graphic::closest_point(
  self : Graphic,
  point : Vec2,
  area_of_interest : BoundingBox?,
) -> Anchor? {
  match self {
    CompoundPath(compound_path) =>
      compound_path.closest_point(point, area_of_interest)
    Group(group) => group.closest_point(point, area_of_interest)
    Path(path) => path.closest_point(point, area_of_interest)
  }
}

///|
/// `primitives` returns an array of primitives.
pub fn Graphic::primitives(self : Graphic) -> Array[Graphic] {
  match self {
    CompoundPath(compound_path) => compound_path.primitives()
    Group(group) => group.primitives()
    Path(path) => path.primitives()
  }
}

///|
/// `reverse` reverses this `Graphic`.
pub fn Graphic::reverse(self : Graphic) -> Graphic {
  match self {
    CompoundPath(compound_path) => CompoundPath(compound_path.reverse())
    Group(group) => Group(group.reverse())
    Path(path) => Path(path.reverse())
  }
}

///|
/// `all_compound_paths` returns all `CompoundPath`s in this `Graphic`.
pub fn Graphic::all_compound_paths(self : Graphic) -> Array[CompoundPath] {
  match self {
    CompoundPath(compound_path) => [compound_path]
    Group(group) => group.all_compound_paths()
    Path(_path) => []
  }
}

///|
/// `all_paths` returns all `Path`s in this `Graphic`.
pub fn Graphic::all_paths(self : Graphic) -> Array[Path] {
  match self {
    CompoundPath(path) => path.paths
    Group(group) => group.all_paths()
    Path(path) => [path]
  }
}

///|
/// `all_anchors` returns all `Anchor`s in this `Graphic`.
pub fn Graphic::all_anchors(self : Graphic) -> Array[Anchor] {
  match self {
    CompoundPath(path) => path.all_anchors()
    Group(group) => group.all_anchors()
    Path(path) => path.anchors
  }
}

///|
/// `all_paths_and_compound_paths` returns all `Path`s and `CompoundPath`s in this `Graphic`.
pub fn Graphic::all_paths_and_compound_paths(self : Graphic) -> Array[Graphic] {
  match self {
    CompoundPath(_path) => [self]
    Group(group) => group.all_paths_and_compound_paths()
    Path(_path) => [self]
  }
}

///|
/// `has_style` returns true if this `Graphic` has either a stroke or a fill.
pub fn Graphic::has_style(self : Graphic) -> Bool {
  match self {
    CompoundPath(path) => path.has_style()
    Group(group) => group.has_style()
    Path(path) => path.has_style()
  }
}

///|
/// `with_fill` returns a new `Graphic` with the provided fill applied.
pub fn Graphic::with_fill(self : Graphic, fill : Fill?) -> Graphic {
  match self {
    CompoundPath(path) => CompoundPath(path.with_fill(fill))
    Group(group) => Group(group.with_fill(fill))
    Path(path) => Path(path.with_fill(fill))
  }
}

///|
/// `remove_fill` removes a fill style from this `Graphic`, returning a new `Graphic`.
pub fn Graphic::remove_fill(self : Graphic) -> Graphic {
  match self {
    CompoundPath(path) => CompoundPath(path.remove_fill())
    Group(group) => Group(group.remove_fill())
    Path(path) => Path(path.remove_fill())
  }
}

///|
/// `with_stroke` returns a new `Graphic` with the provided stroke applied.
pub fn Graphic::with_stroke(self : Graphic, stroke : Stroke?) -> Graphic {
  match self {
    CompoundPath(path) => CompoundPath(path.with_stroke(stroke))
    Group(group) => Group(group.with_stroke(stroke))
    Path(path) => Path(path.with_stroke(stroke))
  }
}

///|
/// `remove_stroke` removes a stroke style from this `Graphic`, returning a new `Graphic`.
pub fn Graphic::remove_stroke(self : Graphic) -> Graphic {
  match self {
    CompoundPath(path) => CompoundPath(path.remove_stroke())
    Group(group) => Group(group.remove_stroke())
    Path(path) => Path(path.remove_stroke())
  }
}

///|
/// `with_style` returns a new `Graphic` with the provided fill and stroke applied.
pub fn Graphic::with_style(
  self : Graphic,
  fill? : Fill,
  stroke? : Stroke,
) -> Graphic {
  match self {
    CompoundPath(path) => CompoundPath(path.with_style(fill?, stroke?))
    Group(group) => Group(group.with_style(fill?, stroke?))
    Path(path) => Path(path.with_style(fill?, stroke?))
  }
}

///|
/// `copy_style` copies the fill and stroke style from `graphic`, returning a new graphic.
pub fn Graphic::copy_style(self : Graphic, graphic : Graphic) -> Graphic {
  match self {
    CompoundPath(path) => CompoundPath(path.copy_style(graphic))
    Group(group) => Group(group.copy_style(graphic))
    Path(path) => Path(path.copy_style(graphic))
  }
}

///|
/// `scale_stroke` scales the stroke width of this `Graphic` by `scale_factor`, returning a new `Graphic`.
pub fn Graphic::scale_stroke(self : Graphic, scale_factor : Double) -> Graphic {
  match self {
    CompoundPath(path) => CompoundPath(path.scale_stroke(scale_factor))
    Group(group) => Group(group.scale_stroke(scale_factor))
    Path(path) => Path(path.scale_stroke(scale_factor))
  }
}

///|
/// `first_styled` returns the first `Path` or `CompoundPath` in this `Graphic`
/// that has either a fill or a stroke, or `None`.
pub fn Graphic::first_styled(self : Graphic) -> Graphic? {
  match self {
    CompoundPath(path) => path.first_styled()
    Group(group) => group.first_styled()
    Path(path) => path.first_styled()
  }
}

///|
/// `Graphic::contains_point` returns a function that returns true if this
/// `Graphic` contains `point`.
pub fn Graphic::contains_point(point : Vec2) -> (Graphic) -> Bool {
  fn(graphic) {
    match graphic {
      CompoundPath(path) => path.contains_point(point)
      Group(group) => group.contains_point(point)
      Path(path) => path.contains_point(point)
    }
  }
}

///|
/// `Graphic::style_contains_point` returns a function that returns true if this
/// `Graphic`'s style contains `point`.
pub fn Graphic::style_contains_point(point : Vec2) -> (Graphic) -> Bool {
  fn(graphic) {
    match graphic {
      CompoundPath(path) => path.style_contains_point(point)
      Group(group) => group.style_contains_point(point)
      Path(path) => path.style_contains_point(point)
    }
  }
}

///|
/// `first_fill` returns the first fill from this `Graphic`.
pub fn Graphic::first_fill(self : Graphic) -> Fill? {
  match self {
    CompoundPath(path) => path.fill
    Group(group) => group.first_fill()
    Path(path) => path.fill
  }
}

///|
/// `first_stroke` returns the first stroke from this `Graphic`.
pub fn Graphic::first_stroke(self : Graphic) -> Stroke? {
  match self {
    CompoundPath(path) => path.stroke
    Group(group) => group.first_stroke()
    Path(path) => path.stroke
  }
}

///|
/// `translate` translates a `Graphic` by `v`.
pub fn Graphic::translate(self : Graphic, v : Vec2) -> Graphic {
  match self {
    CompoundPath(path) => path.translate(v).as_graphic()
    Group(group) => group.translate(v).as_graphic()
    Path(path) => path.translate(v).as_graphic()
  }
}

///|
/// `scale` scales a `Graphic` by `v`.
pub fn Graphic::scale(self : Graphic, v : Vec2) -> Graphic {
  match self {
    CompoundPath(path) => path.scale(v).as_graphic()
    Group(group) => group.scale(v).as_graphic()
    Path(path) => path.scale(v).as_graphic()
  }
}

///|
/// `rotate` rotates a `Graphic` clockwise by `angle` in degrees.
pub fn Graphic::rotate(self : Graphic, angle : Double) -> Graphic {
  match self {
    CompoundPath(path) => path.rotate(angle).as_graphic()
    Group(group) => group.rotate(angle).as_graphic()
    Path(path) => path.rotate(angle).as_graphic()
  }
}

///|
/// `scale_to_fit` scales a `Graphic` to fit inside `box` while preserving aspect ratio.
pub fn Graphic::scale_to_fit(
  self : Graphic,
  box : BoundingBox,
  anchor? : Alignment = Center,
) -> Graphic {
  self.fit_to(box, anchor~)
}

///|
/// `scale_to_fill` scales a `Graphic` to completely fill `box`, ignoring aspect ratio.
pub fn Graphic::scale_to_fill(self : Graphic, box : BoundingBox) -> Graphic {
  let bbox = match self.bounding_box() {
    None => return self
    Some(bbox) => bbox
  }
  let wscale = box.width() / bbox.width()
  let hscale = box.height() / bbox.height()
  let scale = vec2(wscale, hscale)
  let position = box.min - scale * bbox.min
  let transform = Transform::new(position~, scale~)
  let affine_matrix = AffineMatrix::from_transform(transform)
  self.clone().affine_transform(affine_matrix)
}

///|
/// `fit_to` scales and translates a `Graphic` to fit in `box`.
pub fn Graphic::fit_to(
  self : Graphic,
  box : BoundingBox,
  anchor? : Alignment = Center,
) -> Graphic {
  let bbox = match self.bounding_box() {
    None => return self
    Some(bbox) => bbox
  }
  if bbox == box {
    return self
  }
  let wscale = box.width() / bbox.width()
  let hscale = box.height() / bbox.height()
  let s = @cmp.minimum(wscale, hscale)
  let scale = vec2(s, s)

  // Calculate alignment offset
  let scaled_width = bbox.width() * s
  let scaled_height = bbox.height() * s
  let extra_width = box.width() - scaled_width
  let extra_height = box.height() - scaled_height
  let (offset_x, offset_y) = match anchor {
    Unchanged => (0.0, 0.0)
    TopLeft => (0.0, extra_height)
    TopCenter => (extra_width / 2.0, extra_height)
    TopRight => (extra_width, extra_height)
    CenterLeft => (0.0, extra_height / 2.0)
    Center => (extra_width / 2.0, extra_height / 2.0)
    CenterRight => (extra_width, extra_height / 2.0)
    BottomLeft => (0.0, 0.0)
    BottomCenter => (extra_width / 2.0, 0.0)
    BottomRight => (extra_width, 0.0)
    BaselineLeft => (0.0, 0.0)
    BaselineCenter => (extra_width / 2.0, 0.0)
    BaselineRight => (extra_width, 0.0)
    RatioXY(rx, ry) => (extra_width * rx, extra_height * ry)
  }
  let offset = vec2(offset_x, offset_y)
  let position = box.min - scale * bbox.min + offset
  let transform = Transform::new(position~, scale~)
  let affine_matrix = AffineMatrix::from_transform(transform)
  self.clone().affine_transform(affine_matrix)
}

///|
/// `with_margin` returns a new `Graphic` (a `Group`) that includes `self` plus
/// unstyled `Path` elements that expand the bounding box by the requested
/// margin amounts on each side.
pub fn Graphic::with_margin(
  self : Graphic,
  top? : Double,
  right? : Double,
  bottom? : Double,
  left? : Double,
) -> Graphic {
  let bbox = match self.bounding_box() {
    None => return self
    Some(bbox) => bbox
  }
  let t = match top {
    Some(v) => v
    None => 0.0
  }
  let r = match right {
    Some(v) => v
    None => 0.0
  }
  let b = match bottom {
    Some(v) => v
    None => 0.0
  }
  let l = match left {
    Some(v) => v
    None => 0.0
  }
  let p1 = vec2(bbox.min.x - l, bbox.min.y - b)
  let p2 = vec2(bbox.max.x + r, bbox.min.y - b)
  let p3 = vec2(bbox.max.x + r, bbox.max.y + t)
  let p4 = vec2(bbox.min.x - l, bbox.max.y + t)
  let margin_path = Path::from_points([p1, p2, p3, p4], closed=true)
  Group({ items: [self, Path(margin_path)] })
}

///|
/// `with_background` returns a new `Graphic` (a `Group`) that includes a solid
/// background rectangle of the provided `color` behind the current graphic.
/// The background rectangle is sized to match the current bounding box.
pub fn Graphic::with_background(self : Graphic, color : Color) -> Graphic {
  let bbox = match self.bounding_box() {
    None => return self
    Some(bbox) => bbox
  }
  let background = Path::from_points(
      [
        vec2(bbox.min.x, bbox.min.y),
        vec2(bbox.max.x, bbox.min.y),
        vec2(bbox.max.x, bbox.max.y),
        vec2(bbox.min.x, bbox.max.y),
      ],
      closed=true,
    )
    .as_graphic()
    .with_style(fill=color.as_fill())
  Group({ items: [background, self] })
}

///|
/// `to_profiles` extracts profiles (outer and holes) from a `Graphic`.
/// Returns an array of (outer_polygon, holes_polygons).
pub fn Graphic::to_profiles(
  self : Graphic,
  curve_segments : Int,
) -> Array[(Array[Vec2], Array[Array[Vec2]])] {
  match self {
    Path(path) => {
      let polygon = path.to_polygon(curve_segments)
      if polygon.length() >= 3 {
        [(polygon, [])]
      } else {
        []
      }
    }
    CompoundPath(compound_path) => {
      let paths = compound_path.paths
      if paths.length() == 0 {
        return []
      }
      let outer = paths[0].to_polygon(curve_segments)
      if outer.length() < 3 {
        return []
      }
      let holes : Array[Array[Vec2]] = []
      for i in 1..<paths.length() {
        let poly = paths[i].to_polygon(curve_segments)
        if poly.length() >= 3 {
          holes.push(poly)
        }
      }
      [(outer, holes)]
    }
    Group(group) =>
      group.items
      .iter()
      .flat_map(fn(item) { item.to_profiles(curve_segments).iter() })
      .collect()
  }
}

///|
/// `to_profiles_tuples` returns profiles with points as simple tuples for downstream consumers.
pub fn Graphic::to_profiles_tuples(
  self : Graphic,
  curve_segments : Int,
) -> Array[(Array[(Double, Double)], Array[Array[(Double, Double)]])] {
  let profiles = self.to_profiles(curve_segments)
  profiles.map(fn(p : (Array[Vec2], Array[Array[Vec2]])) {
    let outer = p.0.map(fn(pt : Vec2) { pt.to_tuple() })
    let holes = p.1.map(fn(h : Array[Vec2]) {
      h.map(fn(pt : Vec2) { pt.to_tuple() })
    })
    (outer, holes)
  })
}

///|
pub impl ToJson for Graphic with to_json(self) {
  match self {
    CompoundPath(path) => path.to_json()
    Group(group) => group.to_json()
    Path(path) => path.to_json()
  }
}

///|
pub impl @json.FromJson for Graphic with from_json(json, path) {
  match json.as_object() {
    _ =>
      raise @json.JsonDecodeError(
        (path, "Graphic::from_json: not implemented yet"),
      )
  }
}
