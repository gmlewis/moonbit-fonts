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
  let sq = @draw.unit_square().as_graphic() // 1x1
  let tests = [
    // (alignment, h_spacing, v_spacing, expected_width, expected_height)
    (Alignment::TopLeft, 0.0, 0.0, 2.0, 2.0),
    (TopCenter, 1.0, 1.0, 3.0, 3.0),
    (Center, 0.5, 0.5, 2.5, 2.5),
    (BottomRight, 0.0, 0.0, 2.0, 2.0),
  ]
  for tt in tests {
    let res = grid(
        [sq, sq, sq, sq],
        2,
        alignment=tt.0,
        h_spacing=tt.1,
        v_spacing=tt.2,
      )
      .bounding_box()
      .unwrap()
    assert_eq(res.width(), tt.3)
    assert_eq(res.height(), tt.4)
  }
}
