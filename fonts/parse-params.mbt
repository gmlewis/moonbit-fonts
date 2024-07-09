/// `Params` represents the parameters to an SVG command.
type Params Array[Double] derive(Debug, Eq)

// let regexp = @regexp.compile("^(?<addr>[a-zA-Z0-9._%+-]+)@(?<host>[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,})$")?
let params_re : @regexp.RegExp = @regexp.compile("^ *([0-9\\.\\-]+) *,*")!!.unwrap()
// let match_result = regexp.matches("12345@test.com")
// println(match_result.success()) // true
// println(match_result.capture(0)) // 12345@test.com
// println(match_result.capture(1)) // 12345
// println(match_result.capture(2)) // test.com
// println(match_result.named("addr")) // 12345
// println(match_result.named("host")) // test.com

/// `parse_params` parses an SVG command and returns the parameters.
fn parse_params(d : String) -> Params!String {
  let mut d = d
  let params = []
  while d.length() > 0 {
    let match_result = params_re.matches(d)
    let m = match_result.capture(0)
    debug(m)
    match m {
      Some(m) => {
        d = d.substring(start=m.length())
        debug(d)
        let n = @strconv.parse_double(m.trim_space())!
        debug(n)
        params.push(n)
      }
      None => break
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
