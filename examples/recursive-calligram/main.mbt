///|
fn main {
  let name = "MOON"
  let font = @aaarghnormal.font

  match generate_recursive_calligram(font, name) {
    Ok(graphic) => {
      let svg_str = @svg.from_graphic(
        graphic
        .with_margin(top=0.2, right=0.2, bottom=0.2, left=0.2)
        .with_background(@draw.Color::white()),
        y_up=false,
      )
      println(svg_str)
    }
    Err(e) => println("Error: \{e}")
  }
}

///|
fn generate_recursive_calligram(
  font : @fonts.Font,
  name : String
) -> Result[@draw.Graphic, @draw.DrawError] {
  let prng = PRNG::new(hash_string(name))
  
  // 1. Define the silhouette (large circle)
  let radius = 2.0
  let center = @geom.vec2(radius, radius)
  let silhouette = @draw.unit_circle().as_graphic().scale(@geom.vec2(radius * 2.0, radius * 2.0)).translate(center)
  
  let placed_boxes : Array[@geom.BoundingBox] = []
  let mut result = @draw.Graphic::Group({ items: [] })
  
  // 2. Recursive Packing
  let mut current_size = 0.8
  for _level in 0..<5 {
    for _attempt in 0..<50 {
      let angle = prng.next_double() * 360.0
      let dist = prng.next_double() * radius * 0.9
      let pos = @geom.vec2(
        center.x + dist * @math.cos(angle * @math.PI / 180.0),
        center.y + dist * @math.sin(angle * @math.PI / 180.0)
      )
      
      let rotation = prng.next_double() * 360.0
      let text_graphic = @draw.text(font, name, size=current_size) catch {
        _ => continue
      }
      
      let bbox = text_graphic.bounding_box().unwrap_or(@geom.BoundingBox::new())
      let centered_text = text_graphic
        .translate(-bbox.center())
        .rotate(rotation)
        .translate(pos)
      
      let new_bbox = centered_text.bounding_box().unwrap_or(@geom.BoundingBox::new())
      
      // Check if inside silhouette and doesn't overlap others
      if is_bbox_in_circle(new_bbox, center, radius) && not(overlaps_any(new_bbox, placed_boxes)) {
        let color = @draw.Color::from_hsva(prng.next_double(), 0.7, 0.5, 1.0)
        result = result + centered_text.with_style(fill=color.as_fill())
        placed_boxes.push(new_bbox)
      }
    }
    current_size *= 0.7
  }

  // Add the silhouette outline
  result = result + silhouette.with_style(stroke=@draw.Color::black().as_stroke(width=0.02)).remove_fill()

  Ok(result)
}

///|
fn is_bbox_in_circle(bbox : @geom.BoundingBox, center : @geom.Vec2, r : Double) -> Bool {
  let pts = [
    bbox.min,
    @geom.vec2(bbox.max.x, bbox.min.y),
    bbox.max,
    @geom.vec2(bbox.min.x, bbox.max.y)
  ]
  let r_sq = r * r
  for p in pts {
    if p.distance_squared(center) > r_sq {
      return false
    }
  }
  true
}

///|
fn overlaps_any(bbox : @geom.BoundingBox, others : Array[@geom.BoundingBox]) -> Bool {
  for other in others {
    if bbox.overlaps_bounding_box(other) {
      return true
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
struct PRNG { mut state : UInt }
fn PRNG::new(seed : UInt) -> PRNG { { state: seed } }
fn PRNG::next(self : PRNG) -> UInt { self.state = self.state * 1103515245U + 12345U; self.state }
fn PRNG::next_double(self : PRNG) -> Double { (self.next() & 0x7FFFFFFFU).to_double() / 2147483647.0 }