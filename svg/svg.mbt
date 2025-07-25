///|
typealias @draw.CompoundPath

///|
typealias @draw.Fill

///|
typealias @draw.Graphic

///|
typealias @draw.Path

///|
typealias @draw.Stroke

///|
let vec2 = @draw.vec2

///|
/// from_graphics returns an SVG from a Graphic.
/// Note that if the design was created with Y being "up", then it
/// must be flipped to render properly as an SVG.
pub fn from_graphic(g : Graphic, y_up~ : Bool = true) -> String {
  let mut bbox = match g.bounding_box() {
    Some(box) => box
    _ => return "<svg></svg>"
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
  let min = bbox.min.round_to_fixed(2)
  let max = bbox.max.round_to_fixed(2)
  let paths = g.all_paths_and_compound_paths()
  let lines = Array::new(capacity=paths.length())
  ignore(
    Graphic::every(paths, fn(g) {
      match g {
        Path(path) => lines.push(path_to_svg(path))
        CompoundPath(path) => lines.push(compound_path_to_svg(path))
        _ => ()
      }
      true
    }),
  )
  let lines = lines.join("\n")
  (
    $|<svg xmlns="http://www.w3.org/2000/svg" viewBox="\{min.x} \{min.y} \{max.x} \{max.y}">
    $|\{lines}
    #|</svg>
  )
}

///|
fn path_to_svg(path : Path) -> String {
  let d = svg_d([path])
  let stroke = svg_stroke(path.stroke)
  let fill = svg_fill(path.fill)
  (
    $|  <path d="\{d}" \{stroke} \{fill}/>
  )
}

///|
fn compound_path_to_svg(path : CompoundPath) -> String {
  let d = svg_d(path.paths)
  let stroke = svg_stroke(path.stroke)
  let fill = svg_fill(path.fill)
  (
    $|  <path d="\{d}" \{stroke} \{fill}/>
  )
}

///|
fn svg_d(paths : Array[Path]) -> String {
  let cmds = []
  for path in paths {
    cmds.push(svg_path(path))
  }
  cmds.join("")
}

///|
fn svg_path(path : Path) -> String {
  if path.anchors.length() < 2 {
    return ""
  }
  let cmds = []
  for index, anchor in path.anchors {
    let pos = anchor.position
    if index == 0 {
      let pos = pos.round_to_fixed(2)
      cmds.push("M\{pos.x} \{pos.y}")
      continue
    }
    let last_anchor = path.anchors[index - 1]
    let h1 = last_anchor.handle_out
    let h2 = anchor.handle_in
    if h1.is_zero() && h2.is_zero() {
      cmds.push("L\{pos.x} \{pos.y}")
    } else {
      let last_pos = last_anchor.position
      let p1 = (h1 + last_pos).round_to_fixed(2)
      let p2 = (h2 + pos).round_to_fixed(2)
      let pos = pos.round_to_fixed(2)
      cmds.push("C\{p1.x} \{p1.y} \{p2.x} \{p2.y} \{pos.x} \{pos.y}")
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
      let p1 = (h1 + last_pos).round_to_fixed(2)
      let p2 = (h2 + pos).round_to_fixed(2)
      let pos = pos.round_to_fixed(2)
      cmds.push("C\{p1.x} \{p1.y} \{p2.x} \{p2.y} \{pos.x} \{pos.y}")
    }
    cmds.push("Z")
  }
  cmds.join("")
}

///|
fn svg_stroke(stroke : Stroke?) -> String {
  match stroke {
    None =>
      (
        $|stroke="none"
      )
    Some(stroke) => {
      let parts = []
      let color = stroke.color.to_css_string()
      parts.push(
        (
          $|stroke="\{color}"
        ),
      )
      // TODO: stroke-dasharray
      // TODO: stroke-dashoffset
      match stroke.cap {
        Butt => ()
        Round =>
          parts.push(
            (
              $|stroke-linecap="round"
            ),
          )
        Square =>
          parts.push(
            (
              $|stroke-linecap="square"
            ),
          )
      }
      match stroke.join {
        Miter => ()
        Round =>
          parts.push(
            (
              $|stroke-linejoin="round"
            ),
          )
        Bevel =>
          parts.push(
            (
              $|stroke-linejoin="bevel"
            ),
          )
      }
      if stroke.miter_limit != 4 {
        parts.push(
          (
            $|stroke-miterlimit="\{stroke.miter_limit}"
          ),
        )
      }
      if stroke.width != 1 {
        parts.push(
          (
            $|stroke-width="\{stroke.width}"
          ),
        )
      }
      parts.join(" ")
    }
  }
}

///|
fn svg_fill(fill : Fill?) -> String {
  match fill {
    None =>
      (
        $|fill="none"
      )
    Some(fill) => {
      let color = fill.color.to_css_string()
      (
        $|fill="\{color}"
      )
    }
  }
}
