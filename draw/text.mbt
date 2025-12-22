///|
/// `TextAlign` specifies the horizontal alignment of text.
pub(all) enum TextAlign {
  /// `Left` aligns text to the left.
  Left
  /// `Center` centers the text.
  Center
  /// `Right` aligns text to the right.
  Right
} derive(Show, Eq)

///|
/// `to_graphic` generates a new `Graphic` from a text string and a font.
pub fn to_graphic(
  font : Font,
  text : String,
  size? : Double = 1.0,
  alignment? : Alignment = Unchanged,
  y_up? : Bool = false,
) -> Graphic raise DrawError {
  let glyph = font.gen_path(text, alignment~, y_up~) catch {
    e => raise DrawError("to_graphic: \{e}")
  }
  let xscale = size / font.units_per_em
  let yscale = xscale
  let svgpath = SVGPath::from_glyph(glyph) catch {
    e => raise DrawError("to_graphic: \{e}")
  }
  svgpath2compound_path(svgpath, xscale, yscale).as_graphic()
}

///|
/// `text` is a convenience wrapper around `to_graphic` that uses `TextAlign`.
pub fn text(
  font : Font,
  text : String,
  size? : Double = 1.0,
  align? : TextAlign = Left,
  y_up? : Bool = false,
) -> Graphic raise DrawError {
  let alignment : Alignment = match align {
    Left => BaselineLeft
    Center => BaselineCenter
    Right => BaselineRight
  }
  to_graphic(font, text, size~, alignment~, y_up~)
}

///|
fn svgpath2compound_path(
  svgpath : SVGPath,
  xscale : Double,
  yscale : Double,
) -> CompoundPath {
  let paths = []
  let mut anchors = []
  let black = rgba(0, 0, 0, 1)
  let white = rgba(1, 1, 1, 1)
  let mut current_gerber_lp = GerberLP::Dark
  for cmd in svgpath.cmds {
    match cmd.cmd {
      M => {
        if anchors.length() > 0 {
          let color = if current_gerber_lp == Dark { black } else { white }
          let path = Path::new(
            anchors~,
            clear=current_gerber_lp == Clear,
            fill=fill(color),
          )
          paths.push(path)
          anchors = []
        }
        current_gerber_lp = cmd.gerber_lp
        for p in cmd.params {
          anchors.push(Anchor::new(position=vec2(p.x * xscale, p.y * yscale)))
        }
      }
      L =>
        for p in cmd.params {
          anchors.push(Anchor::new(position=vec2(p.x * xscale, p.y * yscale)))
        }
      C =>
        for i = 0; i < cmd.params.length(); i = i + 3 {
          let c1 = cmd.params[i]
          let c2 = cmd.params[i + 1]
          let end = cmd.params[i + 2]
          let prev_anchor = anchors[anchors.length() - 1]
          prev_anchor.handle_out = vec2(c1.x * xscale, c1.y * yscale).sub(
            prev_anchor.position,
          )
          let end_pos = vec2(end.x * xscale, end.y * yscale)
          let h_in = vec2(c2.x * xscale, c2.y * yscale).sub(end_pos)
          anchors.push(Anchor::new(position=end_pos, handle_in=h_in))
        }
      Q =>
        for i = 0; i < cmd.params.length(); i = i + 2 {
          let cp = cmd.params[i]
          let end = cmd.params[i + 1]
          let start_pt = anchors[anchors.length() - 1].position
          let quad_ctrl_pt = vec2(cp.x * xscale, cp.y * yscale)
          let c1 = quad_ctrl_pt
            .sub(start_pt)
            .mul_scalar(2.0 / 3.0)
            .add(start_pt)
          anchors[anchors.length() - 1].handle_out = c1.sub(start_pt)
          let end_pt = vec2(end.x * xscale, end.y * yscale)
          let c2 = quad_ctrl_pt.sub(end_pt).mul_scalar(2.0 / 3.0).add(end_pt)
          anchors.push(Anchor::new(position=end_pt, handle_in=c2.sub(end_pt)))
        }
      Z =>
        if anchors.length() > 0 {
          let color = if current_gerber_lp == Dark { black } else { white }
          let path = Path::new(
            anchors~,
            closed=true,
            clear=current_gerber_lp == Clear,
            fill=fill(color),
          )
          paths.push(path)
          anchors = []
        }
    }
  }
  if anchors.length() > 0 {
    let color = if current_gerber_lp == Dark { black } else { white }
    let path = Path::new(
      anchors~,
      clear=current_gerber_lp == Clear,
      fill=fill(color),
    )
    paths.push(path)
  }
  CompoundPath::new(paths~, fill=fill(black))
}
