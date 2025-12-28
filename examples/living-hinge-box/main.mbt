///|
fn main {
  let name = "BEND"
  let font = @aaarghnormal.font

  match generate_living_hinge_box(font, name) {
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
fn generate_living_hinge_box(
  font : @fonts.Font,
  name : String
) -> Result[@draw.Graphic, @draw.DrawError] {
  // Constants for the box
  let box_width = 4.0
  let box_height = 2.0
  let hinge_width = 1.0
  
  // 1. Create text to be integrated into the hinge
  // Use a smaller size to fit the narrow hinge
  let text_graphic = @draw.text(font, name, size=0.4) catch {
    e => return Err(e)
  }
  let bbox = text_graphic.bounding_box().unwrap_or(@geom.BoundingBox::new())
  
  // Center text EXACTLY in the hinge area
  let hinge_rect = @geom.bbox(box_width, 0.0, box_width + hinge_width, box_height)
  let hinge_center = hinge_rect.center()
  let text_center = bbox.center()
  
  // Shift text to hinge center
  let centered_text = text_graphic.translate(hinge_center.sub(text_center))
  let text_profiles = centered_text.to_profiles(5)

  // 2. Generate the lattice pattern for the hinge
  let mut result = @draw.Graphic::Group({ items: [] })
  
  // Draw the two main panels
  let panel1 = @draw.Path::from_points([
    @geom.vec2(0, 0), @geom.vec2(box_width, 0),
    @geom.vec2(box_width, box_height), @geom.vec2(0, box_height)
  ], closed=true).as_graphic().with_style(stroke=@draw.Color::black().as_stroke(width=0.02))
  
  let panel2 = @draw.Path::from_points([
    @geom.vec2(box_width + hinge_width, 0), @geom.vec2(2.0 * box_width + hinge_width, 0),
    @geom.vec2(2.0 * box_width + hinge_width, box_height), @geom.vec2(box_width + hinge_width, box_height)
  ], closed=true).as_graphic().with_style(stroke=@draw.Color::black().as_stroke(width=0.02))
  
  result = result + panel1 + panel2

  // 3. Lattice with integrated typography
  let rows = 30 // More rows for smoother bend
  let cols = 8
  let dx = hinge_width / cols.to_double()
  let dy = box_height / rows.to_double()
  
  for c in 0..<cols {
    let x = box_width + c.to_double() * dx + dx / 2.0
    for r in 0..<rows {
      let mut y = r.to_double() * dy
      if c % 2 == 1 {
        y += dy / 2.0
      }
      
      let p1 = @geom.vec2(x, y)
      let p2 = @geom.vec2(x, y + dy * 0.8)
      
      // Check if the cut intersects the text
      let mid = p1.add(p2).mul_scalar(0.5)
      if not(is_point_in_profiles(mid, text_profiles)) {
        let cut = @draw.Path::from_points([p1, p2], closed=false)
          .as_graphic()
          .with_style(stroke=@draw.Color::red().as_stroke(width=0.01))
        result = result + cut
      }
    }
  }

  // Add the text outlines as red cuts (for laser)
  result = result + centered_text.with_style(stroke=@draw.Color::red().as_stroke(width=0.01)).remove_fill()

  Ok(result)
}

///|
fn is_point_in_profiles(
  pt : @geom.Vec2,
  profiles : Array[(Array[@geom.Vec2], Array[Array[@geom.Vec2]])]
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
      if not(in_hole) { return true }
    }
  }
  false
}

///|
fn is_point_in_poly(pt : @geom.Vec2, poly : Array[@geom.Vec2]) -> Bool {
  let mut inside = false
  let n = poly.length()
  for i in 0..<n {
    let p1 = poly[i]
    let p2 = poly[(i + 1) % n]
    if ((p1.y > pt.y) != (p2.y > pt.y)) &&
       (pt.x < (p2.x - p1.x) * (pt.y - p1.y) / (p2.y - p1.y) + p1.x) {
      inside = not(inside)
    }
  }
  inside
}