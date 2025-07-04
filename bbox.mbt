///|
/// `glyph_bbox` returns the conservative bounding box of a Glyph path.
/// It only supports the absolute SVG commands: M, L, C, Q, Z.
///
/// Note that this function does _NOT_ fully analyze the Cubic or Quadratic
/// Bézier curves to determine their exact bounding boxes, but instead
/// takes a naive and concervative approach by encapsulating the bounds
/// of all control points in addition to curve anchor points which may result
/// in returning a much larger bounding box than is actually needed to fully
/// contain the glyph.
pub fn glyph_bbox(d : String) -> Rectangle raise FontError {
  let cmds = split_path(d)
  let mut xmin = 0.0
  let mut ymin = 0.0
  let mut xmax = 0.0
  let mut ymax = 0.0
  let update_x = fn(x : Double) {
    if x < xmin {
      xmin = x
    }
    if x > xmax {
      xmax = x
    }
  }
  let update_y = fn(y : Double) {
    if y < ymin {
      ymin = y
    }
    if y > ymax {
      ymax = y
    }
  }

  //
  for cmd_idx, cmd in cmds {
    for index, val in cmd.p.inner() {
      if cmd.c == "Z" {
        raise FontError(
          "glyph_bbox: cmd_idx=\{cmd_idx}, index=\{index}, unexpected command 'Z' with params: \{cmd.p.inner()}",
        )
      }
      if cmd_idx == 0 && index == 0 {
        if cmd.c != "M" {
          raise FontError(
            "glyph_bbox: cmd_idx=\{cmd_idx}, index=\{index}, unexpected command: '\{cmd.c}'",
          )
        }
        xmin = val
        xmax = val
      } else if cmd_idx == 0 && index == 1 {
        if cmd.c != "M" {
          raise FontError(
            "glyph_bbox: cmd_idx=\{cmd_idx}, index=\{index}, unexpected command: '\{cmd.c}'",
          )
        }
        ymin = val
        ymax = val
      } else if index % 2 == 0 {
        update_x(val)
      } else {
        update_y(val)
      }
    }
  }
  rect(xmin, ymin, xmax, ymax)
}
