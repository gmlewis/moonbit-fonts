/// Stroke defines a stroke style.
pub(all) struct Stroke {
  color : Color
} derive(Show, Eq)

/// Stroke::new returns a new stroke style.
pub fn Stroke::new(color~ : Color = color(0, 0, 0, 1)) -> Stroke {
  { color, }
}

/// stroke is a helper function.
pub fn stroke(color : Color) -> Stroke {
  { color, }
}

/// clone returns a new copy of this Stroke.
pub fn clone(self : Stroke) -> Stroke {
  { color: self.color.clone() }
}
