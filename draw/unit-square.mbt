/// unit_square constructs a new Group representing a unit square centered at the origin.
pub fn unit_square() -> Group {
  let a1 = Anchor::new(position=vec2(0, -0.5))
  let a2 = Anchor::new(position=vec2(0.5, 0))
  let a3 = Anchor::new(position=vec2(0, 0.5))
  let a4 = Anchor::new(position=vec2(-0.5, 0))
  Group::new(items=[Path(Path::new(anchors=[a1, a2, a3, a4], closed=true))])
}
