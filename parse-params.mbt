///|
/// `Params` represents the parameters to an SVG command.
struct Params(Array[Double]) derive(Show, Eq)

///|
pub fn length(self : Params) -> Int {
  self.inner().length()
}

///|
let params_re : @regexp.RegExp = (try? @regexp.compile("^ *([0-9\\.\\-]+) *,*")).unwrap()

///|
/// `parse_params` parses an SVG command and returns the parameters.
fn parse_params(d : String) -> Params raise FontError {
  let mut d = d
  let params = []
  while d.length() > 0 {
    let match_result = params_re.matches(d)
    match match_result.captures() {
      [m, num] => {
        d = d.substring(start=m.length())
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
