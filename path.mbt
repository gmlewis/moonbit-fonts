///|
/// A `Path` is identical to a `Glyph` but has been optimized internally
/// for further manipulation, whereas a `Glyph` is optimized for compact
/// storage of font data within all the font packages.
/// A `Path` can be converted to a `Glpyh` and vice versa.
pub(all) struct Path {
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
} derive(Show, Eq)

///|
/// `AbsoluteCmd` represents a supported absolute SVG command.
pub(all) enum AbsoluteCmd {
  // MoveTo: https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/d#moveto_path_commands
  M
  // LineTo: https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/d#lineto_path_commands
  L
  // Cubic Bézier curve: https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/d#cubic_b%C3%A9zier_curve
  C
  // Quadratic Bézier curve: https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/d#quadratic_b%C3%A9zier_curve
  Q
  // ClosePath: https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/d#closepath
  Z
} derive(Show, Eq)

///|
/// `GerberLP` represents whether a subpath is `Dark` or `Clear`.
pub(all) enum GerberLP {
  Dark
  Clear
} derive(Show, Eq)

///|
/// `from_glyph` returns a `Path` from a `Glyph`, optionally processing
/// every `Cmd` with a processing function.
/// Note that apart from `path_cmd_fn`, `from_glyph` makes no attempt to process the
/// invidual glyphs and simply transforms the representation.
pub fn Path::from_glyph(
  g : Glyph,
  path_cmd_fn? : PathCmdFn,
) -> Path raise FontError {
  let mut bbox = Rectangle::new()
  let svg_cmds = split_path(g.d)
  let cmds = Array::new(capacity=svg_cmds.length())
  let mut gerber_index = 0
  let mut gerber_lp = Dark
  for index, svg_cmd in svg_cmds {
    if svg_cmd.c == "M" {
      gerber_lp = match
        g.gerber_lp.unsafe_charcode_at(gerber_index).to_char().unwrap() {
        'd' => Dark
        'c' => Clear
        c => raise FontError("Path::from_glyph: unsupported GerberLP '\{c}'")
      }
      gerber_index += 1
    }
    let cmd = PathCmd::from_svg_cmd(svg_cmd, gerber_lp)
    let cmd = match path_cmd_fn {
      Some(f) => f.inner()(index, cmd)
      _ => cmd
    }
    cmds.push(cmd)

    // update bbox
    if cmd.cmd != Z {
      if index == 0 {
        bbox = cmd.bbox()
      } else {
        for p in cmd.params {
          bbox.extend(pt(p.x, p.y))
        }
      }
    }
  }

  //
  let (xmin, ymin, xmax, ymax) = bbox.bounds()
  { char: g.char, cmds, xmin, ymin, xmax, ymax }
}

///|
/// `to_glyph` returns a "super" `Glyph` from a `Path`, optionally processing
/// every `PathCmd` with a processing function.
/// Note that apart from `path_cmd_fn`, `to_glyph` makes no attempt to process the
/// invidual glyphs and simply transforms the representation.
pub fn to_glyph(self : Path, path_cmd_fn? : PathCmdFn) -> Glyph {
  let gerber_lp = @buffer.new()
  let d = @buffer.new()
  let mut bbox = Rectangle::new()

  //
  for index, cmd in self.cmds {
    let cmd = match path_cmd_fn {
      Some(f) => f.inner()(index, cmd)
      _ => cmd
    }
    let (svg_cmd, glp) = cmd.to_svg_cmd()
    d.write_string(svg_cmd.c)
    if glp != "" {
      gerber_lp.write_string(glp)
    }
    let params = Array::new(capacity=svg_cmd.p.length())
    for p in svg_cmd.p.inner() {
      params.push(svg_num(p))
    }
    d.write_string(params.join(" "))

    // update bbox
    if cmd.cmd != Z {
      if index == 0 {
        bbox = cmd.bbox()
      } else {
        for p in cmd.params {
          bbox.extend(pt(p.x, p.y))
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
/// `clone` makes a deep copy of a Path.
pub fn Path::clone(self : Path) -> Path {
  let cmds = Array::new(capacity=self.cmds.length())
  for cmd in self.cmds {
    cmds.push(cmd.clone())
  }
  {
    char: self.char,
    cmds,
    xmin: self.xmin,
    ymin: self.ymin,
    xmax: self.xmax,
    ymax: self.ymax,
  }
}
