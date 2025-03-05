///|
typealias Font = @fonts.Font

///|
pub(all) enum TextAlign {
  Left
  Center
  Right
} derive(Show, Eq)

///| text generates a new Graphic (a Group of Group of compound_paths) from a text
/// string and a font.
pub fn text(
  text~ : String,
  font~ : Font,
  align~ : TextAlign = Left,
  size~ : Double = 1
) -> Graphic!DrawError {
  let xscale = size / font.units_per_em
  let yscale = -xscale
  let mut x = 0.0
  let mut y = 0.0
  let compound_paths : Array[Graphic] = []
  for c in text {
    let glyph = font.glyphs[c.to_string()]
    if glyph != None {
      let glyph = glyph.unwrap()
      // console.log(`GML: glyph=${JSON.stringify(glyph)}`)
      let cp = glyph2compound_path!(
        glyph.d,
        glyph.gerber_lp,
        vec2(x, y),
        xscale,
        yscale,
      )
      compound_paths.push(CompoundPath(cp))
      if glyph.horiz_adv_x > 0 {
        x = x + xscale * glyph.horiz_adv_x
      } else {
        x = x + xscale * font.horiz_adv_x
      }
    } else if c == '\n' { // advance line and return to far left
      x = 0
      y = y - yscale * (font.units_per_em - font.descent)
    } else if c == '\r' { // advance line only
      y = y - yscale * (font.units_per_em - font.descent)
    } else {
      // anything else - advance to the right by default width
      x = x + xscale * font.horiz_adv_x
    }
  }

  //
  let group = Group::new(items=compound_paths)
  // Use default positioning of initial glyph
  if align == Center {
    let bbox = group.bounding_box()
    if bbox != None {
      let bbox = bbox.unwrap()
      let position = vec2(-(bbox.max.x + bbox.min.x) / 2, 0)
      ignore(group.transform(position~))
    }
  } else if align == Right {
    let bbox = group.bounding_box()
    if bbox != None {
      let bbox = bbox.unwrap()
      let position = vec2(-bbox.max.x, 0)
      ignore(group.transform(position~))
    }
  }
  Group(Group::new(items=[Group(group)]))
}

///|
let split_re : @regexp.RegExp = @regexp.compile?("^([MLCQZ])([0-9.\\-, ]*)").unwrap()

///|
fn parse_params(s : String) -> Array[Double] {
  s
  .split(" ")
  .map(fn(s) {
    try {
      @strconv.parse_double!(s)
    } catch {
      _ => 0.0
    }
  })
  .collect()
}

// `glyph2compound_path` converts an SVG path into a CompoundPath.
///|
fn glyph2compound_path(
  d : String,
  gerber_lp : String,
  pos : Vec2,
  xscale : Double,
  yscale : Double
) -> CompoundPath!DrawError {
  let paths = []
  let mut anchors = []
  if gerber_lp[0] != 'd' {
    raise DrawError(
      "glyph2compound_path: unexpected gerber_lp='\{gerber_lp}' does not start with 'd'",
    )
  }
  let mut gerber_index = 0
  let black = rgba(0, 0, 0, 1)
  let mut color = black // start with black
  let mut path_is_inverted = false
  let mut d = d
  while d.length() > 0 {
    let m = split_re.matches(d)
    guard m.captures() is [match_str, cmd, params] else {
      raise DrawError("glyph2compound_path: unable to split SVG path '\{d}'")
    }

    //
    d = d.substring(start=match_str.length())
    match cmd {
      "M" => {
        if anchors.length() > 0 {
          let path = Path::new(
            anchors~,
            clear=path_is_inverted,
            fill=Some(fill(color)),
          )
          paths.push(path)
          anchors = []
        }
        if gerber_lp[gerber_index] == 'd' {
          color = rgba(0, 0, 0, 1)
          path_is_inverted = false
        } else if gerber_lp[gerber_index] == 'c' {
          color = rgba(1, 1, 1, 1)
          path_is_inverted = true
        } else {
          raise DrawError(
            "glyph2compound_path: bad length of gerber_lp='\{gerber_lp}'",
          )
        }
        gerber_index += 1
        let params = parse_params(params)
        anchors.push(
          Anchor::new(
            position=vec2(params[0] * xscale, params[1] * yscale).add(pos),
          ),
        )
      }
      "L" => {
        if anchors.length() == 0 {
          raise DrawError(
            "glyph2compound_path: unexpected SVG command without prior position: \{match_str}",
          )
        }
        let params = parse_params(params)
        for i = 0; i < params.length(); i = i + 2 {
          anchors.push(
            Anchor::new(
              position=vec2(params[i] * xscale, params[i + 1] * yscale).add(pos),
            ),
          )
        }
      }
      "C" => {
        if anchors.length() == 0 {
          raise DrawError(
            "glyph2compound_path: unexpected SVG command without prior position: \{match_str}",
          )
        }
        let params = parse_params(match_str)
        for i = 0; i < params.length(); i = i + 6 {
          anchors[anchors.length() - 1].handle_out = vec2(
              params[i] * xscale,
              params[i + 1] * yscale,
            )
            .add(pos)
            .sub(anchors[anchors.length() - 1].position)
          let anchor_pos = vec2(params[i + 4] * xscale, params[i + 5] * yscale).add(
            pos,
          )
          let handle_in = vec2(params[i + 2] * xscale, params[i + 3] * yscale)
            .add(pos)
            .sub(anchor_pos)
          anchors.push(Anchor::new(position=anchor_pos, handle_in~))
        }
      }
      //   case 'Q': {
      "Q" => {
        if anchors.length() == 0 {
          raise DrawError(
            "glyph2compound_path: unexpected SVG command without prior position: \{match_str}",
          )
        }
        let params = parse_params(params)
        for i = 0; i < params.length(); i = i + 4 {
          let start_pt = anchors[anchors.length() - 1].position
          let quad_ctrl_pt = vec2(params[i] * xscale, params[i + 1] * yscale).add(
            pos,
          )
          let cubic1CtrlPt = quad_ctrl_pt
            .clone()
            .sub(start_pt)
            .mul_scalar(2.0 / 3)
            .add(start_pt)
          anchors[anchors.length() - 1].handle_out = cubic1CtrlPt.sub(
            anchors[anchors.length() - 1].position,
          )
          let end_pt = vec2(params[i + 2] * xscale, params[i + 3] * yscale).add(
            pos,
          )
          let cubic2_ctrl_pt = quad_ctrl_pt
            .sub(end_pt)
            .mul_scalar(2.0 / 3)
            .add(end_pt)
          anchors.push(
            Anchor::new(position=end_pt, handle_in=cubic2_ctrl_pt.sub(end_pt)),
          )
        }
      }
      "Z" => {
        if anchors.length() == 0 {
          raise DrawError(
            "glyph2compound_path: unexpected SVG command without prior segments: \{match_str}",
          )
        }
        let path = Path::new(
          anchors~,
          closed=true,
          clear=path_is_inverted,
          fill=Some(fill(color)),
        )
        paths.push(path)
        anchors = []
      }
      _ => raise DrawError("unsupported font command: \{match_str}")
    }
  }

  //
  if anchors.length() > 0 {
    let path = Path::new(
      anchors~,
      clear=path_is_inverted,
      fill=Some(fill(color)),
    )
    paths.push(path)
  }
  CompoundPath::new(paths~, fill=Some(fill(black)))
}
