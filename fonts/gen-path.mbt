/// `gen_path` renders the provided text string into an SVG path
/// using the provided font information.
pub fn gen_path(self : Font, text : String) -> String!Error {
  let mut x = 0.0
  let mut y = 0.0
  let d = Buffer::new()
  iter_exn!(
    text.iter().collect(),
    fn(c) {
      match self.glyphs.get(c.to_string()) {
        Some(glyph) => {
          d.write_string(translate_path!(glyph.d, x, y))
          if glyph.horiz_adv_x > 0.0 {
            x = x + glyph.horiz_adv_x
          } else {
            x = x + self.horiz_adv_x
          }
        }
        None =>
          match c {
            '\x0a' => { // \n
              x = 0.0
              y = y - self.units_per_em + self.descent
            }
            '\x0d' => // \r
              y = y - self.units_per_em + self.descent
            _ => x = x + self.horiz_adv_x
          }
      }
    },
  )
  d.to_string()
}

fn iter_exn[T, Err : Error](arr : Array[T], iter : (T) -> Unit!Err) -> Unit!Err {
  for i = 0; i < arr.length(); i = i + 1 {
    iter!(arr[i])
  }
}

test "gen_path on some simple glyphs" {
  let glyphs = {
    "A": {
      char: "A",
      horiz_adv_x: 0.0,
      d: "M507 24L48 24L48 530L395 530L395 625L48 625L48 723L507 723L507 24ZM395 269L395 433L138 433L138 269L395 269Z",
      xmin: 48.0,
      ymin: 24.0,
      xmax: 507.0,
      ymax: 723.0,
    },
    "B": {
      char: "B",
      horiz_adv_x: 0.0,
      d: "M507 21L48 21L48 723L160 723L160 530L507 530L507 21ZM417 269L417 433L160 433L160 269L417 269Z",
      xmin: 48.0,
      ymin: 21.0,
      xmax: 507.0,
      ymax: 723.0,
    },
    "C": {
      char: "C",
      horiz_adv_x: 0.0,
      d: "M507 21L48 21L48 723L507 723L507 625L160 625L160 269L507 269L507 21Z",
      xmin: 48.0,
      ymin: 21.0,
      xmax: 507.0,
      ymax: 723.0,
    },
  }
  let nullpointer = {
    id: "nullpointer",
    horiz_adv_x: 540.0,
    units_per_em: 1000.0,
    ascent: 800.0,
    descent: -200.0,
    glyphs,
  }
  //
  let got = nullpointer.gen_path!("ABC\nBC\rC")
  let want = "M507 24L48 24L48 530L395 530L395 625L48 625L48 723L507 723L507 24ZM395 269L395 433L138 433L138 269L395 269ZM1047 21L588 21L588 723L700 723L700 530L1047 530L1047 21ZM957 269L957 433L700 433L700 269L957 269ZM1587 21L1128 21L1128 723L1587 723L1587 625L1240 625L1240 269L1587 269L1587 21ZM507 -1179L48 -1179L48 -477L160 -477L160 -670L507 -670L507 -1179ZM417 -931L417 -767L160 -767L160 -931L417 -931ZM1047 -1179L588 -1179L588 -477L1047 -477L1047 -575L700 -575L700 -931L1047 -931L1047 -1179ZM1587 -2379L1128 -2379L1128 -1677L1587 -1677L1587 -1775L1240 -1775L1240 -2131L1587 -2131L1587 -2379Z"
  assert_eq!(got, want)
}
