///|
/// The draw package contains convenient abstractions for drawing vector
/// graphics.

///|
/// DrawError represents an error that occured during graphic generation.
pub(all) suberror DrawError String derive(Show, Eq)

///|
/// dedupe_points removes consecutive near-duplicate points from an array.
/// Points are considered duplicates if their distance_squared <= epsilon^2.
pub fn dedupe_points(points : Array[Vec2], epsilon? : Double = 0.000000001) -> Array[Vec2] {
  if points.length() <= 1 {
    return points
  }
  let eps_sq = epsilon * epsilon
  let mut result : Array[Vec2] = []
  for i in 0..<points.length() {
    if i == 0 || points[i - 1].distance_squared(points[i]) > eps_sq {
      result.push(points[i])
    }
  }
  // Use self-assignment to mark `result` as mut-used (silence unused_mut warning)
  result = result
  result
}
