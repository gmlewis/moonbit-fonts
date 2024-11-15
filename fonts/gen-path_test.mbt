let glyphs : Map[String, @fonts.Glyph] = {
  "A": {
    char: "A",
    horiz_adv_x: 0.0,
    gerber_lp: "dc",
    d: "M507 24L48 24L48 530L395 530L395 625L48 625L48 723L507 723L507 24ZM395 269L395 433L138 433L138 269L395 269Z",
    xmin: 48.0,
    ymin: 24.0,
    xmax: 507.0,
    ymax: 723.0,
  },
  "B": {
    char: "B",
    horiz_adv_x: 0.0,
    gerber_lp: "dc",
    d: "M507 21L48 21L48 723L160 723L160 530L507 530L507 21ZM417 269L417 433L160 433L160 269L417 269Z",
    xmin: 48.0,
    ymin: 21.0,
    xmax: 507.0,
    ymax: 723.0,
  },
  "C": {
    char: "C",
    horiz_adv_x: 0.0,
    gerber_lp: "d",
    d: "M507 21L48 21L48 723L507 723L507 625L160 625L160 269L507 269L507 21Z",
    xmin: 48.0,
    ymin: 21.0,
    xmax: 507.0,
    ymax: 723.0,
  },
}

let nullpointer : @fonts.Font = {
  id: "nullpointer",
  horiz_adv_x: 540.0,
  units_per_em: 1000.0,
  ascent: 800.0,
  descent: -200.0,
  glyphs,
}

struct GenPathTestCase {
  name : String
  anchor : @fonts.Anchor
  y_up : Bool
  want_d : String
}

let test_cases : Array[GenPathTestCase] = [
  {
    name: "top left",
    anchor: TopLeft,
    y_up: false,
    want_d: "M459 -699L0 -699L0 -193L347 -193L347 -98L0 -98L0 0L459 0L459 -699ZM347 -454L347 -290L90 -290L90 -454L347 -454ZM999 -702L540 -702L540 0L652 0L652 -193L999 -193L999 -702ZM909 -454L909 -290L652 -290L652 -454L909 -454ZM1539 -702L1080 -702L1080 0L1539 0L1539 -98L1192 -98L1192 -454L1539 -454L1539 -702ZM459 -1902L0 -1902L0 -1200L112 -1200L112 -1393L459 -1393L459 -1902ZM369 -1654L369 -1490L112 -1490L112 -1654L369 -1654ZM999 -1902L540 -1902L540 -1200L999 -1200L999 -1298L652 -1298L652 -1654L999 -1654L999 -1902ZM1539 -3102L1080 -3102L1080 -2400L1539 -2400L1539 -2498L1192 -2498L1192 -2854L1539 -2854L1539 -3102Z",
  },
  {
    name: "top left with y_up",
    anchor: TopLeft,
    y_up: true,
    want_d: "M459 699L0 699L0 193L347 193L347 98L0 98L0 0L459 0L459 699ZM347 454L347 290L90 290L90 454L347 454ZM999 702L540 702L540 0L652 0L652 193L999 193L999 702ZM909 454L909 290L652 290L652 454L909 454ZM1539 702L1080 702L1080 0L1539 0L1539 98L1192 98L1192 454L1539 454L1539 702ZM459 1902L0 1902L0 1200L112 1200L112 1393L459 1393L459 1902ZM369 1654L369 1490L112 1490L112 1654L369 1654ZM999 1902L540 1902L540 1200L999 1200L999 1298L652 1298L652 1654L999 1654L999 1902ZM1539 3102L1080 3102L1080 2400L1539 2400L1539 2498L1192 2498L1192 2854L1539 2854L1539 3102Z",
  },
]

test "gen_path on test_cases" {
  for tc in test_cases {
    let got = nullpointer.gen_path!(
      "ABC\nBC\rC",
      anchor=tc.anchor,
      y_up=tc.y_up,
    )
    try {
      assert_eq!(got.d, tc.want_d)
      assert_eq!(got.gerber_lp, "dcdcddcdd")
      assert_eq!(got.char, "ABC\nBC\rC")
      let bbox = @fonts.bbox!(got.d)
      assert_eq!(got.xmin, bbox.min.x)
      assert_eq!(got.ymin, bbox.min.y)
      assert_eq!(got.xmax, bbox.max.x)
      assert_eq!(got.ymax, bbox.max.y)
    } catch {
      e => {
        println("test case '\{tc.name}' failure:")
        raise e
      }
    }
  }
}

// test "gen_path on some simple glyphs using default settings" {
//   let got = nullpointer.gen_path!("ABC\nBC\rC")
//   let want = "M507 24L48 24L48 530L395 530L395 625L48 625L48 723L507 723L507 24ZM395 269L395 433L138 433L138 269L395 269ZM1047 21L588 21L588 723L700 723L700 530L1047 530L1047 21ZM957 269L957 433L700 433L700 269L957 269ZM1587 21L1128 21L1128 723L1587 723L1587 625L1240 625L1240 269L1587 269L1587 21ZM507 -1179L48 -1179L48 -477L160 -477L160 -670L507 -670L507 -1179ZM417 -931L417 -767L160 -767L160 -931L417 -931ZM1047 -1179L588 -1179L588 -477L1047 -477L1047 -575L700 -575L700 -931L1047 -931L1047 -1179ZM1587 -2379L1128 -2379L1128 -1677L1587 -1677L1587 -1775L1240 -1775L1240 -2131L1587 -2131L1587 -2379Z"
//   assert_eq!(got.d, want)
//   assert_eq!(got.gerber_lp, "dcdcddcdd")
//   assert_eq!(got.char, "ABC\nBC\rC")
//   assert_eq!(got.xmin, 48.0)
//   assert_eq!(got.ymin, -2379.0)
//   assert_eq!(got.xmax, 1587.0)
//   assert_eq!(got.ymax, 723.0)
// }

// test "gen_path on some simple glyphs with vertical centering" {
//   let got = nullpointer.gen_path!("ABC\nBC\rC", center_y=true)
//   let want = "M507 852L48 852L48 1358L395 1358L395 1453L48 1453L48 1551L507 1551L507 852ZM395 1097L395 1261L138 1261L138 1097L395 1097ZM1047 849L588 849L588 1551L700 1551L700 1358L1047 1358L1047 849ZM957 1097L957 1261L700 1261L700 1097L957 1097ZM1587 849L1128 849L1128 1551L1587 1551L1587 1453L1240 1453L1240 1097L1587 1097L1587 849ZM507 -351L48 -351L48 351L160 351L160 158L507 158L507 -351ZM417 -103L417 61L160 61L160 -103L417 -103ZM1047 -351L588 -351L588 351L1047 351L1047 253L700 253L700 -103L1047 -103L1047 -351ZM1587 -1551L1128 -1551L1128 -849L1587 -849L1587 -947L1240 -947L1240 -1303L1587 -1303L1587 -1551Z"
//   assert_eq!(got.d, want)
//   assert_eq!(got.gerber_lp, "dcdcddcdd")
//   assert_eq!(got.char, "ABC\nBC\rC")
//   assert_eq!(got.xmin, 48.0)
//   assert_eq!(got.ymin, -1551.0)
//   assert_eq!(got.xmax, 1587.0)
//   assert_eq!(got.ymax, 1551.0)
// }

// test "gen_path on some simple glyphs with horizontal centering" {
//   let got = nullpointer.gen_path!("ABC\nBC\rC", center_x=true)
//   let want = "M-310.5 24L-769.5 24L-769.5 530L-422.5 530L-422.5 625L-769.5 625L-769.5 723L-310.5 723L-310.5 24ZM-422.5 269L-422.5 433L-679.5 433L-679.5 269L-422.5 269ZM229.5 21L-229.5 21L-229.5 723L-117.5 723L-117.5 530L229.5 530L229.5 21ZM139.5 269L139.5 433L-117.5 433L-117.5 269L139.5 269ZM769.5 21L310.5 21L310.5 723L769.5 723L769.5 625L422.5 625L422.5 269L769.5 269L769.5 21ZM-310.5 -1179L-769.5 -1179L-769.5 -477L-657.5 -477L-657.5 -670L-310.5 -670L-310.5 -1179ZM-400.5 -931L-400.5 -767L-657.5 -767L-657.5 -931L-400.5 -931ZM229.5 -1179L-229.5 -1179L-229.5 -477L229.5 -477L229.5 -575L-117.5 -575L-117.5 -931L229.5 -931L229.5 -1179ZM769.5 -2379L310.5 -2379L310.5 -1677L769.5 -1677L769.5 -1775L422.5 -1775L422.5 -2131L769.5 -2131L769.5 -2379Z"
//   assert_eq!(got.d, want)
//   assert_eq!(got.gerber_lp, "dcdcddcdd")
//   assert_eq!(got.char, "ABC\nBC\rC")
//   assert_eq!(got.xmin, -769.5)
//   assert_eq!(got.ymin, -2379.0)
//   assert_eq!(got.xmax, 769.5)
//   assert_eq!(got.ymax, 723.0)
// }

// test "gen_path on some simple glyphs with horizontal and vertical centering" {
//   let got = nullpointer.gen_path!("ABC\nBC\rC", center_x=true, center_y=true)
//   let want = "M-310.5 852L-769.5 852L-769.5 1358L-422.5 1358L-422.5 1453L-769.5 1453L-769.5 1551L-310.5 1551L-310.5 852ZM-422.5 1097L-422.5 1261L-679.5 1261L-679.5 1097L-422.5 1097ZM229.5 849L-229.5 849L-229.5 1551L-117.5 1551L-117.5 1358L229.5 1358L229.5 849ZM139.5 1097L139.5 1261L-117.5 1261L-117.5 1097L139.5 1097ZM769.5 849L310.5 849L310.5 1551L769.5 1551L769.5 1453L422.5 1453L422.5 1097L769.5 1097L769.5 849ZM-310.5 -351L-769.5 -351L-769.5 351L-657.5 351L-657.5 158L-310.5 158L-310.5 -351ZM-400.5 -103L-400.5 61L-657.5 61L-657.5 -103L-400.5 -103ZM229.5 -351L-229.5 -351L-229.5 351L229.5 351L229.5 253L-117.5 253L-117.5 -103L229.5 -103L229.5 -351ZM769.5 -1551L310.5 -1551L310.5 -849L769.5 -849L769.5 -947L422.5 -947L422.5 -1303L769.5 -1303L769.5 -1551Z"
//   assert_eq!(got.d, want)
//   assert_eq!(got.gerber_lp, "dcdcddcdd")
//   assert_eq!(got.char, "ABC\nBC\rC")
//   assert_eq!(got.xmin, -769.5)
//   assert_eq!(got.ymin, -1551.0)
//   assert_eq!(got.xmax, 769.5)
//   assert_eq!(got.ymax, 1551.0)
// }

// test "gen_path on some simple glyphs with y_up=true" {
//   let got = nullpointer.gen_path!("ABC\nBC\rC", y_up=true)
//   let want = "M507 -24L48 -24L48 -530L395 -530L395 -625L48 -625L48 -723L507 -723L507 -24ZM395 -269L395 -433L138 -433L138 -269L395 -269ZM1047 -21L588 -21L588 -723L700 -723L700 -530L1047 -530L1047 -21ZM957 -269L957 -433L700 -433L700 -269L957 -269ZM1587 -21L1128 -21L1128 -723L1587 -723L1587 -625L1240 -625L1240 -269L1587 -269L1587 -21ZM507 1179L48 1179L48 477L160 477L160 670L507 670L507 1179ZM417 931L417 767L160 767L160 931L417 931ZM1047 1179L588 1179L588 477L1047 477L1047 575L700 575L700 931L1047 931L1047 1179ZM1587 2379L1128 2379L1128 1677L1587 1677L1587 1775L1240 1775L1240 2131L1587 2131L1587 2379Z"
//   assert_eq!(got.d, want)
//   assert_eq!(got.gerber_lp, "dcdcddcdd")
//   assert_eq!(got.char, "ABC\nBC\rC")
//   assert_eq!(got.xmin, 48.0)
//   assert_eq!(got.ymin, -24.0)
//   assert_eq!(got.xmax, 1587.0)
//   assert_eq!(got.ymax, 2379.0)
// }

// test "gen_path on some simple glyphs with vertical centering and y_up=true" {
//   let got = nullpointer.gen_path!("ABC\nBC\rC", center_y=true, y_up=true)
//   let want = "M507 852L48 852L48 1358L395 1358L395 1453L48 1453L48 1551L507 1551L507 852ZM395 1097L395 1261L138 1261L138 1097L395 1097ZM1047 849L588 849L588 1551L700 1551L700 1358L1047 1358L1047 849ZM957 1097L957 1261L700 1261L700 1097L957 1097ZM1587 849L1128 849L1128 1551L1587 1551L1587 1453L1240 1453L1240 1097L1587 1097L1587 849ZM507 -351L48 -351L48 351L160 351L160 158L507 158L507 -351ZM417 -103L417 61L160 61L160 -103L417 -103ZM1047 -351L588 -351L588 351L1047 351L1047 253L700 253L700 -103L1047 -103L1047 -351ZM1587 -1551L1128 -1551L1128 -849L1587 -849L1587 -947L1240 -947L1240 -1303L1587 -1303L1587 -1551Z"
//   assert_eq!(got.d, want)
//   assert_eq!(got.gerber_lp, "dcdcddcdd")
//   assert_eq!(got.char, "ABC\nBC\rC")
//   assert_eq!(got.xmin, 48.0)
//   assert_eq!(got.ymin, -1551.0)
//   assert_eq!(got.xmax, 1587.0)
//   assert_eq!(got.ymax, 1551.0)
// }

// test "gen_path on some simple glyphs with horizontal centering and y_up=true" {
//   let got = nullpointer.gen_path!("ABC\nBC\rC", center_x=true, y_up=true)
//   let want = "M-310.5 24L-769.5 24L-769.5 530L-422.5 530L-422.5 625L-769.5 625L-769.5 723L-310.5 723L-310.5 24ZM-422.5 269L-422.5 433L-679.5 433L-679.5 269L-422.5 269ZM229.5 21L-229.5 21L-229.5 723L-117.5 723L-117.5 530L229.5 530L229.5 21ZM139.5 269L139.5 433L-117.5 433L-117.5 269L139.5 269ZM769.5 21L310.5 21L310.5 723L769.5 723L769.5 625L422.5 625L422.5 269L769.5 269L769.5 21ZM-310.5 -1179L-769.5 -1179L-769.5 -477L-657.5 -477L-657.5 -670L-310.5 -670L-310.5 -1179ZM-400.5 -931L-400.5 -767L-657.5 -767L-657.5 -931L-400.5 -931ZM229.5 -1179L-229.5 -1179L-229.5 -477L229.5 -477L229.5 -575L-117.5 -575L-117.5 -931L229.5 -931L229.5 -1179ZM769.5 -2379L310.5 -2379L310.5 -1677L769.5 -1677L769.5 -1775L422.5 -1775L422.5 -2131L769.5 -2131L769.5 -2379Z"
//   assert_eq!(got.d, want)
//   assert_eq!(got.gerber_lp, "dcdcddcdd")
//   assert_eq!(got.char, "ABC\nBC\rC")
//   assert_eq!(got.xmin, -769.5)
//   assert_eq!(got.ymin, -2379.0)
//   assert_eq!(got.xmax, 769.5)
//   assert_eq!(got.ymax, 723.0)
// }

// test "gen_path on some simple glyphs with horizontal and vertical centering and y_up=true" {
//   let got = nullpointer.gen_path!(
//     "ABC\nBC\rC",
//     center_x=true,
//     center_y=true,
//     y_up=true,
//   )
//   let want = "M-310.5 852L-769.5 852L-769.5 1358L-422.5 1358L-422.5 1453L-769.5 1453L-769.5 1551L-310.5 1551L-310.5 852ZM-422.5 1097L-422.5 1261L-679.5 1261L-679.5 1097L-422.5 1097ZM229.5 849L-229.5 849L-229.5 1551L-117.5 1551L-117.5 1358L229.5 1358L229.5 849ZM139.5 1097L139.5 1261L-117.5 1261L-117.5 1097L139.5 1097ZM769.5 849L310.5 849L310.5 1551L769.5 1551L769.5 1453L422.5 1453L422.5 1097L769.5 1097L769.5 849ZM-310.5 -351L-769.5 -351L-769.5 351L-657.5 351L-657.5 158L-310.5 158L-310.5 -351ZM-400.5 -103L-400.5 61L-657.5 61L-657.5 -103L-400.5 -103ZM229.5 -351L-229.5 -351L-229.5 351L229.5 351L229.5 253L-117.5 253L-117.5 -103L229.5 -103L229.5 -351ZM769.5 -1551L310.5 -1551L310.5 -849L769.5 -849L769.5 -947L422.5 -947L422.5 -1303L769.5 -1303L769.5 -1551Z"
//   assert_eq!(got.d, want)
//   assert_eq!(got.gerber_lp, "dcdcddcdd")
//   assert_eq!(got.char, "ABC\nBC\rC")
//   assert_eq!(got.xmin, -769.5)
//   assert_eq!(got.ymin, -1551.0)
//   assert_eq!(got.xmax, 769.5)
//   assert_eq!(got.ymax, 1551.0)
// }

// test "center_lines on some simple glyphs using default settings" {
//   let got = nullpointer.center_lines!(["ABC", "BC", "C"])
//   let want = "M507 24L48 24L48 530L395 530L395 625L48 625L48 723L507 723L507 24ZM395 269L395 433L138 433L138 269L395 269ZM1047 21L588 21L588 723L700 723L700 530L1047 530L1047 21ZM957 269L957 433L700 433L700 269L957 269ZM1587 21L1128 21L1128 723L1587 723L1587 625L1240 625L1240 269L1587 269L1587 21ZM507 -1179L48 -1179L48 -477L160 -477L160 -670L507 -670L507 -1179ZM417 -931L417 -767L160 -767L160 -931L417 -931ZM1047 -1179L588 -1179L588 -477L1047 -477L1047 -575L700 -575L700 -931L1047 -931L1047 -1179ZM1587 -2379L1128 -2379L1128 -1677L1587 -1677L1587 -1775L1240 -1775L1240 -2131L1587 -2131L1587 -2379Z"
//   assert_eq!(got.d, want)
//   assert_eq!(got.gerber_lp, "dcdcddcdd")
//   assert_eq!(got.char, "ABC\nBC\rC")
//   assert_eq!(got.xmin, 48.0)
//   assert_eq!(got.ymin, -2379.0)
//   assert_eq!(got.xmax, 1587.0)
//   assert_eq!(got.ymax, 723.0)
// }

// test "center_lines on some simple glyphs with vertical centering" {
//   let got = nullpointer.center_lines!(["ABC", "BC", "C"], center_y=true)
//   let want = "M507 852L48 852L48 1358L395 1358L395 1453L48 1453L48 1551L507 1551L507 852ZM395 1097L395 1261L138 1261L138 1097L395 1097ZM1047 849L588 849L588 1551L700 1551L700 1358L1047 1358L1047 849ZM957 1097L957 1261L700 1261L700 1097L957 1097ZM1587 849L1128 849L1128 1551L1587 1551L1587 1453L1240 1453L1240 1097L1587 1097L1587 849ZM507 -351L48 -351L48 351L160 351L160 158L507 158L507 -351ZM417 -103L417 61L160 61L160 -103L417 -103ZM1047 -351L588 -351L588 351L1047 351L1047 253L700 253L700 -103L1047 -103L1047 -351ZM1587 -1551L1128 -1551L1128 -849L1587 -849L1587 -947L1240 -947L1240 -1303L1587 -1303L1587 -1551Z"
//   assert_eq!(got.d, want)
//   assert_eq!(got.gerber_lp, "dcdcddcdd")
//   assert_eq!(got.char, "ABC\nBC\rC")
//   assert_eq!(got.xmin, 48.0)
//   assert_eq!(got.ymin, -1551.0)
//   assert_eq!(got.xmax, 1587.0)
//   assert_eq!(got.ymax, 1551.0)
// }

// test "center_lines on some simple glyphs with horizontal and vertical centering" {
//   let got = nullpointer.center_lines!(["ABC", "BC", "C"], center_y=true)
//   let want = "M-310.5 852L-769.5 852L-769.5 1358L-422.5 1358L-422.5 1453L-769.5 1453L-769.5 1551L-310.5 1551L-310.5 852ZM-422.5 1097L-422.5 1261L-679.5 1261L-679.5 1097L-422.5 1097ZM229.5 849L-229.5 849L-229.5 1551L-117.5 1551L-117.5 1358L229.5 1358L229.5 849ZM139.5 1097L139.5 1261L-117.5 1261L-117.5 1097L139.5 1097ZM769.5 849L310.5 849L310.5 1551L769.5 1551L769.5 1453L422.5 1453L422.5 1097L769.5 1097L769.5 849ZM-310.5 -351L-769.5 -351L-769.5 351L-657.5 351L-657.5 158L-310.5 158L-310.5 -351ZM-400.5 -103L-400.5 61L-657.5 61L-657.5 -103L-400.5 -103ZM229.5 -351L-229.5 -351L-229.5 351L229.5 351L229.5 253L-117.5 253L-117.5 -103L229.5 -103L229.5 -351ZM769.5 -1551L310.5 -1551L310.5 -849L769.5 -849L769.5 -947L422.5 -947L422.5 -1303L769.5 -1303L769.5 -1551Z"
//   assert_eq!(got.d, want)
//   assert_eq!(got.gerber_lp, "dcdcddcdd")
//   assert_eq!(got.char, "ABC\nBC\rC")
//   assert_eq!(got.xmin, -769.5)
//   assert_eq!(got.ymin, -1551.0)
//   assert_eq!(got.xmax, 769.5)
//   assert_eq!(got.ymax, 1551.0)
// }

// test "center_lines on some simple glyphs with y_up=true" {
//   let got = nullpointer.center_lines!(["ABC", "BC", "C"], y_up=true)
//   let want = "M507 24L48 24L48 530L395 530L395 625L48 625L48 723L507 723L507 24ZM395 269L395 433L138 433L138 269L395 269ZM1047 21L588 21L588 723L700 723L700 530L1047 530L1047 21ZM957 269L957 433L700 433L700 269L957 269ZM1587 21L1128 21L1128 723L1587 723L1587 625L1240 625L1240 269L1587 269L1587 21ZM507 -1179L48 -1179L48 -477L160 -477L160 -670L507 -670L507 -1179ZM417 -931L417 -767L160 -767L160 -931L417 -931ZM1047 -1179L588 -1179L588 -477L1047 -477L1047 -575L700 -575L700 -931L1047 -931L1047 -1179ZM1587 -2379L1128 -2379L1128 -1677L1587 -1677L1587 -1775L1240 -1775L1240 -2131L1587 -2131L1587 -2379Z"
//   assert_eq!(got.d, want)
//   assert_eq!(got.gerber_lp, "dcdcddcdd")
//   assert_eq!(got.char, "ABC\nBC\rC")
//   assert_eq!(got.xmin, 48.0)
//   assert_eq!(got.ymin, -2379.0)
//   assert_eq!(got.xmax, 1587.0)
//   assert_eq!(got.ymax, 723.0)
// }

// test "center_lines on some simple glyphs with vertical centering and y_up=true" {
//   let got = nullpointer.center_lines!(
//     ["ABC", "BC", "C"],
//     center_y=true,
//     y_up=true,
//   )
//   let want = "M507 852L48 852L48 1358L395 1358L395 1453L48 1453L48 1551L507 1551L507 852ZM395 1097L395 1261L138 1261L138 1097L395 1097ZM1047 849L588 849L588 1551L700 1551L700 1358L1047 1358L1047 849ZM957 1097L957 1261L700 1261L700 1097L957 1097ZM1587 849L1128 849L1128 1551L1587 1551L1587 1453L1240 1453L1240 1097L1587 1097L1587 849ZM507 -351L48 -351L48 351L160 351L160 158L507 158L507 -351ZM417 -103L417 61L160 61L160 -103L417 -103ZM1047 -351L588 -351L588 351L1047 351L1047 253L700 253L700 -103L1047 -103L1047 -351ZM1587 -1551L1128 -1551L1128 -849L1587 -849L1587 -947L1240 -947L1240 -1303L1587 -1303L1587 -1551Z"
//   assert_eq!(got.d, want)
//   assert_eq!(got.gerber_lp, "dcdcddcdd")
//   assert_eq!(got.char, "ABC\nBC\rC")
//   assert_eq!(got.xmin, 48.0)
//   assert_eq!(got.ymin, -1551.0)
//   assert_eq!(got.xmax, 1587.0)
//   assert_eq!(got.ymax, 1551.0)
// }

// test "center_lines on some simple glyphs with horizontal and vertical centering and y_up=true" {
//   let got = nullpointer.center_lines!(
//     ["ABC", "BC", "C"],
//     center_y=true,
//     y_up=true,
//   )
//   let want = "M-310.5 852L-769.5 852L-769.5 1358L-422.5 1358L-422.5 1453L-769.5 1453L-769.5 1551L-310.5 1551L-310.5 852ZM-422.5 1097L-422.5 1261L-679.5 1261L-679.5 1097L-422.5 1097ZM229.5 849L-229.5 849L-229.5 1551L-117.5 1551L-117.5 1358L229.5 1358L229.5 849ZM139.5 1097L139.5 1261L-117.5 1261L-117.5 1097L139.5 1097ZM769.5 849L310.5 849L310.5 1551L769.5 1551L769.5 1453L422.5 1453L422.5 1097L769.5 1097L769.5 849ZM-310.5 -351L-769.5 -351L-769.5 351L-657.5 351L-657.5 158L-310.5 158L-310.5 -351ZM-400.5 -103L-400.5 61L-657.5 61L-657.5 -103L-400.5 -103ZM229.5 -351L-229.5 -351L-229.5 351L229.5 351L229.5 253L-117.5 253L-117.5 -103L229.5 -103L229.5 -351ZM769.5 -1551L310.5 -1551L310.5 -849L769.5 -849L769.5 -947L422.5 -947L422.5 -1303L769.5 -1303L769.5 -1551Z"
//   assert_eq!(got.d, want)
//   assert_eq!(got.gerber_lp, "dcdcddcdd")
//   assert_eq!(got.char, "ABC\nBC\rC")
//   assert_eq!(got.xmin, -769.5)
//   assert_eq!(got.ymin, -1551.0)
//   assert_eq!(got.xmax, 769.5)
//   assert_eq!(got.ymax, 1551.0)
// }
