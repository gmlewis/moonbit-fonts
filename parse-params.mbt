///|
/// `Params` represents the parameters to an SVG command.
struct Params(Array[Double]) derive(Show, Eq)

///|
pub fn Params::length(self : Params) -> Int {
  self.0.length()
}

///|
let params_re : @regexp.Regexp = (try? @regexp.compile("^ *([0-9\\.\\-]+) *,*")).unwrap()

///|
/// `parse_params` parses an SVG command and returns the parameters.
fn parse_params(d : String) -> Params raise FontError {
  let mut d = d
  let params = []
  while d.length() > 0 {
    let match_result = params_re
      .match_(d)
      .unwrap_or_error(
        FontError("parse_params: unable to parse SVG params: \{d}"),
      )
    match match_result.results() {
      [Some(m), Some(num)] => {
        d = d.unsafe_substring(start=m.length(), end=d.length())
        let n = @strconv.parse_double(num) catch {
          _ => raise FontError("parse_params: unable to parse double: \{num}")
        }
        params.push(n)
      }
      e =>
        raise FontError(
          "parse_params: unable to parse SVG params \{d}: got \{e}",
        )
    }
  }
  params
}

///|
test "parse_params" {
  let d = " 343 75 327.5 112 "
  let got = parse_params(d)
  let want = [343.0, 75.0, 327.5, 112.0]
  assert_eq(got, want)
}
