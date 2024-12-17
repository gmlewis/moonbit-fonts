///|
fn main {

}

///|
let vec2 = @draw.vec2

///|
pub fn draw(ctx : @canvas.CanvasCtx, width : Int, height : Int) -> Unit {
  let box = @draw.BoundingBox::from_points([
    vec2(0, 0),
    vec2(width.to_double(), height.to_double()),
  ])
  let b = @checkerboard.checkerboard().fit_to(box)
  @canvas.from_graphic(ctx, b)
}
