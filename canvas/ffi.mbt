///|
typealias @draw.CompoundPath

///|
typealias @draw.Fill

///|
typealias @draw.Graphic

///|
typealias @draw.Path

///|
typealias @draw.Stroke

///|
let vec2 = @draw.vec2

// context of an HTML5 canvas
///|
#external
type CanvasCtx

// Declare the foreign function interfaces (FFIs)

///|
fn arc(
  self : CanvasCtx,
  x : Double,
  y : Double,
  radius : Double,
  start_angle : Double,
  end_angle : Double,
  counterclockwise : Bool
) = "canvas" "arc"

///|
fn begin_path(self : CanvasCtx) = "canvas" "beginPath"

///|
fn close_path(self : CanvasCtx) = "canvas" "closePath"

///|
fn cubic_bezier_curve_to(
  self : CanvasCtx,
  cp1x : Double,
  cp1y : Double,
  cp2x : Double,
  cp2y : Double,
  x : Double,
  y : Double
) = "canvas" "bezierCurveTo"

///|
fn fill(self : CanvasCtx) = "canvas" "fill"

///|
fn move_to(self : CanvasCtx, x : Double, y : Double) = "canvas" "moveTo"

///|
fn line_to(self : CanvasCtx, x : Double, y : Double) = "canvas" "lineTo"

///|
/// Note that `canvas.setFillColor` is added by the JavaScript host
/// to set the `fillStyle` property of the canvas context.
fn set_fill_color(
  self : CanvasCtx,
  r : Double,
  g : Double,
  b : Double,
  a : Double
) = "canvas" "setFillColor"

///|
/// Note that `canvas.setStrokeColor` is added by the JavaScript host
/// to set the `strokeStyle` property of the canvas context.
fn set_stroke_color(
  self : CanvasCtx,
  r : Double,
  g : Double,
  b : Double,
  a : Double
) = "canvas" "setStrokeColor"

///|
fn stroke(self : CanvasCtx) = "canvas" "stroke"

// fn get_pi() -> Double = "math" "PI"

///|
/// Note that `canvas.setLineCapButt` is added by the JavaScript host
/// to set the `lineCap` property of the canvas context to "butt".
fn set_line_cap_butt(self : CanvasCtx) = "canvas" "setLineCapButt"

///|
/// Note that `canvas.setLineCapRound` is added by the JavaScript host
/// to set the `lineCap` property of the canvas context to "round".
fn set_line_cap_round(self : CanvasCtx) = "canvas" "setLineCapRound"

///|
/// Note that `canvas.setLineCapSquare` is added by the JavaScript host
/// to set the `lineCap` property of the canvas context to "square".
fn set_line_cap_square(self : CanvasCtx) = "canvas" "setLineCapSquare"

///|
/// Note that `canvas.setLineJoinMiter` is added by the JavaScript host
/// to set the `lineJoin` property of the canvas context to "miter".
fn set_line_join_miter(self : CanvasCtx) = "canvas" "setLineJoinMiter"

///|
/// Note that `canvas.setLineJoinRound` is added by the JavaScript host
/// to set the `lineJoin` property of the canvas context to "round".
fn set_line_join_round(self : CanvasCtx) = "canvas" "setLineJoinRound"

///|
/// Note that `canvas.setLineJoinBevel` is added by the JavaScript host
/// to set the `lineJoin` property of the canvas context to "bevel".
fn set_line_join_bevel(self : CanvasCtx) = "canvas" "setLineJoinBevel"

///|
/// Note that `canvas.setMiterLimit` is added by the JavaScript host
/// to set the `miterLimit` property of the canvas context.
fn set_miter_limit(self : CanvasCtx, miter_limit : Double) = "canvas" "setMiterLimit"

///|
/// Note that `canvas.setLineWidth` is added by the JavaScript host
/// to set the `lineWidth` property of the canvas context.
fn set_line_width(self : CanvasCtx, width : Double) = "canvas" "setLineWidth"

///|
/// Note that `canvas.getInputLength` and `canvas.getInputByteAtOffset` are
/// convenience functions that allow the JavaScript host to easily pass a
/// string (such as a JSON blob) to the MoonBit wasm module without needing
/// to provide another SDK or WIT interface. If these features are not needed,
/// then the host can supply two functions that both return 0.
fn get_input_length(self : CanvasCtx) -> Int = "canvas" "getInputLength"

///|
fn get_input_byte_at_offset(self : CanvasCtx, offset : Int) -> Byte = "canvas" "getInputByteAtOffset"
