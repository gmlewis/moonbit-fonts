///|
/// CompoundPath represents one or more paths that typically make up a font glyph.
pub(all) struct CompoundPath {
  mut paths : Array[Path]
  mut fill : Fill?
  mut stroke : Stroke?
} derive(Show, FromJson, ToJson)

///|
/// CompoundPath::new creates a new CompoundPath.
pub fn CompoundPath::new(
  paths? : Array[Path] = [],
  fill? : Fill,
  stroke? : Stroke,
) -> CompoundPath {
  { paths, fill, stroke }
}

///|
/// as_graphic returns a CompoundPath as a Graphic.
pub fn CompoundPath::as_graphic(self : CompoundPath) -> Graphic {
  CompoundPath(self)
}

///|
/// op_get is a convenience function.
pub fn CompoundPath::op_get(self : CompoundPath, index : Int) -> Path {
  self.paths[index]
}

///|
/// op_set is a convenience function.
pub fn CompoundPath::op_set(
  self : CompoundPath,
  index : Int,
  path : Path,
) -> Unit {
  self.paths[index] = path
}

///|
/// clone makes a new copy of this CompoundPath.
pub fn CompoundPath::clone(self : CompoundPath) -> CompoundPath {
  let paths = self.paths.map(fn(path) { path.clone() })
  let fill = clone_option(self.fill)
  let stroke = clone_option(self.stroke)
  { paths, fill, stroke }
}

///|
/// affine_transform transforms this CompoundPath by `affine_matrix`.
pub fn CompoundPath::affine_transform(
  self : CompoundPath,
  affine_matrix : AffineMatrix,
) -> CompoundPath {
  {
    ..self,
    paths: self.paths.map(fn(path) { path.affine_transform(affine_matrix) }),
  }
}

///|
/// affine_transform_without_translation transforms this CompoundPath by `affine_matrix`
/// without affecting translation.
pub fn CompoundPath::affine_transform_without_translation(
  self : CompoundPath,
  affine_matrix : AffineMatrix,
) -> CompoundPath {
  {
    ..self,
    paths: self.paths.map(fn(path) {
      path.affine_transform_without_translation(affine_matrix)
    }),
  }
}

///|
/// transform provides a convenient API for a common task.
pub fn CompoundPath::transform(
  self : CompoundPath,
  position? : Vec2 = vec2(0, 0),
  rotation? : Double = 0,
  scale? : Vec2 = vec2(1, 1),
  skew? : Double = 0,
  origin? : Vec2 = vec2(0, 0),
) -> CompoundPath {
  let affine_matrix = AffineMatrix::from_transform(
    Transform::new(position~, rotation~, scale~, skew~, origin~),
  )
  self.affine_transform(affine_matrix)
}

///|
/// with_fill returns a new CompoundPath with this fill applied.
pub fn CompoundPath::with_fill(
  self : CompoundPath,
  fill : Fill?,
) -> CompoundPath {
  { ..self, fill, }
}

///|
/// with_stroke returns a new CompoundPath with this stroke applied.
pub fn CompoundPath::with_stroke(
  self : CompoundPath,
  stroke : Stroke?,
) -> CompoundPath {
  { ..self, stroke, }
}

///|
/// with_style returns a new CompoundPath with this fill and stroke applied.
pub fn CompoundPath::with_style(
  self : CompoundPath,
  fill? : Fill,
  stroke? : Stroke,
) -> CompoundPath {
  { ..self, fill, stroke }
}

///|
/// bounding_box returns the smallest axis-aligned bounding box that contains
/// this CompoundPath or None.
pub fn CompoundPath::bounding_box(self : CompoundPath) -> BoundingBox? {
  let result = BoundingBox::max_reversed()
  for path in self.paths {
    let bbox = match path.bounding_box() {
      None => continue
      Some(bbox) => bbox
    }
    result.min.min(bbox.min)
    result.max.max(bbox.max)
  }
  match result.is_inf() {
    true => None
    false => Some(result)
  }
}

///|
/// closest_point returns the closest point to `point` that lies on this CompoundPath or None.
pub fn CompoundPath::closest_point(
  self : CompoundPath,
  point : Vec2,
  area_of_interest : BoundingBox?,
) -> Anchor? {
  let { paths, .. } = self
  match paths.length() {
    0 => return None
    1 => return paths[0].closest_point(point, area_of_interest)
    _ => ()
  }
  let mut closest_point = None
  let mut closest_distance = @double.infinity
  for path in paths {
    let pt = match path.closest_point(point, area_of_interest) {
      None => continue
      Some(pt) => pt
    }
    let distance = point.distance_squared(pt.position)
    if distance < closest_distance {
      closest_point = Some(pt)
      closest_distance = distance
    }
  }
  closest_point
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
/// contains_point returns true if this CompoundPath contains `point`.
pub fn CompoundPath::contains_point(
  _self : CompoundPath,
  _point : Vec2,
) -> Bool {
  false // TODO
}

///|
/// copy_style copies the fill and stroke from `graphic` and returns a new CompoundPath.
pub fn CompoundPath::copy_style(
  self : CompoundPath,
  graphic : Graphic,
) -> CompoundPath {
  let fill = graphic.first_fill()
  let stroke = graphic.first_stroke()
  { ..self, fill, stroke }
}

///|
/// first_styled returns this CompoundPath if it is styled or None.
pub fn CompoundPath::first_styled(self : CompoundPath) -> Graphic? {
  if self.has_style() {
    Some(CompoundPath(self))
  } else {
    None
  }
}

///|
/// has_style returns true if this CompoundPath has fill or stroke.
pub fn CompoundPath::has_style(self : CompoundPath) -> Bool {
  self.fill != None || self.stroke != None
}

///|
/// is_contained_by_bounding_box returns true if no part of this CompoundPath
/// lies beyond its min or max.
pub fn CompoundPath::is_contained_by_bounding_box(
  self : CompoundPath,
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
/// is_intersected_by_bounding_box returns true if part of this CompoundPath crosses
/// the boundary between inside and outside of `box`.
pub fn CompoundPath::is_intersected_by_bounding_box(
  _self : CompoundPath,
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
/// that is inside both the CompoundPath and `box`.
pub fn CompoundPath::is_overlapped_by_bounding_box(
  self : CompoundPath,
  box : BoundingBox,
) -> Bool {
  self.is_contained_by_bounding_box(box) ||
  self.is_intersected_by_bounding_box(box)
}

///|
/// loose_bounding_box returns an approximate bounding box for this CompoundPath.
/// It may not be the smallest possible bounding box, but is cheaper to compute.
pub fn CompoundPath::loose_bounding_box(self : CompoundPath) -> BoundingBox? {
  let result = BoundingBox::max_reversed()
  for i in 0..<self.paths.length() {
    let bbox = match self.paths[i].loose_bounding_box() {
      None => continue
      Some(bbox) => bbox
    }
    result.min.min(bbox.min)
    result.max.max(bbox.max)
  }
  match result.is_inf() {
    true => None
    false => Some(result)
  }
}

///|
/// primitives returns a flattened array of Graphics primitives.
pub fn CompoundPath::primitives(self : CompoundPath) -> Array[Graphic] {
  [CompoundPath(self)]
}

///|
/// remove_fill returns a new CompoundPath without fill styling.
pub fn CompoundPath::remove_fill(self : CompoundPath) -> CompoundPath {
  { ..self, fill: None }
}

///|
/// remove_stroke returns a new CompoundPath without stroke styling.
pub fn CompoundPath::remove_stroke(self : CompoundPath) -> CompoundPath {
  { ..self, stroke: None }
}

///|
/// reverse returns a new CompoundPath with all paths reversed.
pub fn CompoundPath::reverse(self : CompoundPath) -> CompoundPath {
  let paths = self.paths.iter().map(fn(path) { path.reverse() }).collect().rev()
  { ..self, paths, }
}

///|
/// scale_stroke returns a new CompoundPath with the width of its stroke (if any) scaled by `scale_factor`.
pub fn CompoundPath::scale_stroke(
  self : CompoundPath,
  scale_factor : Double,
) -> CompoundPath {
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
/// style_contains_point returns true if this path's style contains `point`.
pub fn CompoundPath::style_contains_point(
  _self : CompoundPath,
  _point : Vec2,
) -> Bool {
  // TODO
  false
}

///|
/// all_anchors returns a flattened array of all anchors in this CompoundPath.
pub fn CompoundPath::all_anchors(self : CompoundPath) -> Array[Anchor] {
  self.paths.iter().flat_map(fn(path) { path.anchors.iter() }).collect()
}

///|
/// translate translates a CompoundPath by `v`.
pub fn CompoundPath::translate(self : CompoundPath, v : Vec2) -> CompoundPath {
  let affine_matrix = AffineMatrix::from_translation(v)
  self.affine_transform(affine_matrix)
}

///|
/// scale scales a CompoundPath by `v`.
pub fn CompoundPath::scale(self : CompoundPath, v : Vec2) -> CompoundPath {
  let affine_matrix = AffineMatrix::from_scale(v)
  self.affine_transform(affine_matrix)
}

///|
/// rotate rotates a CompoundPath clockwise by `angle` in degrees.
pub fn CompoundPath::rotate(
  self : CompoundPath,
  angle : Double,
) -> CompoundPath {
  let affine_matrix = AffineMatrix::from_rotation(angle)
  self.affine_transform(affine_matrix)
}
