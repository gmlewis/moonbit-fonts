/// `Params` represents the parameters to an SVG command.
type Params Array[Double]

// let regexp = @regexp.compile("^(?<addr>[a-zA-Z0-9._%+-]+)@(?<host>[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,})$")?
let params_re = @regexp.compile("^ *([0-9\\.\\-]+) *,*")?
// let match_result = regexp.matches("12345@test.com")
// println(match_result.success()) // true
// println(match_result.capture(0)) // 12345@test.com
// println(match_result.capture(1)) // 12345
// println(match_result.capture(2)) // test.com
// println(match_result.named("addr")) // 12345
// println(match_result.named("host")) // test.com

/// `parse_params` parses an SVG command and returns the parameters.
fn parse_params(d : String) -> Params { // !String {
  let params = []
  while d.length() > 0 {
    let match_result = params_re.matches(d)
  }
  params
}
