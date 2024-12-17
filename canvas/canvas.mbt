///| from_graphics renders a Graphic to an HTML5 canvas using its native API.
/// Note that if the design was created with Y being "up", then it
/// must be flipped to render properly in the canvas.
pub fn from_graphic(self : CanvasCtx, g : Graphic, y_up~ : Bool = true) -> Unit {
  let mut bbox = match g.bounding_box() {
    Some(box) => box
    _ => return
  }

  // flip design if necessary
  let mut g = g
  if y_up {
    let height = bbox.height()
    let transform = @draw.Transform::new(
      position=vec2(0, height),
      scale=vec2(1, -1),
    )
    let affine_matrix = @draw.AffineMatrix::from_transform(transform)
    g = g.clone().affine_transform(affine_matrix)
    bbox = g.bounding_box().unwrap()
  }

  //
  let paths = g.all_paths_and_compound_paths()
  ignore(
    Graphic::every(paths, fn(g) {
      match g {
        Path(path) => self.render_path(path)
        CompoundPath(path) => self.render_compound_path(path)
        _ => ()
      }
      true
    }),
  )
}

///|
fn render_path(self : CanvasCtx, path : Path) -> Unit {
  self.render_paths([path], path.stroke, path.fill)
}

///|
fn render_compound_path(self : CanvasCtx, path : CompoundPath) -> Unit {
  self.render_paths(path.paths, path.stroke, path.fill)
}

///|
fn render_paths(
  self : CanvasCtx,
  paths : Array[Path],
  stroke : Stroke?,
  fill : Fill?
) -> Unit {
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
fn canvas_commands(self : CanvasCtx, path : Path) -> Unit {
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
fn svg_stroke(stroke : Stroke?) -> String {
  // TODO
  match stroke {
    None =>
      $|stroke="none"
    Some(stroke) => {
      let parts = []
      let color = stroke.color.to_css_string()
      parts.push(
        $|stroke="\{color}"
        ,
      )
      // TODO: stroke-dasharray
      // TODO: stroke-dashoffset
      match stroke.cap {
        Butt => ()
        Round =>
          parts.push(
            $|stroke-linecap="round"
            ,
          )
        Square =>
          parts.push(
            $|stroke-linecap="square"
            ,
          )
      }
      match stroke.join {
        Miter => ()
        Round =>
          parts.push(
            $|stroke-linejoin="round"
            ,
          )
        Bevel =>
          parts.push(
            $|stroke-linejoin="bevel"
            ,
          )
      }
      if stroke.miter_limit != 4 {
        parts.push(
          $|stroke-miterlimit="\{stroke.miter_limit}"
          ,
        )
      }
      if stroke.width != 1 {
        parts.push(
          $|stroke-width="\{stroke.width}"
          ,
        )
      }
      String::concat(parts, separator=" ")
    }
  }
}

///|
fn set_fill(self : CanvasCtx, fill : Fill?) -> Unit {
  match fill {
    None => self.set_fill_color(0, 0, 0, 0)
    Some(fill) => {
      let c = fill.color
      self.set_fill_color(c.r, c.g, c.b, c.a)
    }
  }
}
