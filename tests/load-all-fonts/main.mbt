///|
async fn main {
  // must be run from this directory
  let data = @fs.read_file("../../all-fonts.txt")
  let content = data.text()
  let lines = content.split("\n")
  let mut total = 0
  let mut failed = 0

  //
  async fn write_progress(msg : String) -> Unit {
    // Best-effort terminal output; ignore failures.
    @stdio.stdout.write(msg) catch {
      _ => ()
    }
  }

  //
  for line in lines {
    let line = line.trim()
    if line == "" {
      continue
    }
    total = total + 1
    // Extract short name: gmlewis/fonts-a/aaarghnormal -> aaarghnormal
    let parts = line.split("/").collect()
    if parts.length() == 0 {
      continue
    }
    let short_name_view = parts[parts.length() - 1]
    let short_name = short_name_view.to_string()
    if short_name == "" {
      println("Could not extract font name from line: \{line}")
      failed = failed + 1
      continue
    }
    write_progress("Loading \{short_name}... ")
    try {
      let font = @loader.load_font(short_name)
      write_progress("OK: \{font.id} has \{font.glyphs.length()} glyphs.\n")
    } catch {
      e => {
        write_progress("FAILED: \{e}\n\n")
        failed = failed + 1
      }
    }
  }
  println("\nSummary: \{total} fonts checked, \{failed} failed.")
  if failed > 0 {
    abort("")
  }
}
