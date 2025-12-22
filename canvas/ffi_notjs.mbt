// Declare the foreign function interfaces (FFIs)

///|
// fn arc(
//   self : CanvasCtx,
//   x : Double,
//   y : Double,
//   radius : Double,
//   start_angle : Double,
//   end_angle : Double,
//   counterclockwise : Bool
// ) -> Unit { abort("not a JS context") }

///|
fn CanvasCtx::begin_path(_self : CanvasCtx) -> Unit {
  abort("not a JS context")
}

///|
fn CanvasCtx::close_path(_self : CanvasCtx) -> Unit {
  abort("not a JS context")
}

///|
fn CanvasCtx::cubic_bezier_curve_to(
  _self : CanvasCtx,
  _cp1x : Double,
  _cp1y : Double,
  _cp2x : Double,
  _cp2y : Double,
  _x : Double,
  _y : Double,
) -> Unit {
  abort("not a JS context")
}

///|
fn CanvasCtx::fill(_self : CanvasCtx) -> Unit {
  abort("not a JS context")
}

///|
fn CanvasCtx::move_to(_self : CanvasCtx, _x : Double, _y : Double) -> Unit {
  abort("not a JS context")
}

///|
fn CanvasCtx::line_to(_self : CanvasCtx, _x : Double, _y : Double) -> Unit {
  abort("not a JS context")
}

///|
/// Note that `canvas.setFillColor` is added by the JavaScript host
/// to set the `fillStyle` property of the canvas context.
fn CanvasCtx::set_fill_color(
  _self : CanvasCtx,
  _r : Double,
  _g : Double,
  _b : Double,
  _a : Double,
) -> Unit {
  abort("not a JS context")
}

///|
/// Note that `canvas.setStrokeColor` is added by the JavaScript host
/// to set the `strokeStyle` property of the canvas context.
fn CanvasCtx::set_stroke_color(
  _self : CanvasCtx,
  _r : Double,
  _g : Double,
  _b : Double,
  _a : Double,
) -> Unit {
  abort("not a JS context")
}

///|
fn CanvasCtx::stroke(_self : CanvasCtx) -> Unit {
  abort("not a JS context")
}

// fn get_pi() -> Double = "math" "PI"

///|
/// Note that `canvas.setLineCapButt` is added by the JavaScript host
/// to set the `lineCap` property of the canvas context to `butt`.
fn CanvasCtx::set_line_cap_butt(_self : CanvasCtx) -> Unit {
  abort("not a JS context")
}

///|
/// Note that `canvas.setLineCapRound` is added by the JavaScript host
/// to set the `lineCap` property of the canvas context to `round`.
fn CanvasCtx::set_line_cap_round(_self : CanvasCtx) -> Unit {
  abort("not a JS context")
}

///|
/// Note that `canvas.setLineCapSquare` is added by the JavaScript host
/// to set the `lineCap` property of the canvas context to `square`.
fn CanvasCtx::set_line_cap_square(_self : CanvasCtx) -> Unit {
  abort("not a JS context")
}

///|
/// Note that `canvas.setLineJoinMiter` is added by the JavaScript host
/// to set the `lineJoin` property of the canvas context to `miter`.
fn CanvasCtx::set_line_join_miter(_self : CanvasCtx) -> Unit {
  abort("not a JS context")
}

///|
/// Note that `canvas.setLineJoinRound` is added by the JavaScript host
/// to set the `lineJoin` property of the canvas context to `round`.
fn CanvasCtx::set_line_join_round(_self : CanvasCtx) -> Unit {
  abort("not a JS context")
}

///|
/// Note that `canvas.setLineJoinBevel` is added by the JavaScript host
/// to set the `lineJoin` property of the canvas context to `bevel`.
fn CanvasCtx::set_line_join_bevel(_self : CanvasCtx) -> Unit {
  abort("not a JS context")
}

///|
/// Note that `canvas.setMiterLimit` is added by the JavaScript host
/// to set the `miterLimit` property of the canvas context.
fn CanvasCtx::set_miter_limit(_self : CanvasCtx, _miter_limit : Double) -> Unit {
  abort("not a JS context")
}

///|
/// Note that `canvas.setLineWidth` is added by the JavaScript host
/// to set the `lineWidth` property of the canvas context.
fn CanvasCtx::set_line_width(_self : CanvasCtx, _width : Double) -> Unit {
  abort("not a JS context")
}

///|
/// Note that `canvas.getInputLength` and `canvas.getInputByteAtOffset` are
/// convenience functions that allow the JavaScript host to easily pass a
/// string (such as a JSON blob) to the MoonBit wasm module without needing
/// to provide another SDK or WIT interface. If these features are not needed,
/// then the host can supply two functions that both return 0.
fn CanvasCtx::get_input_length(_self : CanvasCtx) -> Int {
  abort("not a JS context")
}

///|
fn CanvasCtx::get_input_byte_at_offset(
  _self : CanvasCtx,
  _offset : Int,
) -> Byte {
  abort("not a JS context")
}
