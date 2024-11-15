/// `bbox` returns the bounding box of a Glyph path.
pub fn bbox(d : String) -> Rectangle!Error {
  let cmds = split_path!(d)
  let mut xmin = 0.0
  let mut ymin = 0.0
  let mut xmax = 0.0
  let mut ymax = 0.0
  for cmd_idx, cmd in cmds {
    for index, val in cmd.p._ {
      if cmd_idx == 0 && index == 0 {
        xmin = val
        xmax = val
      } else if cmd_idx == 0 && index == 1 {
        ymin = val
        ymax = val
      } else if index % 2 == 0 {
        if val < xmin {
          xmin = val
        }
        if val > xmax {
          xmax = val
        }
      } else {
        if val < ymin {
          ymin = val
        }
        if val > ymax {
          ymax = val
        }
      }
    }
  }
  rect(xmin, ymin, xmax, ymax)
}
