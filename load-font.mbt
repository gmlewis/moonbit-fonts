///|
/// `load_font` attempts to load a font by its name from the `all-fonts` directory.
/// It expects the font to be in a compressed JSON format (e.g., `font_name.json.gz`).
/// If the font is not found, it raises a `FontError` with instructions on how to
/// generate the font.
pub async fn Font::load_font(font_name : String) -> Font raise FontError {
  let font_path = "all-fonts/\{font_name}.json.gz"
  let exists = @afs.exists(font_path) catch {
    e => raise FontError("Error checking font existence: \{e}")
  }
  if not(exists) {
    let msg =
      #|Font '\{font_name}' not found at '\{font_path}'.
      #|To generate this font, follow these steps:
      #|1. Navigate to the 'moonbit-16-fonts' directory.
      #|2. Ensure you have the 'all-fonts.txt' file containing '\{font_name}'.
      #|3. Run the generation script:
      #|   python3 scripts/compress-all-fonts.py --force --font \{font_name}
      #|4. Rerun your program.
    raise FontError(msg)
  }
  try {
    let data = @afs.read_file(font_path) catch {
      e => raise FontError("Error reading font file: \{e}")
    }
    let bytes = data.binary()
    println("Loaded font data size: \{bytes.length()} bytes")
    let buffer = @io.Buffer::from_bytes(bytes)

    // Decompress the gzip data
    println("Creating gzip reader...")
    let (gzip_reader, err) = @gzip.Reader::new(buffer)
    match err {
      Some(e) => raise FontError("Gzip decompression error: \{e}")
      None => ()
    }
    println("Reading all from gzip reader...")
    let (json_bytes, err) = @io.read_all(gzip_reader)
    match err {
      Some(e) => raise FontError("Read error during decompression: \{e}")
      None => ()
    }
    println("Decompressed size: \{json_bytes.length()} bytes")
    let json_str = json_bytes.to_bytes().to_string()
    println("Parsing JSON...")
    let json = @json.parse(json_str)
    println("Decoding JSON to Font...")
    let font : Font = @json.from_json(json)
    println("Font loaded successfully: \{font.id}")
    font
  } catch {
    @json.JsonDecodeError(e) => raise FontError("JSON decode error: \{e}")
    e => raise FontError("Unexpected error loading font: \{e}")
  }
}
