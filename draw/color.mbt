///|
/// Color represents a color in RGBA color space.
pub(all) struct Color {
  mut r : Double
  mut g : Double
  mut b : Double
  mut a : Double
} derive(Show, Eq, FromJson, ToJson)

///|
/// Color::new returns a new color.
pub fn Color::new(
  r~ : Double = 0,
  g~ : Double = 0,
  b~ : Double = 0,
  a~ : Double = 1,
) -> Color {
  { r, g, b, a }
}

///|
/// rgba is a convenience function.
pub fn rgba(r : Double, g : Double, b : Double, a : Double) -> Color {
  { r, g, b, a }
}

///|
/// Color::from_hsva creates a color by converting HSVA space to RGBA.
pub fn Color::from_hsva(
  hue : Double,
  saturation : Double,
  value : Double,
  alpha : Double,
) -> Color {
  let h = hue * 6
  let s = saturation
  let v = value
  let quad = @math.floor(h) // % 6  // compiler workaround
  let frac = h - @math.floor(h)
  let a = v * (1.0 - s)
  let b = v * (1.0 - s * frac)
  let c = v * (1.0 - s * (1.0 - frac))
  match quad {
    0 => return rgba(v, c, a, alpha)
    1 => return rgba(b, v, a, alpha)
    2 => return rgba(a, v, c, alpha)
    3 => return rgba(a, b, v, alpha)
    4 => return rgba(c, a, v, alpha)
    _ => return rgba(v, a, b, alpha)
  }
}

///|
fn parse_hex_hex(s : String) -> Double raise Error {
  @strconv.parse_int("\{s}\{s}", base=16).to_double() / 255
}

///|
fn parse_hex(s : String) -> Double raise Error {
  @strconv.parse_int(s, base=16).to_double() / 255
}

///|
let percent_re : @regexp.RegExp = (try? @regexp.compile("^(\\d+)%$")).unwrap()

///|
let rgb_re : @regexp.RegExp = (try? @regexp.compile(
  "^rgb\\s*\\(\\s*(\\d+%?)[\\s,]+(\\d+%?)[\\s,]+(\\d+%?)\\s*\\)$",
)).unwrap()

///|
let rgba_re : @regexp.RegExp = (try? @regexp.compile(
  "^rgba\\s*\\(\\s*(\\d+%?)[\\s,]+(\\d+%?)[\\s,]+(\\d+%?)[\\s,]+(\\d+%?)\\s*\\)$",
)).unwrap()

///|
fn parse_percent(s : String) -> Double raise Error {
  let m = percent_re.matches(s)
  match m.captures() {
    [_, v] => @strconv.parse_int(v, base=10).to_double() / 100
    _ => @strconv.parse_int(s, base=10).to_double() / 255
  }
}

///|
fn css_color(r : Int, g : Int, b : Int) -> Color {
  let r = r.to_double() / 255
  let g = g.to_double() / 255
  let b = b.to_double() / 255
  { r, g, b, a: 1 }
}

///|
/// Color::from_css_string returns a color from a CSS string.
pub fn Color::from_css_string(css_string : String) -> Color raise Error {
  let css_string = css_string.trim(" ").to_lower().to_string()
  match css_colors.get(css_string) {
    Some([r, g, b]) => return css_color(r, g, b)
    _ => ()
  }

  //
  if Some('#') == css_string.unsafe_charcode_at(0).to_char() {
    match css_string.length() {
      4 =>
        return rgba(
          parse_hex_hex(
            css_string.unsafe_charcode_at(1).to_char().unwrap().to_string(),
          ),
          parse_hex_hex(
            css_string.unsafe_charcode_at(2).to_char().unwrap().to_string(),
          ),
          parse_hex_hex(
            css_string.unsafe_charcode_at(3).to_char().unwrap().to_string(),
          ),
          1,
        )
      5 =>
        return rgba(
          parse_hex_hex(
            css_string.unsafe_charcode_at(1).to_char().unwrap().to_string(),
          ),
          parse_hex_hex(
            css_string.unsafe_charcode_at(2).to_char().unwrap().to_string(),
          ),
          parse_hex_hex(
            css_string.unsafe_charcode_at(3).to_char().unwrap().to_string(),
          ),
          parse_hex_hex(
            css_string.unsafe_charcode_at(4).to_char().unwrap().to_string(),
          ),
        )
      7 =>
        return rgba(
          parse_hex(css_string.substring(start=1, end=3)),
          parse_hex(css_string.substring(start=3, end=5)),
          parse_hex(css_string.substring(start=5, end=7)),
          1,
        )
      9 =>
        return rgba(
          parse_hex(css_string.substring(start=1, end=3)),
          parse_hex(css_string.substring(start=3, end=5)),
          parse_hex(css_string.substring(start=5, end=7)),
          parse_hex(css_string.substring(start=7, end=9)),
        )
      _ => ()
    }
  }

  //
  let m = rgb_re.matches(css_string)
  match m.captures() {
    [_, r, g, b] =>
      return rgba(parse_percent(r), parse_percent(g), parse_percent(b), 1)
    _ => ()
  }

  //
  let m = rgba_re.matches(css_string)
  match m.captures() {
    [_, r, g, b, a] =>
      return rgba(
        parse_percent(r),
        parse_percent(g),
        parse_percent(b),
        parse_percent(a),
      )
    _ => Color::new()
  }
}

///|
/// Color::from_rgb8_number returns a color from a bit-packed RGB8 format.
pub fn Color::from_rgb8_number(value : UInt) -> Color {
  let r = ((value >> 16) & 0xff).reinterpret_as_int().to_double() / 255
  let g = ((value >> 8) & 0xff).reinterpret_as_int().to_double() / 255
  let b = (value & 0xff).reinterpret_as_int().to_double() / 255
  rgba(r, g, b, 1)
}

///|
/// as_fill is a convenience function for setting a fill color.
pub fn as_fill(self : Color) -> Fill? {
  Some(fill(self))
}

///|
/// clone returns a new copy of this Color.
pub fn Color::clone(self : Color) -> Color {
  rgba(self.r, self.g, self.b, self.a)
}

///|
/// set sets the RGBA components of this Color.
pub fn set(
  self : Color,
  r : Double,
  g : Double,
  b : Double,
  a : Double,
) -> Color {
  self.r = r
  self.g = g
  self.b = b
  self.a = a
  self
}

///|
/// mix linearly interpolates between this Color and `c` with mixing factor `t`.
pub fn mix(self : Color, c : Color, t : Double) -> Color {
  self.r += (c.r - self.r) * t
  self.g += (c.g - self.g) * t
  self.b += (c.b - self.b) * t
  self.a += (c.a - self.a) * t
  self
}

///|
/// luminance returns the relative luminance of this color for standard human vision.
pub fn luminance(self : Color) -> Double {
  0.2126 * self.r + 0.7152 * self.g + 0.0722 * self.b
}

///|
/// to_css_string returns a CSS-style string for this color.
pub fn to_css_string(self : Color) -> String {
  match self.a {
    1 => self.to_css_hex_string()
    _ => self.to_css_rgba_string()
  }
}

// to_hex_digit returns a hex digit.

///|
fn to_hex_digit(v : Byte) -> String {
  match v & 0x0f {
    _..<10 as v => "\{v.to_int()}"
    10 => "A"
    11 => "B"
    12 => "C"
    13 => "D"
    14 => "E"
    15 => "F"
    _ => ""
  }
}

// to_hex_byte returns a 2-digit hex string (e.g. "FE").

///|
fn to_hex_byte(v : Byte) -> String {
  let hi = to_hex_digit(v >> 4)
  let lo = to_hex_digit(v & 0x0f)
  "\{hi}\{lo}"
}

// to_hex returns a 6-digit hex string (e.g. "FEDCBA")

///|
fn to_hex(v : UInt) -> String {
  let r = to_hex_byte(((v >> 16) & 0xff).to_byte())
  let g = to_hex_byte(((v >> 8) & 0xff).to_byte())
  let b = to_hex_byte((v & 0xff).to_byte())
  "\{r}\{g}\{b}"
}

///|
/// to_css_hex_string returns a CSS-style hex string for this color.
pub fn to_css_hex_string(self : Color) -> String {
  let s = to_hex(16777216U + self.to_rgb8_number())
  "#\{s}"
}

///|
fn[T : Compare] clamp(v : T, min : T, max : T) -> T {
  if v < min {
    min
  } else if v > max {
    max
  } else {
    v
  }
}

///|
/// to_css_rgba_string returns a CSS-style "rgba()" string for this color.
pub fn to_css_rgba_string(self : Color) -> String {
  let r = clamp(@math.round(self.r * 255).to_int(), 0, 255)
  let g = clamp(@math.round(self.g * 255).to_int(), 0, 255)
  let b = clamp(@math.round(self.b * 255).to_int(), 0, 255)
  let a = clamp(self.a, 0, 1)
  "rgba(\{r},\{g},\{b},\{a})"
}

///|
/// to_rgb8_number returns a bit-packed number in RGB8 format.
pub fn to_rgb8_number(self : Color) -> UInt {
  let r = clamp(@math.round(self.r * 255).to_int(), 0, 255).reinterpret_as_uint()
  let g = clamp(@math.round(self.g * 255).to_int(), 0, 255).reinterpret_as_uint()
  let b = clamp(@math.round(self.b * 255).to_int(), 0, 255).reinterpret_as_uint()
  (r << 16) | (g << 8) | b
}

///|
/// to_hsva converts this color to the HSVA color space, returning
/// [hue, saturation, value, alpha] in the range (0..1).
pub fn to_hsva(self : Color) -> Array[Double] {
  let mut hue = 0.0
  let mut t = 0.0
  let { r, g, b, a: alpha } = self
  let value = @cmp.maximum(@cmp.maximum(r, g), b)
  let delta = value - @cmp.minimum(@cmp.minimum(r, g), b)
  let f = fn(v) { (value - v) / (6.0 * delta) + 0.5 }
  if delta != 0 {
    t = delta / value
    let red = f(r)
    let green = f(g)
    let blue = f(b)
    hue = if r == value {
      blue - green
    } else if g == value {
      red - blue + 1.0 / 3
    } else {
      green - red + 2.0 / 3
    }
    if hue < 0 {
      hue += 1
    } else if hue > 1 {
      hue -= 1
    }
  }
  return [hue, t, value, alpha]
}

///|
let css_colors : Map[String, Array[Int]] = {
  "aliceblue": [240, 248, 255],
  "antiquewhite": [250, 235, 215],
  "aqua": [0, 255, 255],
  "aquamarine": [127, 255, 212],
  "azure": [240, 255, 255],
  "beige": [245, 245, 220],
  "bisque": [255, 228, 196],
  "black": [0, 0, 0],
  "blanchedalmond": [255, 235, 205],
  "blue": [0, 0, 255],
  "blueviolet": [138, 43, 226],
  "brown": [165, 42, 42],
  "burlywood": [222, 184, 135],
  "cadetblue": [95, 158, 160],
  "chartreuse": [127, 255, 0],
  "chocolate": [210, 105, 30],
  "coral": [255, 127, 80],
  "cornflowerblue": [100, 149, 237],
  "cornsilk": [255, 248, 220],
  "crimson": [220, 20, 60],
  "cyan": [0, 255, 255],
  "darkblue": [0, 0, 139],
  "darkcyan": [0, 139, 139],
  "darkgoldenrod": [184, 134, 11],
  "darkgray": [169, 169, 169],
  "darkgreen": [0, 100, 0],
  "darkgrey": [169, 169, 169],
  "darkkhaki": [189, 183, 107],
  "darkmagenta": [139, 0, 139],
  "darkolivegreen": [85, 107, 47],
  "darkorange": [255, 140, 0],
  "darkorchid": [153, 50, 204],
  "darkred": [139, 0, 0],
  "darksalmon": [233, 150, 122],
  "darkseagreen": [143, 188, 143],
  "darkslateblue": [72, 61, 139],
  "darkslategray": [47, 79, 79],
  "darkslategrey": [47, 79, 79],
  "darkturquoise": [0, 206, 209],
  "darkviolet": [148, 0, 211],
  "deeppink": [255, 20, 147],
  "deepskyblue": [0, 191, 255],
  "dimgray": [105, 105, 105],
  "dimgrey": [105, 105, 105],
  "dodgerblue": [30, 144, 255],
  "firebrick": [178, 34, 34],
  "floralwhite": [255, 250, 240],
  "forestgreen": [34, 139, 34],
  "fuchsia": [255, 0, 255],
  "gainsboro": [220, 220, 220],
  "ghostwhite": [248, 248, 255],
  "gold": [255, 215, 0],
  "goldenrod": [218, 165, 32],
  "gray": [128, 128, 128],
  "green": [0, 128, 0],
  "greenyellow": [173, 255, 47],
  "grey": [128, 128, 128],
  "honeydew": [240, 255, 240],
  "hotpink": [255, 105, 180],
  "indianred": [205, 92, 92],
  "indigo": [75, 0, 130],
  "ivory": [255, 255, 240],
  "khaki": [240, 230, 140],
  "lavender": [230, 230, 250],
  "lavenderblush": [255, 240, 245],
  "lawngreen": [124, 252, 0],
  "lemonchiffon": [255, 250, 205],
  "lightblue": [173, 216, 230],
  "lightcoral": [240, 128, 128],
  "lightcyan": [224, 255, 255],
  "lightgoldenrodyellow": [250, 250, 210],
  "lightgray": [211, 211, 211],
  "lightgreen": [144, 238, 144],
  "lightgrey": [211, 211, 211],
  "lightpink": [255, 182, 193],
  "lightsalmon": [255, 160, 122],
  "lightseagreen": [32, 178, 170],
  "lightskyblue": [135, 206, 250],
  "lightslategray": [119, 136, 153],
  "lightslategrey": [119, 136, 153],
  "lightsteelblue": [176, 196, 222],
  "lightyellow": [255, 255, 224],
  "lime": [0, 255, 0],
  "limegreen": [50, 205, 50],
  "linen": [250, 240, 230],
  "magenta": [255, 0, 255],
  "maroon": [128, 0, 0],
  "mediumaquamarine": [102, 205, 170],
  "mediumblue": [0, 0, 205],
  "mediumorchid": [186, 85, 211],
  "mediumpurple": [147, 112, 219],
  "mediumseagreen": [60, 179, 113],
  "mediumslateblue": [123, 104, 238],
  "mediumspringgreen": [0, 250, 154],
  "mediumturquoise": [72, 209, 204],
  "mediumvioletred": [199, 21, 133],
  "midnightblue": [25, 25, 112],
  "mintcream": [245, 255, 250],
  "mistyrose": [255, 228, 225],
  "moccasin": [255, 228, 181],
  "navajowhite": [255, 222, 173],
  "navy": [0, 0, 128],
  "oldlace": [253, 245, 230],
  "olive": [128, 128, 0],
  "olivedrab": [107, 142, 35],
  "orange": [255, 165, 0],
  "orangered": [255, 69, 0],
  "orchid": [218, 112, 214],
  "palegoldenrod": [238, 232, 170],
  "palegreen": [152, 251, 152],
  "paleturquoise": [175, 238, 238],
  "palevioletred": [219, 112, 147],
  "papayawhip": [255, 239, 213],
  "peachpuff": [255, 218, 185],
  "peru": [205, 133, 63],
  "pink": [255, 192, 203],
  "plum": [221, 160, 221],
  "powderblue": [176, 224, 230],
  "purple": [128, 0, 128],
  "red": [255, 0, 0],
  "rosybrown": [188, 143, 143],
  "royalblue": [65, 105, 225],
  "saddlebrown": [139, 69, 19],
  "salmon": [250, 128, 114],
  "sandybrown": [244, 164, 96],
  "seagreen": [46, 139, 87],
  "seashell": [255, 245, 238],
  "sienna": [160, 82, 45],
  "silver": [192, 192, 192],
  "skyblue": [135, 206, 235],
  "slateblue": [106, 90, 205],
  "slategray": [112, 128, 144],
  "slategrey": [112, 128, 144],
  "snow": [255, 250, 250],
  "springgreen": [0, 255, 127],
  "steelblue": [70, 130, 180],
  "tan": [210, 180, 140],
  "teal": [0, 128, 128],
  "thistle": [216, 191, 216],
  "tomato": [255, 99, 71],
  "transparent": [0, 0, 0, 0],
  "turquoise": [64, 224, 208],
  "violet": [238, 130, 238],
  "wheat": [245, 222, 179],
  "white": [255, 255, 255],
  "whitesmoke": [245, 245, 245],
  "yellow": [255, 255, 0],
  "yellowgreen": [154, 205, 50],
  "rebeccapurple": [102, 51, 153],
}
