///|
/// Fill defines a fill style.
pub(all) struct Fill {
  color : Color
} derive(Show, Eq, FromJson, ToJson)

///|
/// Fill::new returns a new fill style.
pub fn Fill::new(color~ : Color = rgba(0, 0, 0, 1)) -> Fill {
  { color, }
}

///|
/// fill is a helper function.
pub fn fill(color : Color) -> Fill {
  { color, }
}

///|
/// clone returns a new copy of this Fill.
pub impl Clonable for Fill with clone(self) {
  { color: self.color.clone() }
}
