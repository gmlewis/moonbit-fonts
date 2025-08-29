///|
/// Transform represents transform arguments.
pub(all) struct Transform {
  position : Vec2
  rotation : Double
  scale : Vec2
  skew : Double
  origin : Vec2
} derive(Show, Eq)

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
