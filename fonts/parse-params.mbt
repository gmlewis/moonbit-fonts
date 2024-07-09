/// `Params` represents the parameters to an SVG command.
type Params Array[Double] derive(Debug, Eq)

let params_re : @regexp.RegExp = @regexp.compile("^ *([0-9\\.\\-]+) *,*")!!.unwrap()

/// `parse_params` parses an SVG command and returns the parameters.
fn parse_params(d : String) -> Params!String {
  let mut d = d
  let params = []
  while d.length() > 0 {
    let match_result = params_re.matches(d)
    let m = match_result.capture(0)
    match m {
      Some(m) => {
        d = d.substring(start=m.length())
        let n = @strconv.parse_double(m.trim_space())!
        params.push(n)
      }
      None => {
        raise "unable to parse SVG params \(d)"
      }
    }
  }
  params
}

test "parse_params" {
  let d = " 343 75 327.5 112 "
  let got = parse_params(d)!
  let want = [343.0, 75.0, 327.5, 112.0]
  @test.eq(got, want)!
}
