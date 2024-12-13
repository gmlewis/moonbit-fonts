///|
typealias Fill = @draw.Fill

///|
typealias Graphic = @draw.Graphic

///|
typealias Group = @draw.Group

///|
typealias Transform = @draw.Transform

///|
let fill = @draw.fill

///|
let rgba = @draw.rgba

///|
let unit_circle = @draw.unit_circle

///|
let unit_square = @draw.unit_square

///|
let vec2 = @draw.vec2

///|
pub fn checkerboard() -> Graphic {
  let board = []
  for y in 0..<8 {
    for x in 0..<8 {
      board.push(square(x, y))
      if y < 3 && (x + y) % 2 == 0 {
        board.push(black_checker(x, y))
      } else if y > 4 && (x + y) % 2 == 0 {
        board.push(red_checker(x, y))
      }
    }
  }
  Group::new(items=board).as_graphic()
}

///|
fn single_checker(
  x : Int,
  y : Int,
  outer_fill : Fill?,
  inner_fill : Fill?
) -> Graphic {
  let items = [
    unit_circle()
    .transform(
      position=vec2(0.5 + x.to_double(), 0.5 + y.to_double()),
      scale=vec2(0.95, 0.95),
    )
    .assign_fill(outer_fill)
    .as_graphic(),
    unit_circle()
    .transform(
      position=vec2(0.5 + x.to_double(), 0.5 + y.to_double()),
      scale=vec2(0.8, 0.8),
    )
    .assign_fill(inner_fill)
    .as_graphic(),
  ]
  Group::new(items~).as_graphic()
}

///|
fn black_checker(x : Int, y : Int) -> Graphic {
  let light_gray = rgba(0.4, 0.4, 0.4, 1).as_fill()
  let dark_gray = rgba(0.1, 0.1, 0.1, 1).as_fill()
  single_checker(x, y, light_gray, dark_gray)
}

///|
fn red_checker(x : Int, y : Int) -> Graphic {
  let light_red = rgba(0.8, 0, 0, 1).as_fill()
  let dark_red = rgba(0.5, 0, 0, 1).as_fill()
  single_checker(x, y, light_red, dark_red)
}

///|
fn square(x : Int, y : Int) -> Graphic {
  let fill = fill(
    if (x + y) % 2 == 0 {
      rgba(0, 0, 0, 1) // black
    } else {
      rgba(1, 0, 0, 1) // red
    },
  )
  let v = vec2(0.5 + x.to_double(), 0.5 + y.to_double())
  unit_square().translate(v).assign_fill(Some(fill)).as_graphic()
}
