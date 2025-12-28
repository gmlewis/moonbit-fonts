///|
fn main {
  let name = "MOON"
  let font = @aaarghnormal.font

  match generate_bio_mechanical(font, name) {
    Ok(graphic) => {
      let svg_str = @svg.from_graphic(
        graphic
        .with_margin(top=0.2, right=0.2, bottom=0.2, left=0.2)
        .with_background(@draw.rgba(0.05, 0.05, 0.05, 1.0)), // Dark background
        y_up=false,
      )
      println(svg_str)
    }
    Err(e) => println("Error: \{e}")
  }
}

///|
struct Node {
  pos : @geom.Vec2
  parent_idx : Int
  depth : Int
  mut influence_count : Int
  mut influence_dir : @geom.Vec2
}

///|
fn generate_bio_mechanical(
  font : @fonts.Font,
  name : String
) -> Result[@draw.Graphic, @draw.DrawError] {
  let prng = PRNG::new(hash_string(name))
  
  // 1. Get text attractors
  let text_graphic = @draw.text(font, name, size=1.0) catch {
    e => return Err(e)
  }
  let profiles = text_graphic.to_profiles(40) // Very dense
  let bbox = text_graphic.bounding_box().unwrap_or(@geom.BoundingBox::new())
  let frame = bbox.inset(-1.2)
  
  let attractors : Array[@geom.Vec2] = []
  for p in profiles {
    for pt in p.0 { attractors.push(pt) }
    for hole in p.1 { for pt in hole { attractors.push(pt) } }
  }

  // 2. Growth simulation
  let nodes : Array[Node] = []
  
  // Seed nodes along the frame
  let seed_count = 120
  for _ in 0..<seed_count {
    let side = (prng.next() % 4U).reinterpret_as_int()
    let t = prng.next_double()
    let pos = match side {
      0 => @geom.vec2(frame.min.x + frame.width() * t, frame.min.y)
      1 => @geom.vec2(frame.min.x + frame.width() * t, frame.max.y)
      2 => @geom.vec2(frame.min.x, frame.min.y + frame.height() * t)
      _ => @geom.vec2(frame.max.x, frame.min.y + frame.height() * t)
    }
    nodes.push({ pos, parent_idx: -1, depth: 0, influence_count: 0, influence_dir: @geom.vec2(0, 0) })
  }

  let minDist = 0.06
  let maxDist = 2.0
  let branchLen = 0.08
  
  for _iter in 0..<150 {
    for n in nodes {
      n.influence_count = 0
      n.influence_dir = @geom.vec2(0, 0)
    }

    for i = attractors.length() - 1; i >= 0; i = i - 1 {
      let attr = attractors[i]
      let mut closest_idx = -1
      let mut record = maxDist
      
      for j in 0..<nodes.length() {
        let d = nodes[j].pos.distance(attr)
        if d < minDist {
          attractors.remove(i) |> ignore
          closest_idx = -2
          break
        } else if d < record {
          record = d
          closest_idx = j
        }
      }
      
      if closest_idx >= 0 {
        let n = nodes[closest_idx]
        let dir = attr.sub(n.pos)
        dir.normalize()
        n.influence_dir.self_add(dir)
        n.influence_count += 1
      }
    }

    let current_nodes_len = nodes.length()
    for i in 0..<current_nodes_len {
      let n = nodes[i]
      if n.influence_count > 0 {
        let avg_dir = n.influence_dir.mul_scalar(1.0 / n.influence_count.to_double())
        // Higher noise for more organic curves
        let noise = @geom.vec2((prng.next_double() - 0.5) * 0.8, (prng.next_double() - 0.5) * 0.8)
        avg_dir.self_add(noise)
        avg_dir.normalize()
        
        let new_pos = n.pos.add(avg_dir.mul_scalar(branchLen))
        nodes.push({ pos: new_pos, parent_idx: i, depth: n.depth + 1, influence_count: 0, influence_dir: @geom.vec2(0, 0) })
      }
    }
    if attractors.length() == 0 { break }
  }

  // 3. Render
  // Text with strong contrast
  let styled_text = text_graphic.with_style(
    fill=@draw.rgba(0.2, 0.6, 1.0, 0.9).as_fill(), // Glowing blue core
    stroke=@draw.rgba(1.0, 1.0, 1.0, 1.0).as_stroke(width=0.02)
  )
  
  // Metallic Frame
  let frame_path = @draw.Path::from_points([
    frame.min, @geom.vec2(frame.max.x, frame.min.y),
    frame.max, @geom.vec2(frame.min.x, frame.max.y)
  ], closed=true).as_graphic().with_style(stroke=@draw.rgba(0.4, 0.4, 0.4, 1.0).as_stroke(width=0.15))
  
  let mut branches = @draw.Graphic::Group({ items: [] })
  let mut max_depth = 1
  for n in nodes { if n.depth > max_depth { max_depth = n.depth } }

  for n in nodes {
    if n.parent_idx >= 0 {
      let p = nodes[n.parent_idx]
      let depth_t = n.depth.to_double() / max_depth.to_double()
      let width = 0.1 * (1.0 - depth_t * 0.8)
      let color = @draw.rgba(
        0.1 + depth_t * 0.2, 
        0.8 - depth_t * 0.4, 
        0.2 + depth_t * 0.3, 
        1.0
      )
      let branch = @draw.Path::from_points([p.pos, n.pos], closed=false)
        .as_graphic()
        .with_style(stroke=color.as_stroke(width~, cap=@draw.Round))
      branches = branches + branch
    }
  }

  Ok(branches + styled_text + frame_path)
}

///|
fn hash_string(s : String) -> UInt {
  let mut h = 0U
  for i in 0..<s.length() { h = h * 31U + s[i].to_int().reinterpret_as_uint() }
  h
}

///|
struct PRNG { mut state : UInt }
fn PRNG::new(seed : UInt) -> PRNG { { state: seed } }
fn PRNG::next(self : PRNG) -> UInt { self.state = self.state * 1103515245U + 12345U; self.state }
fn PRNG::next_double(self : PRNG) -> Double { (self.next() & 0x7FFFFFFFU).to_double() / 2147483647.0 }
