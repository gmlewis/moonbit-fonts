///|
test "row layout" {
  let g1 = @draw.unit_square().as_graphic() // bbox min:(-0.5, -0.5), max:(0.5, 0.5)
  let g2 = @draw.unit_square().as_graphic()
  let r = row([g1, g2], spacing=1.0)
  let bbox = r.bounding_box().unwrap()

  // Total width: g1.width(1) + spacing(1) + g2.width(1) = 3
  // Heights are 1.
  inspect(bbox.width(), content="3")
  inspect(bbox.height(), content="1")
}

///|
test "column layout" {
  let g1 = @draw.unit_square().as_graphic()
  let g2 = @draw.unit_square().as_graphic()
  let c = column([g1, g2], spacing=1.0)
  let bbox = c.bounding_box().unwrap()

  // Total height: g1.height(1) + spacing(1) + g2.height(1) = 3
  // Widths are 1.
  inspect(bbox.width(), content="1")
  inspect(bbox.height(), content="3")
}

///|
test "grid layout" {
  let g = @draw.unit_square().as_graphic()
  let gr = grid([g, g, g, g], 2, h_spacing=1.0, v_spacing=1.0)
  let bbox = gr.bounding_box().unwrap()

  // 2x2 grid. Width = 1 + 1 + 1 = 3. Height = 1 + 1 + 1 = 3.
  inspect(bbox.width(), content="3")
  inspect(bbox.height(), content="3")
}
