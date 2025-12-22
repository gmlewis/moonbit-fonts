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

///|
test "CompoundPath from_json/to_json roundtrip" {
  let json_str =
    #|{"paths":[{"anchors":[{"position":{"x":0,"y":0},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}},{"position":{"x":1,"y":1},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}}],"closed":true,"clear":false},{"anchors":[{"position":{"x":2,"y":2},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}},{"position":{"x":3,"y":3},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}}],"closed":false,"clear":false}],"fill":{"color":{"r":1,"g":0,"b":0,"a":1}}}
  let json = @json.parse(json_str)
  let cp_from_json : CompoundPath = @json.from_json(json)
  let got_json = cp_from_json.to_json().stringify()
  inspect(got_json, content=json_str)
}
