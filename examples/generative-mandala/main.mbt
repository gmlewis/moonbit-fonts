///|
fn main {
  let name = "MoonBit"
  let font = @aaarghnormal.font

  match generate_mandala(font, name) {
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
fn generate_mandala(
  font : @fonts.Font,
  name : String
) -> Result[@draw.Graphic, @draw.DrawError] {
  let seed = hash_string(name)
  let prng = PRNG::new(seed)

  // 1. Create central text
  let text_graphic = @draw.text(font, name, size=1.0) catch {
    e => return Err(e)
  }
  
  let styled_text = text_graphic.with_style(fill=@draw.Color::black().as_fill())
  
  // Center the text
  let bbox = styled_text.bounding_box().unwrap_or(@geom.BoundingBox::new())
  let center_offset = @geom.vec2(-bbox.center().x, -bbox.center().y)
  let centered_text = styled_text.translate(center_offset)

  let mut mandala = centered_text

  // 2. Generate rings
  let num_rings = 4 + (seed % 3).reinterpret_as_int()
  let mut radius = bbox.width() / 2.0 + 0.2
  
  for i in 0..<num_rings {
    let segments = 6 + (prng.next() % 12).reinterpret_as_int()
    let hue = prng.next_double()
    let color = @draw.Color::from_hsva(hue, 0.7, 0.9, 0.6)
    
    let motif = match i % 3 {
      0 => {
        let w = 0.2 + prng.next_double() * 0.3
        let h = 0.3 + prng.next_double() * 0.5
        create_petal(radius, w, h)
      }
      1 => {
        let w = 0.1 + prng.next_double() * 0.2
        let h = 0.2 + prng.next_double() * 0.4
        create_diamond(radius, w, h)
      }
      _ => {
        let r = 0.05 + prng.next_double() * 0.15
        create_circle_at(radius + r, r)
      }
    }
    let ring_graphic = motif.with_style(
      fill=color.as_fill(),
      stroke=color.mix(@draw.Color::black(), 0.3).as_stroke(width=0.01)
    )
    
    mandala = mandala + repeat_radial(ring_graphic, segments)
    radius += 0.5 + prng.next_double() * 0.3
  }

  Ok(mandala)
}

///|
fn repeat_radial(graphic : @draw.Graphic, count : Int) -> @draw.Graphic {
  let items = [graphic]
  let step = 360.0 / count.to_double()
  for i in 1..<count {
    items.push(graphic.rotate(step * i.to_double()))
  }
  @draw.Graphic::Group({ items, })
}

///|
fn create_petal(r : Double, width : Double, height : Double) -> @draw.Graphic {
  let a1 = @draw.Anchor::new(position=@geom.vec2(0, r))
  let a2 = @draw.Anchor::new(
    position=@geom.vec2(width / 2.0, r + height / 2.0),
    handle_in=@geom.vec2(-width / 4.0, 0),
    handle_out=@geom.vec2(width / 4.0, 0),
  )
  let a3 = @draw.Anchor::new(position=@geom.vec2(0, r + height))
  let a4 = @draw.Anchor::new(
    position=@geom.vec2(-width / 2.0, r + height / 2.0),
    handle_in=@geom.vec2(width / 4.0, 0),
    handle_out=@geom.vec2(-width / 4.0, 0),
  )
  @draw.Graphic::Path(@draw.Path::new(anchors=[a1, a2, a3, a4], closed=true))
}

///|
fn create_diamond(r : Double, width : Double, height : Double) -> @draw.Graphic {
  let p1 = @geom.vec2(0, r)
  let p2 = @geom.vec2(width / 2.0, r + height / 2.0)
  let p3 = @geom.vec2(0, r + height)
  let p4 = @geom.vec2(-width / 2.0, r + height / 2.0)
  @draw.Graphic::Path(@draw.Path::from_points([p1, p2, p3, p4], closed=true))
}

///|
fn create_circle_at(r_center : Double, r : Double) -> @draw.Graphic {
  @draw.unit_circle().as_graphic().scale(@geom.vec2(r * 2.0, r * 2.0)).translate(@geom.vec2(0, r_center))
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