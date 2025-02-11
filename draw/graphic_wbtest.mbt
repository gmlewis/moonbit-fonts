///|
test "@draw.Graphic::to_json of compound_path" {
  let compound_path = glyph2compound_path!(letter_P, "dc", vec2(0, 0), 1, 1)
  let got = compound_path.to_json().stringify()
  inspect!(
    got,
    content=
      #|{"paths":[{"anchors":[{"position":{"x":582,"y":1462},"handle_in":{"x":0,"y":0},"handle_out":{"x":188.66666666666663,"y":0}},{"position":{"x":995.5,"y":1351.5},"handle_in":{"x":-87,"y":73.66666666666674},"handle_out":{"x":87,"y":-73.66666666666674}},{"position":{"x":1126,"y":1035},"handle_in":{"x":0,"y":137.33333333333326},"handle_out":{"x":0,"y":-62}},{"position":{"x":1095.5,"y":858.5},"handle_in":{"x":20.333333333333258,"y":55.66666666666663},"handle_out":{"x":-20.333333333333258,"y":-55.66666666666663}},{"position":{"x":997,"y":711.5},"handle_in":{"x":45.33333333333326,"y":42.33333333333337},"handle_out":{"x":-45.33333333333337,"y":-42.33333333333337}},{"position":{"x":818.5,"y":611.5},"handle_in":{"x":73.66666666666663,"y":24.33333333333337},"handle_out":{"x":-73.66666666666663,"y":-24.33333333333337}},{"position":{"x":548,"y":575},"handle_in":{"x":106.66666666666663,"y":0},"handle_out":{"x":0,"y":0}},{"position":{"x":370,"y":575},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}},{"position":{"x":370,"y":0},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}},{"position":{"x":200,"y":0},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}},{"position":{"x":200,"y":1462},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}},{"position":{"x":582,"y":1462},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}}],"closed":true,"clear":false,"fill":{"color":{"r":0,"g":0,"b":0,"a":1}}},{"anchors":[{"position":{"x":566,"y":1317},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}},{"position":{"x":370,"y":1317},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}},{"position":{"x":370,"y":721},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}},{"position":{"x":529,"y":721},"handle_in":{"x":0,"y":0},"handle_out":{"x":93.33333333333337,"y":0}},{"position":{"x":762.5,"y":751},"handle_in":{"x":-62.33333333333337,"y":-20},"handle_out":{"x":62.33333333333337,"y":20}},{"position":{"x":903,"y":848.5},"handle_in":{"x":-31.33333333333337,"y":-45},"handle_out":{"x":31.33333333333337,"y":45}},{"position":{"x":950,"y":1028},"handle_in":{"x":0,"y":-74.66666666666663},"handle_out":{"x":0,"y":97.33333333333326}},{"position":{"x":857,"y":1245.5},"handle_in":{"x":62,"y":-47.66666666666674},"handle_out":{"x":-62,"y":47.66666666666674}},{"position":{"x":566,"y":1317},"handle_in":{"x":132,"y":0},"handle_out":{"x":0,"y":0}}],"closed":true,"clear":true,"fill":{"color":{"r":1,"g":1,"b":1,"a":1}}}],"fill":{"color":{"r":0,"g":0,"b":0,"a":1}}}
    ,
  )
}

///|
test "@draw.Graphic::to_json of group" {
  let group = unit_square()
  let got = group.to_json().stringify()
  inspect!(
    got,
    content=
      #|{"items":[{"anchors":[{"position":{"x":-0.5,"y":-0.5},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}},{"position":{"x":0.5,"y":-0.5},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}},{"position":{"x":0.5,"y":0.5},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}},{"position":{"x":-0.5,"y":0.5},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}}],"closed":true,"clear":false}]}
    ,
  )
}

///|
test "@draw.Graphic::to_json of path" {
  let path = Path::from_points([vec2(0, 0), vec2(1, 1)])
  let got = path.to_json().stringify()
  inspect!(
    got,
    content=
      #|{"anchors":[{"position":{"x":0,"y":0},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}},{"position":{"x":1,"y":1},"handle_in":{"x":0,"y":0},"handle_out":{"x":0,"y":0}}],"closed":false,"clear":false}
    ,
  )
}
