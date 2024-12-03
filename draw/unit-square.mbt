///| unit_square constructs a new Group representing a unit square centered at the origin.
pub fn unit_square() -> Group {
  let c = 0.5
  let a1 = Anchor::new(position=vec2(-c, -c))
  let a2 = Anchor::new(position=vec2(c, -c))
  let a3 = Anchor::new(position=vec2(c, c))
  let a4 = Anchor::new(position=vec2(-c, c))
  Group::new(items=[Path(Path::new(anchors=[a1, a2, a3, a4], closed=true))])
}
