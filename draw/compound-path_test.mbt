///|
test "has_style/no_style" {
  let cp = CompoundPath::new(paths=[])
  inspect(cp.has_style(), content="false")
}

///|
test "has_style/fill_only" {
  let fill = Fill::new(color=rgba(0, 0, 0, 1))
  let cp = CompoundPath::new(paths=[], fill~)
  inspect(cp.has_style(), content="true")
}

///|
test "has_style/stroke_only" {
  let stroke = Stroke::new()
  let cp = CompoundPath::new(paths=[], stroke~)
  inspect(cp.has_style(), content="true")
}
