///|
fn main {
  let font = @aaarghnormal.font

  // Create some "cards" for our gallery
  let cards = []
  let colors = [
    @draw.Color::new(r=0.2, g=0.4, b=0.8), // Blue
    @draw.Color::new(r=0.8, g=0.2, b=0.2), // Red
    @draw.Color::new(r=0.2, g=0.7, b=0.3), // Green
    @draw.Color::new(r=0.9, g=0.6, b=0.1), // Orange
    @draw.Color::new(r=0.5, g=0.2, b=0.7), // Purple
    @draw.Color::new(r=0.1, g=0.7, b=0.8), // Cyan
  ]
  //
  let labels = ["Velocity", "Pressure", "Engine", "Fuel", "Temp", "Cabin"]
  let values = ["842 km/h", "101.3 kPa", "Optimal", "82%", "22°C", "Normal"]
  for i = 0; i < 6; i = i + 1 {
    let title = @draw.text(font, labels[i], size=0.2, align=Center).with_style(
      fill=@draw.Color::white().as_fill(),
    ) catch {
      _ => continue
    }
    //
    let value = @draw.text(font, values[i], size=0.4, align=Center).with_style(
      fill=@draw.Color::white().as_fill(),
    ) catch {
      _ => continue
    }
    //
    let card_content = @draw.column([title, value], spacing=0.2)
    let card = card_content
      .with_margin(top=0.3, right=0.4, bottom=0.3, left=0.4)
      .with_background(colors[i])
    //
    cards.push(card)
  }

  // Header
  let header_text = @draw.text(font, "Flight Dashboard", size=0.8, align=Center).with_style(
    fill=@draw.Color::new(r=0.1, g=0.1, b=0.2).as_fill(),
  ) catch {
    _ => return
  }
  //
  let sub_header = @draw.text(
    font,
    "System Status Overview",
    size=0.3,
    align=Center,
  ).with_style(fill=@draw.Color::new(r=0.4, g=0.4, b=0.5).as_fill()) catch {
    _ => return
  }
  //
  let header = @draw.column([header_text, sub_header], spacing=0.1)

  // Layout the cards in a grid
  let card_grid = @draw.grid(cards, 3, h_spacing=0.3, v_spacing=0.3)

  // Assemble the final scene
  let scene = @draw.column([header, card_grid], spacing=0.8, alignment=Center)

  // Add a final background and margin to the whole thing
  let final_graphic = scene
    .with_margin(top=0.5, right=0.5, bottom=0.5, left=0.5)
    .with_background(@draw.Color::new(r=0.95, g=0.95, b=0.97))
  println(@svg.from_graphic(final_graphic, y_up=false))
}
