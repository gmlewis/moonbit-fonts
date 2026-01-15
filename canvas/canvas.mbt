///|
using @geom {vec2}

///|
using @draw {type CompoundPath, type Fill, type Graphic, type Path, type Stroke}

///|
// context of an HTML5 canvas

///|
#external
type CanvasCtx

///|
/// `CanvasCtx::from_graphic` renders a `Graphic` to an HTML5 canvas using its native API.
/// Note that if the design was created with `Y` being "up", then it
/// must be flipped to render properly in the canvas.
pub fn CanvasCtx::from_graphic(
  self : CanvasCtx,
  g : Graphic,
  y_up? : Bool = true,
) -> Unit {
  let mut bbox = match g.bounding_box() {
    Some(box) => box
    _ => return
  }

  // flip design if necessary
  let mut g = g
  if y_up {
    let height = bbox.height()
    let transform = @geom.Transform::new(
      position=vec2(0, height),
      scale=vec2(1, -1),
    )
    let affine_matrix = @geom.AffineMatrix::from_transform(transform)
    g = g.clone().affine_transform(affine_matrix)
    bbox = g.bounding_box().unwrap()
  }

  //
  let paths = g.all_paths_and_compound_paths()
  for path in paths {
    match path {
      Path(path) => self.render_path(path)
      CompoundPath(path) => self.render_compound_path(path)
      _ => ()
    }
  }
}

///|
fn CanvasCtx::render_path(self : CanvasCtx, path : Path) -> Unit {
  self.render_paths([path], path.stroke, path.fill)
}

///|
fn CanvasCtx::render_compound_path(
  self : CanvasCtx,
  path : CompoundPath,
) -> Unit {
  self.render_paths(path.paths, path.stroke, path.fill)
}

///|
fn CanvasCtx::render_paths(
  self : CanvasCtx,
  paths : Array[Path],
  stroke : Stroke?,
  fill : Fill?,
) -> Unit {
  self.set_stroke(stroke)
  self.set_fill(fill)
  self.begin_path()
  for path in paths {
    self.canvas_commands(path)
  }
  if fill != None {
    self.fill()
  }
  if stroke != None {
    self.stroke()
  }
}

///|
fn CanvasCtx::canvas_commands(self : CanvasCtx, path : Path) -> Unit {
  if path.anchors.length() < 2 {
    return
  }
  for index, anchor in path.anchors {
    let pos = anchor.position
    if index == 0 {
      self.move_to(pos.x, pos.y)
      continue
    }
    let last_anchor = path.anchors[index - 1]
    let h1 = last_anchor.handle_out
    let h2 = anchor.handle_in
    if h1.is_zero() && h2.is_zero() {
      self.line_to(pos.x, pos.y)
    } else {
      let last_pos = last_anchor.position
      let p1 = h1 + last_pos
      let p2 = h2 + pos
      self.cubic_bezier_curve_to(p1.x, p1.y, p2.x, p2.y, pos.x, pos.y)
    }
  }
  if path.closed {
    let last_anchor = path.anchors[path.anchors.length() - 1]
    let anchor = path.anchors[0]
    let h1 = last_anchor.handle_out
    let h2 = anchor.handle_in
    if not(h1.is_zero()) || not(h2.is_zero()) {
      let last_pos = last_anchor.position
      let pos = anchor.position
      let p1 = h1 + last_pos
      let p2 = h2 + pos
      let pos = pos
      self.cubic_bezier_curve_to(p1.x, p1.y, p2.x, p2.y, pos.x, pos.y)
    }
    self.close_path()
  }
}

///|
fn CanvasCtx::set_stroke(self : CanvasCtx, stroke : Stroke?) -> Unit {
  match stroke {
    None => self.set_stroke_color(0, 0, 0, 0)
    Some(stroke) => {
      let c = stroke.color
      self.set_stroke_color(c.r, c.g, c.b, c.a)
      // TODO: stroke-dasharray
      // TODO: stroke-dashoffset
      self.set_line_cap(stroke.cap)
      self.set_line_join(stroke.join)
      self.set_miter_limit(stroke.miter_limit)
      self.set_line_width(stroke.width)
    }
  }
}

///|
fn CanvasCtx::set_line_cap(
  self : CanvasCtx,
  line_cap : @draw.StrokeCap,
) -> Unit {
  match line_cap {
    @draw.StrokeCap::Butt => self.set_line_cap_butt()
    @draw.StrokeCap::Round => self.set_line_cap_round()
    @draw.StrokeCap::Square => self.set_line_cap_square()
  }
}

///|
fn CanvasCtx::set_line_join(
  self : CanvasCtx,
  line_join : @draw.StrokeJoin,
) -> Unit {
  match line_join {
    @draw.StrokeJoin::Miter => self.set_line_join_miter()
    @draw.StrokeJoin::Round => self.set_line_join_round()
    @draw.StrokeJoin::Bevel => self.set_line_join_bevel()
  }
}

///|
fn CanvasCtx::set_fill(self : CanvasCtx, fill : Fill?) -> Unit {
  match fill {
    None => self.set_fill_color(0, 0, 0, 0)
    Some(fill) => {
      let c = fill.color
      self.set_fill_color(c.r, c.g, c.b, c.a)
    }
  }
}

///|
pub fn CanvasCtx::get_input_bytes(self : CanvasCtx) -> Array[Byte] {
  let length = self.get_input_length()
  if length <= 0 {
    return []
  }
  Array::makei(length, fn(i) { self.get_input_byte_at_offset(i) })
}
