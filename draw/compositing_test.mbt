///|
test "row layout comprehensive" {
  let sq1 = @draw.unit_square().as_graphic() // 1x1, bbox: (-0.5, -0.5) to (0.5, 0.5)
  let sq2 = @draw.unit_square().scale(vec2(0.5, 0.5)).as_graphic() // 0.5x0.5, bbox: (-0.25, -0.25) to (0.25, 0.25)
  let tests = [
    // (alignment, spacing, expected_bbox)
    (Alignment::TopLeft, 0.0, bbox(0, -0.5, 1.5, 0.5)),
    (TopCenter, 1.0, bbox(0, -0.5, 2.5, 0.5)),
    (TopRight, 0.5, bbox(0, -0.5, 2.0, 0.5)),
    (CenterLeft, 0.0, bbox(0, -0.5, 1.5, 0.5)),
    (Center, 1.0, bbox(0, -0.5, 2.5, 0.5)),
    (CenterRight, 0.0, bbox(0, -0.5, 1.5, 0.5)),
    (BottomLeft, 0.0, bbox(0, -0.5, 1.5, 0.5)),
    (BottomCenter, 1.0, bbox(0, -0.5, 2.5, 0.5)),
    (BottomRight, 0.0, bbox(0, -0.5, 1.5, 0.5)),
    (BaselineLeft, 0.0, bbox(0, -0.5, 1.5, 0.5)),
    (BaselineCenter, 1.0, bbox(0, -0.5, 2.5, 0.5)),
    (BaselineRight, 0.0, bbox(0, -0.5, 1.5, 0.5)),
  ]
  for tt in tests {
    let res = row([sq1, sq2], alignment=tt.0, spacing=tt.1)
      .bounding_box()
      .unwrap()
    assert_eq(res, tt.2)
  }
}

///|
test "column layout comprehensive" {
  let sq1 = @draw.unit_square().as_graphic() // 1x1, bbox: (-0.5, -0.5) to (0.5, 0.5)
  let sq2 = @draw.unit_square().scale(vec2(0.5, 0.5)).as_graphic() // 0.5x0.5, bbox: (-0.25, -0.25) to (0.25, 0.25)
  let tests = [
    // (alignment, spacing, expected_bbox)
    (Alignment::TopLeft, 0.0, bbox(-0.5, -1.5, 0.5, 0)),
    (CenterLeft, 1.0, bbox(-0.5, -2.5, 0.5, 0)),
    (BottomLeft, 0.5, bbox(-0.5, -2.0, 0.5, 0)),
    (TopCenter, 0.0, bbox(-0.5, -1.5, 0.5, 0)),
    (Center, 1.0, bbox(-0.5, -2.5, 0.5, 0)),
    (BottomCenter, 0.0, bbox(-0.5, -1.5, 0.5, 0)),
    (TopRight, 0.0, bbox(-0.5, -1.5, 0.5, 0)),
    (CenterRight, 1.0, bbox(-0.5, -2.5, 0.5, 0)),
    (BottomRight, 0.0, bbox(-0.5, -1.5, 0.5, 0)),
    (BaselineLeft, 0.0, bbox(-0.5, -1.5, 0.5, 0)),
    (BaselineCenter, 1.0, bbox(-0.5, -2.5, 0.5, 0)),
    (BaselineRight, 0.0, bbox(-0.5, -1.5, 0.5, 0)),
  ]
  for tt in tests {
    let res = column([sq1, sq2], alignment=tt.0, spacing=tt.1)
      .bounding_box()
      .unwrap()
    assert_eq(res, tt.2)
  }
}

///|
test "grid layout comprehensive" {
  let sq = @draw.unit_square().as_graphic() // 1x1, bbox: (-0.5, -0.5) to (0.5, 0.5)

  // 2x2 grid, all 1x1 squares
  // row spacing 1.0, col spacing 1.0
  // Each row will be width 1+1+1 = 3, height 1
  // Column of 2 rows will be height 1+1+1 = 3, width 3
  let g = grid([sq, sq, sq, sq], 2, h_spacing=1.0, v_spacing=1.0)
  let bbox = g.bounding_box().unwrap()
  inspect(bbox.width(), content="3")
  inspect(bbox.height(), content="3")

  // Test with different item counts
  let g2 = grid([sq, sq, sq], 2, h_spacing=1.0, v_spacing=1.0)
  let bbox2 = g2.bounding_box().unwrap()
  // Row 1: width 3, height 1
  // Row 2: width 1, height 1
  // Column: width 3 (max of rows), height 3
  inspect(bbox2.width(), content="3")
  inspect(bbox2.height(), content="3")
}
