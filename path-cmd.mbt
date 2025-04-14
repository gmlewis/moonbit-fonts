///|
/// `ParamPair` represents an X,Y absolute coordinate pair of parameters.
pub(all) struct ParamPair {
  x : Double
  y : Double
} derive(Eq)

///|
pub fn ParamPair::to_string(self : ParamPair) -> String {
  "(\{svg_num(self.x)},\{svg_num(self.y)})"
}

///|
impl Show for ParamPair with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
/// `Cmd` represents an individual absolute SVG command.
pub(all) struct PathCmd {
  cmd : AbsoluteCmd
  gerber_lp : GerberLP
  params : Array[ParamPair]
} derive(Show, Eq)

///|
pub fn PathCmd::from_svg_cmd(
  svg_cmd : Cmd,
  gerber_lp : GerberLP
) -> PathCmd!FontError {
  let cmd = match svg_cmd.c {
    "M" => M
    "L" => L
    "C" => C
    "Q" => Q
    "Z" => Z
    c =>
      raise FontError("PathCmd::from_svg_cmd: unsupported SVG command '\{c}'")
  }
  if svg_cmd.p._.length() % 2 != 0 {
    raise FontError(
      "PathCmd::from_svg_cmd: unexpected odd params length in svg_cmd: \{svg_cmd}",
    )
  }

  //
  let params : Array[ParamPair] = Array::new(capacity=svg_cmd.p._.length() / 2)
  let mut x = 0.0
  for index, param in svg_cmd.p._ {
    if index % 2 == 0 {
      x = param
    } else {
      params.push({ x, y: param })
    }
  }

  //
  { cmd, gerber_lp, params }
}

///|
pub fn PathCmd::to_svg_cmd(self : PathCmd) -> (Cmd, String) {
  let gerber_lp = match self.cmd {
    M =>
      match self.gerber_lp {
        Dark => "d"
        Clear => "c"
      }
    _ => ""
  }
  let p : Array[Double] = Array::new(capacity=self.params.length() * 2)
  for pp in self.params {
    p.push(pp.x)
    p.push(pp.y)
  }
  let c = "\{self.cmd}"
  let cmd = { c, p }
  (cmd, gerber_lp)
}

///|
/// `bbox` returns the minimum bounding box of a PathCmd.
pub fn bbox(self : PathCmd) -> Rectangle {
  let r = Rectangle::new()
  for index, pp in self.params {
    if index == 0 {
      r.min.x = pp.x
      r.min.y = pp.y
      r.max.x = pp.x
      r.max.y = pp.y
    } else {
      r.extend(pt(pp.x, pp.y))
    }
  }
  r
}

///|
/// `PathCmdFn` represents a function that processes or transforms individual commands.
/// The first argument is the index within the command.
pub(all) type PathCmdFn (Int, PathCmd) -> PathCmd

///|
/// `clone` makes a deep copy of a PatchCmd.
pub fn PathCmd::clone(self : PathCmd) -> PathCmd {
  let params = Array::new(capacity=self.params.length())
  for param in self.params {
    let pp : ParamPair = { x: param.x, y: param.y }
    params.push(pp)
  }
  { cmd: self.cmd, gerber_lp: self.gerber_lp, params }
}
