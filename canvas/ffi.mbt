typealias CompoundPath = @draw.CompoundPath

typealias Fill = @draw.Fill

typealias Graphic = @draw.Graphic

typealias Path = @draw.Path

typealias Stroke = @draw.Stroke

let vec2 = @draw.vec2

// context of an HTML5 canvas
type CanvasCtx

// Declare the foreign function interfaces (FFIs)

fn arc(
  self : CanvasCtx,
  x : Double,
  y : Double,
  radius : Double,
  start_angle : Double,
  end_angle : Double,
  counterclockwise : Bool
) = "canvas" "arc"

fn begin_path(self : CanvasCtx) = "canvas" "beginPath"

fn close_path(self : CanvasCtx) = "canvas" "closePath"

fn cubic_bezier_curve_to(
  self : CanvasCtx,
  cp1x : Double,
  cp1y : Double,
  cp2x : Double,
  cp2y : Double,
  x : Double,
  y : Double
) = "canvas" "bezierCurveTo"

fn fill(self : CanvasCtx) = "canvas" "fill"

fn move_to(self : CanvasCtx, x : Double, y : Double) = "canvas" "moveTo"

fn line_to(self : CanvasCtx, x : Double, y : Double) = "canvas" "lineTo"

fn set_fill_color(
  self : CanvasCtx,
  r : Double,
  g : Double,
  b : Double,
  a : Double
) = "canvas" "setFillColor"

fn stroke(self : CanvasCtx) = "canvas" "stroke"

// fn get_pi() -> Double = "math" "PI"
