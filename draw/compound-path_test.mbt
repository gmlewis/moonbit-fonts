///|
test "@draw.has_style/no_style" {
  let cp = @draw.CompoundPath::new(paths=[])
  inspect(cp.has_style(), content="false")
}

///|
test "@draw.has_style/fill_only" {
  let fill = @draw.Fill::new(color=@draw.rgba(0, 0, 0, 1))
  let cp = @draw.CompoundPath::new(paths=[], fill~)
  inspect(cp.has_style(), content="true")
}

///|
test "@draw.has_style/stroke_only" {
  let stroke = @draw.Stroke::new()
  let cp = @draw.CompoundPath::new(paths=[], stroke~)
  inspect(cp.has_style(), content="true")
}
