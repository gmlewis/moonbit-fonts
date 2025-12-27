///|
fn main {
  let name = "GLENN"
  let font = @baloo.font
  match generate_voronoi_glass(font, name) {
    Ok(graphic) => {
      let svg_str = @svg.from_graphic(
        graphic
        .with_margin(top=0.2, right=0.2, bottom=0.2, left=0.2)
        .with_background(@draw.Color::black()),
        y_up=false,
      )
      println(svg_str)
    }
    Err(e) => println("Error: \{e}")
  }
}

///|
fn generate_voronoi_glass(
  font : @fonts.Font,
  name : String,
) -> Result[@draw.Graphic, @draw.DrawError] {
  let prng = PRNG::new(hash_string(name))

  // 1. Get text profiles (polygons)
  let text_graphic = @draw.text(font, name, size=1.0) catch {
    e => return Err(e)
  }
  let profiles = text_graphic.to_profiles(5)
  let bbox = text_graphic.bounding_box().unwrap_or(@geom.BoundingBox::new())
  let frame = bbox.inset(-0.3)

  // 2. Generate seed points
  let seeds : Array[@geom.Vec2] = []

  // Sample from text paths (Reverted to every 3rd point for cleaner look)
  for p in profiles {
    let outer = p.0
    for i in 0..<outer.length() {
      if i % 3 == 0 {
        seeds.push(outer[i])
      }
    }
    for hole in p.1 {
      for i in 0..<hole.length() {
        if i % 3 == 0 {
          seeds.push(hole[i])
        }
      }
    }
  }

  // Add background seeds (Reverted to 50 for clarity)
  for _ in 0..<50 {
    seeds.push(
      @geom.vec2(
        frame.min.x + prng.next_double() * frame.width(),
        frame.min.y + prng.next_double() * frame.height(),
      ),
    )
  }

  // 3. Compute Voronoi cells (brute force clipping)
  let mut glass = @draw.Graphic::Group({ items: [] })
  for i in 0..<seeds.length() {
    let seed = seeds[i]

    // Compute cell by clipping frame with bisectors of all other seeds
    let mut cell_poly = [
      frame.min.clone(),
      @geom.vec2(frame.max.x, frame.min.y),
      frame.max.clone(),
      @geom.vec2(frame.min.x, frame.max.y),
    ]
    for j in 0..<seeds.length() {
      if i == j {
        continue
      }
      let other = seeds[j]
      cell_poly = clip_polygon_by_bisector(cell_poly, seed, other)
    }
    if cell_poly.length() >= 3 {
      let is_inside = is_point_in_profiles(seed, profiles)
      // Reverted to original high-impact Blue vs Gold logic
      let base_hue = if is_inside { 0.6 } else { 0.05 }
      let color = @draw.Color::from_hsva(
        base_hue + prng.next_double() * 0.1,
        0.6 + prng.next_double() * 0.2,
        0.7 + prng.next_double() * 0.3,
        0.9,
      )
      let path = @draw.Path::from_points(cell_poly, closed=true)
        .as_graphic()
        .with_style(
          fill=color.as_fill(),
          stroke=@draw.Color::new(r=0.1, g=0.1, b=0.1).as_stroke(width=0.01),
        )
      glass = glass + path
    }
  }
  Ok(glass)
}

///|
fn clip_polygon_by_bisector(
  poly : Array[@geom.Vec2],
  p1 : @geom.Vec2,
  p2 : @geom.Vec2,
) -> Array[@geom.Vec2] {
  let result = []
  if poly.length() == 0 {
    return []
  }
  let normal = p2.sub(p1)
  let mid = p1.add(p2).mul_scalar(0.5)
  let is_inside = fn(p : @geom.Vec2) { p.sub(mid).dot(normal) <= 0.0 }
  for i in 0..<poly.length() {
    let a = poly[i]
    let b = poly[(i + 1) % poly.length()]
    let a_in = is_inside(a)
    let b_in = is_inside(b)
    if a_in {
      if b_in {
        result.push(b)
      } else {
        result.push(intersect_line_bisector(a, b, mid, normal))
      }
    } else if b_in {
      result.push(intersect_line_bisector(a, b, mid, normal))
      result.push(b)
    }
  }
  result
}

///|
fn intersect_line_bisector(
  a : @geom.Vec2,
  b : @geom.Vec2,
  mid : @geom.Vec2,
  normal : @geom.Vec2,
) -> @geom.Vec2 {
  let dir = b.sub(a)
  let denom = dir.dot(normal)
  if denom.abs() < 1.e-9 {
    return a
  }
  let t = mid.sub(a).dot(normal) / denom
  a.add(dir.mul_scalar(t))
}

///|
fn is_point_in_profiles(
  pt : @geom.Vec2,
  profiles : Array[(Array[@geom.Vec2], Array[Array[@geom.Vec2]])],
) -> Bool {
  for p in profiles {
    let (outer, holes) = p
    if is_point_in_poly(pt, outer) {
      let mut in_hole = false
      for hole in holes {
        if is_point_in_poly(pt, hole) {
          in_hole = true
          break
        }
      }
      if not(in_hole) {
        return true
      }
    }
  }
  false
}

///|
fn hash_string(s : String) -> UInt {
  let mut h = 0U
  for i in 0..<s.length() {
    h = h * 31U + s[i].to_int().reinterpret_as_uint()
  }
  h
}

///|
struct PRNG {
  mut state : UInt
}

///|
fn PRNG::new(seed : UInt) -> PRNG {
  { state: seed }
}

///|
fn PRNG::next(self : PRNG) -> UInt {
  self.state = self.state * 1103515245U + 12345U
  self.state
}

///|
fn PRNG::next_double(self : PRNG) -> Double {
  (self.next() & 0x7FFFFFFFU).to_double() / 2147483647.0
}

///|
fn is_point_in_poly(pt : @draw.Vec2, poly : Array[@draw.Vec2]) -> Bool {
  let mut inside = false
  let n = poly.length()
  for i in 0..<n {
    let p1 = poly[i]
    let p2 = poly[(i + 1) % n]
    if (p1.y > pt.y) != (p2.y > pt.y) &&
      pt.x < (p2.x - p1.x) * (pt.y - p1.y) / (p2.y - p1.y) + p1.x {
      inside = not(inside)
    }
  }
  inside
}
