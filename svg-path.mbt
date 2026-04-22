///|
/// An `SVGPath` is identical to a `Glyph` but has been optimized internally
/// for further manipulation, whereas a `Glyph` is optimized for compact
/// storage of font data within all the font packages.
/// An `SVGPath` can be converted to a `Glyph` and vice versa.
pub(all) struct SVGPath {
  /// `char` represents all the glyphs contained in this path.
  /// It is identical to the `Glyph.char` field.
  char : String
  /// `cmds` represents the combination of the `gerber_lp` and pre-parsed
  /// `d` fields of a glyph. It is optimized for further graphics-ops
  /// manipulation.
  /// The `gerber_lp` field ("dark" and "clear" subpath information) is encoded
  /// within each `PathCmd`.
  cmds : Array[PathCmd]
  /// These values represent the minimum bounding box of the glyph in native units.
  xmin : Double
  ymin : Double
  xmax : Double
  ymax : Double
} derive(Eq)

///|
pub impl Show for SVGPath with output(self, logger) {
  let { char, cmds, xmin, ymin, xmax, ymax } = self
  logger.write_string(
    (
      $|{char: \{char.escape(quote=true)}, cmds: \{cmds}, xmin: \{xmin}, ymin: \{ymin}, xmax: \{xmax}, ymax: \{ymax}}
    ),
  )
}

///|
test "SVGPath show interface" {
  let svgpath = {
    char: "A",
    cmds: [],
    xmin: 0.0,
    ymin: 0.0,
    xmax: 100.0,
    ymax: 100.0,
  }
  inspect(
    svgpath,
    content=(
      #|{char: "A", cmds: [], xmin: 0, ymin: 0, xmax: 100, ymax: 100}
    ),
  )
}

///|
/// `AbsoluteCmd` represents a supported absolute SVG command.
pub(all) enum AbsoluteCmd {
  /// `M` is the MoveTo command:
  /// https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/d#moveto_path_commands
  M
  /// `L` is the LineTo command:
  /// https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/d#lineto_path_commands
  L
  /// `C` is the Cubic Bézier curve command:
  /// https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/d#cubic_b%C3%A9zier_curve
  C
  /// `Q` is the Quadratic Bézier curve command:
  /// https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/d#quadratic_b%C3%A9zier_curve
  Q
  /// `Z` is the ClosePath command:
  /// https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/d#closepath
  Z
} derive(Eq)

///|
pub impl Show for AbsoluteCmd with output(self, logger) {
  match self {
    M =>
      logger.write_string(
        (
          $|M
        ),
      )
    L =>
      logger.write_string(
        (
          $|L
        ),
      )
    C =>
      logger.write_string(
        (
          $|C
        ),
      )
    Q =>
      logger.write_string(
        (
          $|Q
        ),
      )
    Z =>
      logger.write_string(
        (
          $|Z
        ),
      )
  }
}

///|
test "AbsoluteCmd show interface" {
  inspect(
    M,
    content=(
      #|M
    ),
  )
  inspect(
    L,
    content=(
      #|L
    ),
  )
  inspect(
    C,
    content=(
      #|C
    ),
  )
  inspect(
    Q,
    content=(
      #|Q
    ),
  )
  inspect(
    Z,
    content=(
      #|Z
    ),
  )
}

///|
/// `GerberLP` represents whether a subpath is `Dark` or `Clear`.
pub(all) enum GerberLP {
  /// `Dark` means the subpath is filled.
  Dark
  /// `Clear` means the subpath is a hole.
  Clear
} derive(Eq)

///|
pub impl Show for GerberLP with output(self, logger) {
  match self {
    Dark =>
      logger.write_string(
        (
          $|Dark
        ),
      )
    Clear =>
      logger.write_string(
        (
          $|Clear
        ),
      )
  }
}

///|
test "GerberLP show interface" {
  inspect(
    Dark,
    content=(
      #|Dark
    ),
  )
  inspect(
    Clear,
    content=(
      #|Clear
    ),
  )
}

///|
/// `from_glyph` returns an `SVGPath` from a `Glyph`, optionally processing
/// every `Cmd` with a processing function.
/// Note that apart from `path_cmd_fn`, `from_glyph` makes no attempt to process the
/// individual glyphs and simply transforms the representation.
pub fn SVGPath::from_glyph(
  g : Glyph,
  path_cmd_fn? : PathCmdFn,
) -> SVGPath raise FontError {
  let bbox = @geom.BoundingBox::max_reversed()
  let svg_cmds = split_path(g.d)
  let cmds = Array::new(capacity=svg_cmds.length())
  let mut gerber_index = 0
  let mut gerber_lp = Dark
  for index, svg_cmd in svg_cmds {
    if svg_cmd.c == "M" {
      if gerber_index >= g.gerber_lp.length() {
        raise FontError(
          "SVGPath::from_glyph: gerber_lp index out of range: index=\{gerber_index}, length=\{g.gerber_lp.length()} for path '\{g.char}'",
        )
      }
      let glp = match g.gerber_lp.unsafe_get(gerber_index).to_char() {
        Some(c) => c
        None =>
          raise FontError(
            "SVGPath::from_glyph: invalid GerberLP character at index \{gerber_index} for path '\{g.char}'",
          )
      }
      gerber_lp = match glp {
        'd' => Dark
        'c' => Clear
        c => raise FontError("SVGPath::from_glyph: unsupported GerberLP '\{c}'")
      }
      gerber_index += 1
    }
    let cmd = PathCmd::from_svg_cmd(svg_cmd, gerber_lp)
    let cmd = match path_cmd_fn {
      Some(f) => (f.0)(index, cmd)
      _ => cmd
    }
    cmds.push(cmd)

    // update bbox
    if cmd.cmd != Z {
      if index == 0 {
        let cmd_bbox = cmd.bbox()
        bbox.min.x = cmd_bbox.min.x
        bbox.min.y = cmd_bbox.min.y
        bbox.max.x = cmd_bbox.max.x
        bbox.max.y = cmd_bbox.max.y
      } else {
        for p in cmd.params {
          let _ = bbox.expand_to_include_point(@geom.pt(p.x, p.y))
        }
      }
    }
  }

  //
  let (xmin, ymin, xmax, ymax) = bbox.bounds()
  { char: g.char, cmds, xmin, ymin, xmax, ymax }
}

///|
/// `to_glyph` returns a "super" `Glyph` from an `SVGPath`, optionally processing
/// every `PathCmd` with a processing function.
/// Note that apart from `path_cmd_fn`, `to_glyph` makes no attempt to process the
/// individual glyphs and simply transforms the representation.
pub fn SVGPath::to_glyph(self : SVGPath, path_cmd_fn? : PathCmdFn) -> Glyph {
  let gerber_lp = @buffer.new()
  let d = @buffer.new()
  let bbox = @geom.BoundingBox::max_reversed()

  //
  for index, cmd in self.cmds {
    let cmd = match path_cmd_fn {
      Some(f) => (f.0)(index, cmd)
      _ => cmd
    }
    let (svg_cmd, glp) = cmd.to_svg_cmd()
    d.write_string(svg_cmd.c)
    if glp != "" {
      gerber_lp.write_string(glp)
    }
    let params = Array::makei(svg_cmd.p.0.length(), fn(i) {
      svg_num(svg_cmd.p.0[i])
    })
    d.write_string(params.join(" "))

    // update bbox
    if cmd.cmd != Z {
      if index == 0 {
        bbox.copy(cmd.bbox())
      } else {
        for p in cmd.params {
          let _ = bbox.expand_to_include_point(@geom.pt(p.x, p.y))
        }
      }
    }
  }

  //
  let gerber_lp = gerber_lp.contents().to_unchecked_string()
  let d = d.contents().to_unchecked_string()
  let (xmin, ymin, xmax, ymax) = bbox.bounds()
  { char: self.char, horiz_adv_x: 0, gerber_lp, d, xmin, ymin, xmax, ymax }
}

///|
/// `clone` makes a deep copy of an SVGPath.
pub fn SVGPath::clone(self : SVGPath) -> SVGPath {
  let cmds = Array::makei(self.cmds.length(), fn(i) { self.cmds[i].clone() })
  {
    char: self.char,
    cmds,
    xmin: self.xmin,
    ymin: self.ymin,
    xmax: self.xmax,
    ymax: self.ymax,
  }
}
