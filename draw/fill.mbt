///|
/// `Fill` defines a fill style.
pub(all) struct Fill {
  color : Color
} derive(Eq, FromJson, ToJson)

///|
pub impl Show for Fill with output(self, logger) {
  let { color } = self
  logger.write_string(
    (
      $|{color: \{color}}
    ),
  )
}

///|
test "Fill show interface" {
  let fill = Fill::new(color=rgba(1, 0, 0, 1))
  inspect(
    fill,
    content=(
      #|{color: {r: 1, g: 0, b: 0, a: 1}}
    ),
  )
}

///|
/// `Fill::new` returns a new fill style.
pub fn Fill::new(color? : Color = rgba(0, 0, 0, 1)) -> Fill {
  { color, }
}

///|
/// `fill` is a helper function.
pub fn fill(color : Color) -> Fill {
  { color, }
}

///|
/// `Fill::from_string` returns a new fill style from a CSS color string.
pub fn Fill::from_string(css_string : String) -> Fill raise Error {
  { color: Color::from_css_string(css_string) }
}

///|
/// `clone` returns a new copy of this `Fill`.
pub impl Clonable for Fill with clone(self) {
  { color: self.color.clone() }
}
