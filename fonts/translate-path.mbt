/// `translate_path` translates (moves) an SVG path by the provided offsets.
pub fn translate_path(
  d : String,
  x : Double,
  y : Double,
  invert_y~ : Bool = false
) -> String!Error {
  let cmds = split_path!(d)
  let d = @buffer.new()
  let y_scale = if invert_y { -1.0 } else { 1.0 }
  for cmd in cmds {
    d.write_string(cmd.c)
    cmd.p._
    .iter()
    .eachi(
      fn(index, val) {
        if index % 2 == 0 {
          if index > 0 {
            d.write_char(' ')
          }
          d.write_string(svg_num(x + val))
        } else {
          d.write_char(' ')
          d.write_string(svg_num(y + y_scale * val))
        }
      },
    )
  }
  d.to_string()
}

fn svg_num(val : Double) -> String {
  let s = val.to_string()
  if s.ends_with(".0") {
    s.substring(start=0, end=s.length() - 2) // trim ".0" suffix
  } else {
    s
  }
}

test "translate" {
  let d = "M507 24L48 24L48 530L395 530L395 625L48 625L48 723L507 723L507 24ZM395 269L395 433L138 433L138 269L395 269Z"
  let got = translate_path!(d, 1000.0, 2000.0)
  let want = "M1507 2024L1048 2024L1048 2530L1395 2530L1395 2625L1048 2625L1048 2723L1507 2723L1507 2024ZM1395 2269L1395 2433L1138 2433L1138 2269L1395 2269Z"
  assert_eq!(got, want)
}

test "translate with invert_y=true" {
  let d = "M507 24L48 24L48 530L395 530L395 625L48 625L48 723L507 723L507 24ZM395 269L395 433L138 433L138 269L395 269Z"
  let got = translate_path!(d, 1000.0, 2000.0, invert_y=true)
  let want = "M1507 1976L1048 1976L1048 1470L1395 1470L1395 1375L1048 1375L1048 1277L1507 1277L1507 1976ZM1395 1731L1395 1567L1138 1567L1138 1731L1395 1731Z"
  assert_eq!(got, want)
}
