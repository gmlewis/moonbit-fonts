///|
test "svg unit circle is correct" {
  let c = @draw.unit_circle().as_graphic()
  let got = from_graphic(c, y_up=false)
  inspect(
    got,
    content=(
      #|<svg xmlns="http://www.w3.org/2000/svg" viewBox="-0.5 -0.5 1 1">
      #|  <path d="M0 -0.5C0.2761 -0.5 0.5 -0.2761 0.5 0C0.5 0.2761 0.2761 0.5 0 0.5C-0.2761 0.5 -0.5 0.2761 -0.5 0C-0.5 -0.2761 -0.2761 -0.5 0 -0.5Z" stroke="none" fill="none"/>
      #|</svg>
    ),
  )
}

///|
test "svg unit square is correct" {
  let c = @draw.unit_square().as_graphic()
  let got = from_graphic(c, y_up=false)
  inspect(
    got,
    content=(
      #|<svg xmlns="http://www.w3.org/2000/svg" viewBox="-0.5 -0.5 1 1">
      #|  <path d="M-0.5 -0.5L0.5 -0.5L0.5 0.5L-0.5 0.5Z" stroke="none" fill="none"/>
      #|</svg>
    ),
  )
}
