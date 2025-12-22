///|
test "row alignment comprehensive" {
  let sq1 = @draw.unit_square().as_graphic() // 1x1, bbox: (-0.5, -0.5) to (0.5, 0.5)
  let sq2 = @draw.unit_square().scale(vec2(0.5, 0.5)).as_graphic() // 0.5x0.5, bbox: (-0.25, -0.25) to (0.25, 0.25)
  let tests = [
    (Alignment::TopLeft, 0.0, 1.0),
    (TopCenter, 0.5, 1.0),
    (TopRight, 0.0, 1.0),
    (CenterLeft, 0.5, 1.0),
    (Center, 0.0, 1.0),
    (CenterRight, 0.5, 1.0),
    (BaselineLeft, 0.0, 1.0),
    (BaselineCenter, 0.5, 1.0),
    (BaselineRight, 0.0, 1.0),
    (BottomLeft, 0.5, 1.0),
    (BottomCenter, 0.0, 1.0),
    (BottomRight, 0.5, 1.0),
  ]
  for tt in tests {
    let alignment = tt.0
    let spacing = tt.1
    let expected_height = tt.2
    let res = row([sq1, sq2], alignment~, spacing~).bounding_box().unwrap()
    //
    assert_eq(res.width(), 1.5 + spacing)
    assert_eq(res.height(), expected_height)
  }
}

///|
test "column alignment comprehensive" {
  let sq1 = @draw.unit_square().as_graphic()
  let sq2 = @draw.unit_square().scale(vec2(0.5, 0.5)).as_graphic()
  let tests = [
    (Alignment::TopLeft, 0.0, 1.0),
    (TopCenter, 0.5, 1.0),
    (TopRight, 0.0, 1.0),
    (CenterLeft, 0.5, 1.0),
    (Center, 0.0, 1.0),
    (CenterRight, 0.5, 1.0),
    (BaselineLeft, 0.0, 1.0),
    (BaselineCenter, 0.5, 1.0),
    (BaselineRight, 0.0, 1.0),
    (BottomLeft, 0.5, 1.0),
    (BottomCenter, 0.0, 1.0),
    (BottomRight, 0.5, 1.0),
  ]
  for tt in tests {
    let alignment = tt.0
    let spacing = tt.1
    let expected_width = tt.2
    let res = column([sq1, sq2], alignment~, spacing~).bounding_box().unwrap()
    //
    assert_eq(res.width(), expected_width)
    assert_eq(res.height(), 1.5 + spacing)
  }
}

///|
test "grid alignment comprehensive" {
  let sq1 = @draw.unit_square().as_graphic()
  let sq2 = @draw.unit_square().scale(vec2(0.5, 0.5)).as_graphic()
  let tests = [
    (Alignment::TopLeft, 0.0, 0.0, 2.0, 2.0),
    (TopCenter, 0.5, 0.5, 2.5, 2.5),
    (TopRight, 0.0, 0.0, 2.0, 2.0),
    (CenterLeft, 0.5, 0.5, 2.5, 2.5),
    (Center, 0.0, 0.0, 2.0, 2.0),
    (CenterRight, 0.5, 0.5, 2.5, 2.5),
    (BaselineLeft, 0.0, 0.0, 2.0, 2.0),
    (BaselineCenter, 0.5, 0.5, 2.5, 2.5),
    (BaselineRight, 0.0, 0.0, 2.0, 2.0),
    (BottomLeft, 0.5, 0.5, 2.5, 2.5),
    (BottomCenter, 0.0, 0.0, 2.0, 2.0),
    (BottomRight, 0.5, 0.5, 2.5, 2.5),
  ]
  for tt in tests {
    let alignment = tt.0
    let h_spacing = tt.1
    let v_spacing = tt.2
    let expected_width = tt.3
    let expected_height = tt.4
    // 2x2 grid: [sq1, sq2, sq2, sq1]
    // Col 0: max(sq1.w, sq2.w) = 1.0
    // Col 1: max(sq2.w, sq1.w) = 1.0
    // Row 0: max(sq1.h, sq2.h) = 1.0
    // Row 1: max(sq2.h, sq1.h) = 1.0
    // Total width: 1.0 + 1.0 + h_spacing = 2.0 + h_spacing
    // Total height: 1.0 + 1.0 + v_spacing = 2.0 + v_spacing
    let res = grid([sq1, sq2, sq2, sq1], 2, alignment~, h_spacing~, v_spacing~)
      .bounding_box()
      .unwrap()
    //
    assert_eq(res.width(), expected_width)
    assert_eq(res.height(), expected_height)
  }
}
