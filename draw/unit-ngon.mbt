///|
/// unit_ngon constructs a new Group representing a polygon with
/// `sides` sides, each of length 1, centered at the origin.
/// If `sides` is less than 3, it defaults to 3.
pub fn unit_ngon(sides : Int, start_degrees? : Int = -90) -> Group {
  let sides = if sides < 3 { 3 } else { sides }
  let n = sides.to_double()
  let radius = 1.0 / (2.0 * @math.sin(@math.PI / n))
  let step = 2.0 * @math.PI / n
  let start = start_degrees.to_double() * @math.PI / 180.0
  let anchors = Array::makei(sides, fn(i) {
    let angle = start + step * i.to_double()
    let position = Vec2::from_angle_radians(angle).mul_scalar(radius)
    Anchor::new(position~)
  })
  Group::new(items=[Path(Path::new(anchors~, closed=true))])
}

///|
test "unit_ngon/table/3..8" {
  let eps = 1.e-6
  let cases = [3, 4, 5, 6, 7, 8]
  for sides in cases {
    let g = unit_ngon(sides)
    let paths = g.all_paths()
    inspect(paths.length(), content="1")
    let path = paths[0]
    inspect(path.closed, content="true")
    inspect(path.anchors.length() == sides, content="true")

    // Check that the vertices are centered around the origin.
    let mut sum_x = 0.0
    let mut sum_y = 0.0
    for a in path.anchors {
      sum_x += a.position.x
      sum_y += a.position.y
    }
    let centroid = vec2(sum_x / sides.to_double(), sum_y / sides.to_double())
    inspect(centroid.almost_equals(vec2(0, 0), tolerance=eps), content="true")

    // Check circumradius and that each edge length is 1.
    let n = sides.to_double()
    let radius = 1.0 / (2.0 * @math.sin(@math.PI / n))
    for i in 0..<sides {
      let j = (i + 1) % sides
      let p0 = path.anchors[i].position
      let p1 = path.anchors[j].position
      inspect((p0.length() - radius).abs() <= eps, content="true")
      inspect((p0.distance(p1) - 1.0).abs() <= eps, content="true")
    }
  }
}
