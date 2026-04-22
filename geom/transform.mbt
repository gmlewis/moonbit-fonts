///|
/// `Transform` represents transform arguments.
pub(all) struct Transform {
  position : Vec2
  rotation : Double
  scale : Vec2
  skew : Double
  origin : Vec2
} derive(Eq)

///|
pub impl Show for Transform with output(self, logger) {
  let { position, rotation, scale, skew, origin } = self
  logger.write_string(
    (
      $|{position: \{position}, rotation: \{rotation}, scale: \{scale}, skew: \{skew}, origin: \{origin}}
    ),
  )
}

///|
test "Transform show interface" {
  let t = Transform::new(position=vec2(10, 20), rotation=45, scale=vec2(2, 2))
  inspect(
    t,
    content=(
      #|{position: {x: 10, y: 20}, rotation: 45, scale: {x: 2, y: 2}, skew: 0, origin: {x: 0, y: 0}}
    ),
  )
}

///|
/// Transform::new returns a new identity transform.
pub fn Transform::new(
  position? : Vec2 = vec2(0, 0),
  rotation? : Double = 0,
  scale? : Vec2 = vec2(1, 1),
  skew? : Double = 0,
  origin? : Vec2 = vec2(0, 0),
) -> Transform {
  { position, rotation, scale, skew, origin }
}
