///|
/// `TextAlign` specifies the horizontal alignment of text.
pub(all) enum TextAlign {
  /// `Left` aligns text to the left.
  Left
  /// `Center` centers the text.
  Center
  /// `Right` aligns text to the right.
  Right
} derive(Eq)

///|
pub impl Show for TextAlign with output(self, logger) {
  match self {
    Left =>
      logger.write_string(
        (
          $|Left
        ),
      )
    Center =>
      logger.write_string(
        (
          $|Center
        ),
      )
    Right =>
      logger.write_string(
        (
          $|Right
        ),
      )
  }
}

///|
test "TextAlign show interface" {
  inspect(
    Center,
    content=(
      #|Center
    ),
  )
  inspect(
    Left,
    content=(
      #|Left
    ),
  )
  inspect(
    Right,
    content=(
      #|Right
    ),
  )
}

///|
/// `to_graphic` generates a new `Graphic` from a text string and a font.
pub fn to_graphic(
  font : Font,
  text : String,
  size? : Double = 1.0,
  alignment? : Alignment = Unchanged,
  y_up? : Bool = false,
) -> Graphic raise DrawError {
  let glyph = font.gen_path(text, alignment~, y_up~) catch {
    e => raise DrawError("to_graphic: \{e}")
  }
  let xscale = size / font.units_per_em
  let yscale = xscale
  let svgpath = SVGPath::from_glyph(glyph) catch {
    e => raise DrawError("to_graphic: \{e}")
  }
  svgpath2compound_path(svgpath, xscale, yscale).as_graphic()
}

///|
/// `text` is a convenience wrapper around `to_graphic` that uses `TextAlign`.
pub fn text(
  font : Font,
  text : String,
  size? : Double = 1.0,
  align? : TextAlign = Left,
  y_up? : Bool = false,
) -> Graphic raise DrawError {
  let alignment : Alignment = match align {
    Left => BaselineLeft
    Center => BaselineCenter
    Right => BaselineRight
  }
  to_graphic(font, text, size~, alignment~, y_up~)
}

///|
fn svgpath2compound_path(
  svgpath : SVGPath,
  xscale : Double,
  yscale : Double,
) -> CompoundPath {
  let paths = []
  let mut anchors = []
  let black = rgba(0, 0, 0, 1)
  let white = rgba(1, 1, 1, 1)
  let mut current_gerber_lp = GerberLP::Dark
  for cmd in svgpath.cmds {
    match cmd.cmd {
      M => {
        if anchors.length() > 0 {
          let color = if current_gerber_lp == Dark { black } else { white }
          let path = Path::new(
            anchors~,
            clear=current_gerber_lp == Clear,
            fill=fill(color),
          )
          paths.push(path)
          anchors = []
        }
        current_gerber_lp = cmd.gerber_lp
        for p in cmd.params {
          anchors.push(Anchor::new(position=vec2(p.x * xscale, p.y * yscale)))
        }
      }
      L =>
        for p in cmd.params {
          anchors.push(Anchor::new(position=vec2(p.x * xscale, p.y * yscale)))
        }
      C =>
        for i = 0; i + 2 < cmd.params.length(); i = i + 3 {
          if anchors.length() == 0 {
            continue
          }
          let c1 = cmd.params[i]
          let c2 = cmd.params[i + 1]
          let end = cmd.params[i + 2]
          let prev_anchor = anchors[anchors.length() - 1]
          prev_anchor.handle_out = vec2(c1.x * xscale, c1.y * yscale).sub(
            prev_anchor.position,
          )
          let end_pos = vec2(end.x * xscale, end.y * yscale)
          let h_in = vec2(c2.x * xscale, c2.y * yscale).sub(end_pos)
          anchors.push(Anchor::new(position=end_pos, handle_in=h_in))
        }
      Q =>
        for i = 0; i + 1 < cmd.params.length(); i = i + 2 {
          if anchors.length() == 0 {
            continue
          }
          let cp = cmd.params[i]
          let end = cmd.params[i + 1]
          let prev_anchor = anchors[anchors.length() - 1]
          let start_pt = prev_anchor.position
          let quad_ctrl_pt = vec2(cp.x * xscale, cp.y * yscale)
          let c1 = quad_ctrl_pt
            .sub(start_pt)
            .mul_scalar(2.0 / 3.0)
            .add(start_pt)
          prev_anchor.handle_out = c1.sub(start_pt)
          let end_pt = vec2(end.x * xscale, end.y * yscale)
          let c2 = quad_ctrl_pt.sub(end_pt).mul_scalar(2.0 / 3.0).add(end_pt)
          anchors.push(Anchor::new(position=end_pt, handle_in=c2.sub(end_pt)))
        }
      Z =>
        if anchors.length() > 0 {
          let color = if current_gerber_lp == Dark { black } else { white }
          let path = Path::new(
            anchors~,
            closed=true,
            clear=current_gerber_lp == Clear,
            fill=fill(color),
          )
          paths.push(path)
          anchors = []
        }
    }
  }
  if anchors.length() > 0 {
    let color = if current_gerber_lp == Dark { black } else { white }
    let path = Path::new(
      anchors~,
      clear=current_gerber_lp == Clear,
      fill=fill(color),
    )
    paths.push(path)
  }
  CompoundPath::new(paths~, fill=fill(black))
}

///|
/// `GlyphStyleContext` provides callback context for `text_with`.
pub struct GlyphStyleContext {
  grapheme_index : Int
  grapheme : String
  line_index : Int
  grapheme_index_in_line : Int
  pen_position : Vec2
  pen_position_scaled : Vec2
  has_glyph : Bool
  glyph_horiz_adv_x : Double
  glyph_horiz_adv_x_scaled : Double
}

///|
/// `GlyphTransform` represents optional per-glyph transform operations.
pub struct GlyphTransform {
  position : Vec2
  rotation : Double
  scale : Vec2
  skew : Double
  origin : Vec2
  affine_matrix : AffineMatrix?
}

///|
/// `GlyphStyleAction` controls styling/visibility for a grapheme in `text_with`.
pub enum GlyphStyleAction {
  UseDefault(GlyphTransform)
  Override(Stroke?, Fill?, GlyphTransform)
  Skip
}

///|
/// `TextWithStyleFn` is a functional-style callback for `text_with`.
pub struct TextWithStyleFn((GlyphStyleContext) -> GlyphStyleAction)

///|
/// `TextWithTupleStyleFn` is a compatibility callback that returns `(stroke?, fill?)`.
pub struct TextWithTupleStyleFn((Int, String) -> (Stroke?, Fill?))

///|
/// `text_with_style_fn` creates a style callback value for `text_with`.
pub fn text_with_style_fn(
  func : (GlyphStyleContext) -> GlyphStyleAction,
) -> TextWithStyleFn {
  TextWithStyleFn(func)
}

///|
/// `text_with_tuple_style_fn` creates a tuple-style callback value for `text_with_tuple`.
pub fn text_with_tuple_style_fn(
  func : (Int, String) -> (Stroke?, Fill?),
) -> TextWithTupleStyleFn {
  TextWithTupleStyleFn(func)
}

///|
/// `glyph_transform` creates a per-glyph transform.
pub fn glyph_transform(
  position? : Vec2 = vec2(0, 0),
  rotation? : Double = 0,
  scale? : Vec2 = vec2(1, 1),
  skew? : Double = 0,
  origin? : Vec2 = vec2(0, 0),
  affine_matrix? : AffineMatrix,
) -> GlyphTransform {
  { position, rotation, scale, skew, origin, affine_matrix }
}

///|
/// `glyph_style_use_default` keeps the glyph's default style.
pub fn glyph_style_use_default(
  transform? : GlyphTransform = glyph_transform(),
) -> GlyphStyleAction {
  UseDefault(transform)
}

///|
/// `glyph_style_override` overrides one or both style fields for a glyph.
pub fn glyph_style_override(
  stroke? : Stroke,
  fill? : Fill,
  transform? : GlyphTransform = glyph_transform(),
) -> GlyphStyleAction {
  Override(stroke, fill, transform)
}

///|
/// `glyph_style_skip` skips rendering the glyph.
pub fn glyph_style_skip() -> GlyphStyleAction {
  Skip
}

///|
/// `text_with` generates text like `text`, with optional per-grapheme style actions.
///
/// The callback runs once per grapheme and may:
/// - `UseDefault(transform)`: keep existing style with optional transform,
/// - `Override(stroke?, fill?, transform)`: override style with optional transform,
/// - `Skip`: skip rendering this grapheme.
pub fn text_with(
  font : Font,
  text : String,
  size? : Double = 1.0,
  align? : TextAlign = Left,
  y_up? : Bool = false,
  style_fn? : TextWithStyleFn,
) -> Graphic raise DrawError {
  let xscale = size / font.units_per_em
  let mut x = 0.0
  let mut y = 0.0
  let y_scale = if y_up { 1.0 } else { -1.0 }
  let items : Array[Graphic] = []
  let mut grapheme_index = 0
  let mut line_index = 0
  let mut grapheme_index_in_line = 0

  for c in text {
    let grapheme = c.to_string()
    let glyph_option = font.glyphs.get(grapheme)
    let has_glyph = match glyph_option {
      Some(_glyph) => true
      None => false
    }
    let glyph_horiz_adv_x = match glyph_option {
      Some(glyph) =>
        if glyph.horiz_adv_x > 0.0 {
          glyph.horiz_adv_x
        } else {
          font.horiz_adv_x
        }
      None => font.horiz_adv_x
    }
    let this_index = grapheme_index
    let this_line_index = line_index
    let this_grapheme_index_in_line = grapheme_index_in_line
    let this_pen_position = vec2(x, y)
    let this_pen_position_scaled = vec2(x * xscale, y * xscale)
    grapheme_index += 1
    grapheme_index_in_line += 1
    let style_action = match style_fn {
      None => UseDefault(glyph_transform())
      Some(style_fn) =>
        (style_fn.0)({
          grapheme_index: this_index,
          grapheme,
          line_index: this_line_index,
          grapheme_index_in_line: this_grapheme_index_in_line,
          pen_position: this_pen_position,
          pen_position_scaled: this_pen_position_scaled,
          has_glyph,
          glyph_horiz_adv_x,
          glyph_horiz_adv_x_scaled: glyph_horiz_adv_x * xscale,
        })
    }
    match glyph_option {
      Some(_glyph) => {
        match style_action {
          Skip => {
            x = x + glyph_horiz_adv_x
            continue
          }
          _ => ()
        }
        let glyph_graphic = to_graphic(
          font,
          grapheme,
          size~,
          alignment=Unchanged,
          y_up~,
        ) catch {
          e => raise DrawError("text_with: \{e}")
        }
        let glyph_graphic = glyph_graphic.transform(
          position=vec2(x * xscale, y * xscale),
        )
        let styled_glyph = match style_action {
          UseDefault(transform) =>
            apply_glyph_transform(glyph_graphic, transform)
          Override(stroke_override, fill_override, transform) => {
            let stroke = match stroke_override {
              Some(stroke) => Some(stroke)
              None => glyph_graphic.first_stroke()
            }
            let fill = match fill_override {
              Some(fill) => Some(fill)
              None => glyph_graphic.first_fill()
            }
            let styled = glyph_graphic.with_style(fill?, stroke?)
            apply_glyph_transform(styled, transform)
          }
          Skip => glyph_graphic
        }
        items.push(styled_glyph)
        x = x + glyph_horiz_adv_x
      }
      None =>
        match c {
          '\n' => {
            x = 0.0
            y = y - y_scale * (font.units_per_em - font.descent)
            line_index += 1
            grapheme_index_in_line = 0
          }
          '\r' => {
            y = y - y_scale * (font.units_per_em - font.descent)
            line_index += 1
            grapheme_index_in_line = 0
          }
          _ => x = x + font.horiz_adv_x
        }
    }
  }

  let mut result = Group::new(items~).as_graphic()
  let alignment : Alignment = match align {
    Left => BaselineLeft
    Center => BaselineCenter
    Right => BaselineRight
  }
  if alignment != BaselineLeft {
    match result.bounding_box() {
      None => ()
      Some(box) => {
        let dx = match alignment {
          BaselineCenter => -(box.min.x + box.max.x) / 2.0
          BaselineRight => -box.max.x
          _ => 0.0
        }
        result = result.translate(vec2(dx, 0))
      }
    }
  }
  result
}

///|
/// `text_with_tuple` provides backward-compatible tuple callback styling.
///
/// The callback returns `(stroke?, fill?)` and maps directly to
/// `GlyphStyleAction::Override`.
pub fn text_with_tuple(
  font : Font,
  text : String,
  size? : Double = 1.0,
  align? : TextAlign = Left,
  y_up? : Bool = false,
  style_fn? : TextWithTupleStyleFn,
) -> Graphic raise DrawError {
  let style_fn = match style_fn {
    None => None
    Some(style_fn) =>
      Some(
        TextWithStyleFn(fn(ctx) {
          let (stroke, fill) = (style_fn.0)(ctx.grapheme_index, ctx.grapheme)
          Override(stroke, fill, glyph_transform())
        }),
      )
  }
  text_with(font, text, size~, align~, y_up~, style_fn?)
}

///|
fn apply_glyph_transform(
  graphic : Graphic,
  transform : GlyphTransform,
) -> Graphic {
  let graphic = graphic.transform(
    position=transform.position,
    rotation=transform.rotation,
    scale=transform.scale,
    skew=transform.skew,
    origin=transform.origin,
  )
  match transform.affine_matrix {
    None => graphic
    Some(affine_matrix) => graphic.affine_transform(affine_matrix)
  }
}
