/// circle constructs a new Group representing a unit circle.
pub fn circle() -> Group {
  // https://en.wikipedia.org/wiki/Composite_B%C3%A9zier_curve#Approximating_circular_arcs
  let c = 0.2761423749 // k/2 where k ~= 0.5522847498
  let a1 = Anchor::new(
    position=vec2(0, -0.5),
    handle_in=vec2(-c, 0),
    handle_out=vec2(c, 0),
  )
  let a2 = Anchor::new(
    position=vec2(0.5, 0),
    handle_in=vec2(0, -c),
    handle_out=vec2(0, c),
  )
  let a3 = Anchor::new(
    position=vec2(0, 0.5),
    handle_in=vec2(c, 0),
    handle_out=vec2(-c, 0),
  )
  let a4 = Anchor::new(
    position=vec2(-0.5, 0),
    handle_in=vec2(0, c),
    handle_out=vec2(0, -c),
  )
  Group::new(items=[Path(Path::new(anchors=[a1, a2, a3, a4], closed=true))])
}
