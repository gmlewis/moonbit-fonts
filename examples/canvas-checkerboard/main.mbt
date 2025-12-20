///|
using @geom {vec2, type BoundingBox}

///|
pub fn draw(ctx : @canvas.CanvasCtx, width : Int, height : Int) -> Unit {
  let box = BoundingBox::from_points([
    vec2(0, 0),
    vec2(width.to_double(), height.to_double()),
  ])
  let b = @checkerboard.checkerboard().fit_to(box)
  ctx.from_graphic(b)
}

///|
fn main {

}
