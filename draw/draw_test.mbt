///|
test "@draw.dedupe_points/no_duplicates" {
  let points = [vec2(0, 0), vec2(1, 1), vec2(2, 2)]
  let deduped = @draw.dedupe_points(points)
  inspect(deduped.length(), content="3")
  inspect(deduped[0], content="{x: 0, y: 0}")
  inspect(deduped[1], content="{x: 1, y: 1}")
  inspect(deduped[2], content="{x: 2, y: 2}")
}

///|
test "@draw.dedupe_points/with_duplicates" {
  let points = [vec2(0, 0), vec2(0, 0), vec2(1, 1), vec2(1, 1), vec2(2, 2)]
  let deduped = @draw.dedupe_points(points)
  inspect(deduped.length(), content="3")
  inspect(deduped[0], content="{x: 0, y: 0}")
  inspect(deduped[1], content="{x: 1, y: 1}")
  inspect(deduped[2], content="{x: 2, y: 2}")
}

///|
test "@draw.dedupe_points/near_duplicates" {
  let points = [vec2(0, 0), vec2(0.000000001, 0), vec2(1, 1)]
  let deduped = @draw.dedupe_points(points)
  inspect(deduped.length(), content="2")
  inspect(deduped[0], content="{x: 0, y: 0}")
  inspect(deduped[1], content="{x: 1, y: 1}")
}

///|
test "@draw.dedupe_points/epsilon_param" {
  let points = [vec2(1, 0), vec2(1 + 1.e-6, 0)]
  let deduped_default = @draw.dedupe_points(points)
  inspect(deduped_default.length(), content="2")
  let deduped_large = @draw.dedupe_points(points, epsilon=1.e-3)
  inspect(deduped_large.length(), content="1")
}
