///|
/// `row` arranges an array of `Graphic` elements horizontally.
/// `alignment` specifies the vertical alignment within the row (defaults to `Center`).
/// `spacing` specifies the distance between elements.
pub fn row(
  items : Array[Graphic],
  alignment? : Alignment,
  spacing? : Double,
) -> Graphic {
  if items.length() == 0 {
    return Group::new().as_graphic()
  }
  let s = match spacing {
    Some(v) => v
    None => 0.0
  }
  let align = match alignment {
    Some(v) => v
    None => Center
  }

  // Calculate bounding boxes for all items
  let bboxes = items.map(fn(item) {
    match item.bounding_box() {
      Some(b) => b
      None => bbox(0, 0, 0, 0)
    }
  })

  // Calculate the maximum height (for vertical alignment)
  let mut max_y = 0.0
  let mut min_y = 0.0
  for i, box in bboxes {
    if i == 0 || box.max.y > max_y {
      max_y = box.max.y
    }
    if i == 0 || box.min.y < min_y {
      min_y = box.min.y
    }
  }
  let mut current_x = 0.0
  let positioned_items = []
  for i, item in items {
    let box = bboxes[i]

    // Horizontal position: sequential with spacing
    let tx = current_x - box.min.x

    // Vertical position: based on alignment
    let ty = match align {
      TopLeft | TopCenter | TopRight => max_y - box.max.y
      BottomLeft
      | BottomCenter
      | BottomRight
      | BaselineLeft
      | BaselineCenter
      | BaselineRight => min_y - box.min.y
      _ => (min_y + max_y) / 2.0 - (box.min.y + box.max.y) / 2.0 // Default to Center
    }
    positioned_items.push(item.translate(vec2(tx, ty)))
    current_x += box.width() + s
  }
  Group::new(items=positioned_items).as_graphic()
}

///|
/// `column` arranges an array of `Graphic` elements vertically from top to bottom.
/// `alignment` specifies the horizontal alignment within the column (defaults to `Center`).
/// `spacing` specifies the distance between elements.
pub fn column(
  items : Array[Graphic],
  alignment? : Alignment,
  spacing? : Double,
) -> Graphic {
  if items.length() == 0 {
    return Group::new().as_graphic()
  }
  let s = match spacing {
    Some(v) => v
    None => 0.0
  }
  let align = match alignment {
    Some(v) => v
    None => Center
  }

  // Calculate bounding boxes for all items
  let bboxes = items.map(fn(item) {
    match item.bounding_box() {
      Some(b) => b
      None => bbox(0, 0, 0, 0)
    }
  })

  // Calculate min/max x (for horizontal alignment)
  let mut max_x = 0.0
  let mut min_x = 0.0
  for i, box in bboxes {
    if i == 0 || box.max.x > max_x {
      max_x = box.max.x
    }
    if i == 0 || box.min.x < min_x {
      min_x = box.min.x
    }
  }
  let mut current_y = 0.0
  let positioned_items = []
  for i, item in items {
    let box = bboxes[i]

    // Horizontal position: based on alignment
    let tx = match align {
      TopLeft | CenterLeft | BottomLeft | BaselineLeft => min_x - box.min.x
      TopRight | CenterRight | BottomRight | BaselineRight => max_x - box.max.x
      _ => (min_x + max_x) / 2.0 - (box.min.x + box.max.x) / 2.0 // Default to Center
    }

    // Vertical position: sequential (Y goes down in standard layout)
    let ty = current_y - box.max.y
    positioned_items.push(item.translate(vec2(tx, ty)))
    current_y -= box.height() + s
  }
  Group::new(items=positioned_items).as_graphic()
}

///|
/// `grid` arranges an array of `Graphic` elements in a grid with `cols` columns.
/// `h_spacing` and `v_spacing` specify the distance between elements.
pub fn grid(
  items : Array[Graphic],
  cols : Int,
  h_spacing? : Double,
  v_spacing? : Double,
) -> Graphic {
  if items.length() == 0 || cols <= 0 {
    return Group::new().as_graphic()
  }
  let hs = match h_spacing {
    Some(v) => v
    None => 0.0
  }
  let vs = match v_spacing {
    Some(v) => v
    None => 0.0
  }
  let rows = []
  let mut current_row = []
  for item in items {
    current_row.push(item)
    if current_row.length() == cols {
      rows.push(row(current_row, spacing=hs))
      current_row = []
    }
  }
  if current_row.length() > 0 {
    rows.push(row(current_row, spacing=hs))
  }
  column(rows, spacing=vs)
}
