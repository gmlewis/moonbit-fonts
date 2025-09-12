///|
/// `Cmd` represents an SVG command along with its parameters.
struct Cmd {
  c : String
  p : Params
} derive(Show, Eq)

///|
let split_re : @regexp.Regexp = (try? @regexp.compile(
  "^([MLCQZ])([0-9\\.\\-, ]*)",
)).unwrap()

///|
/// `split_path` splits an SVG path into an array of individual commands.
fn split_path(d : String) -> Array[Cmd] raise FontError {
  let mut d = d
  let cmds = []
  while d.length() > 0 {
    let match_result = split_re
      .match_(d)
      .or_error(FontError("split_path: unable to parse SVG params: \{d}"))
    match match_result.results() {
      [_, Some(c), Some(p)] => {
        d = d.unsafe_substring(start=c.length() + p.length(), end=d.length())
        let c = c.to_string()
        let p = parse_params(p.to_string())
        cmds.push({ c, p })
      }
      _ => raise FontError("split_path: unable to split SVG path \{d}")
    }
  }
  cmds
}

///|
test "split_path" {
  let d = "M507 24L48 24L48 530L395 530L395 625L48 625L48 723L507 723L507 24ZM395 269L395 433L138 433L138 269L395 269Z"
  let got = split_path(d)
  let want = [
    { c: "M", p: Params([507.0, 24.0]) },
    { c: "L", p: Params([48.0, 24.0]) },
    { c: "L", p: Params([48.0, 530.0]) },
    { c: "L", p: Params([395.0, 530.0]) },
    { c: "L", p: Params([395.0, 625.0]) },
    { c: "L", p: Params([48.0, 625.0]) },
    { c: "L", p: Params([48.0, 723.0]) },
    { c: "L", p: Params([507.0, 723.0]) },
    { c: "L", p: Params([507.0, 24.0]) },
    { c: "Z", p: Params([]) },
    { c: "M", p: Params([395.0, 269.0]) },
    { c: "L", p: Params([395.0, 433.0]) },
    { c: "L", p: Params([138.0, 433.0]) },
    { c: "L", p: Params([138.0, 269.0]) },
    { c: "L", p: Params([395.0, 269.0]) },
    { c: "Z", p: Params([]) },
  ]
  assert_eq(got, want)
}
