// This file is based on the Go implementation found here:
// https://cs.opensource.google/go/go/+/refs/tags/go1.23.3:src/image/geom_test.go
// which has the copyright notice:
// Copyright 2015 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

///|
suberror TestError {
  TestError(String)
} derive(Show, Eq)

///|
test "BoundingBox::new" {
  // Test default values (both min and max are zero vectors)
  let bb1 = BoundingBox::new()
  inspect(bb1.min.x, content="0")
  inspect(bb1.min.y, content="0")
  inspect(bb1.max.x, content="0")
  inspect(bb1.max.y, content="0")

  // Test custom values
  let bb2 = BoundingBox::new(min=vec2(-1, -2), max=vec2(3, 4))
  inspect(bb2.min.x, content="-1")
  inspect(bb2.min.y, content="-2")
  inspect(bb2.max.x, content="3")
  inspect(bb2.max.y, content="4")

  // Test zero-area bounding box
  let bb3 = BoundingBox::new(min=vec2(5, 5), max=vec2(5, 5))
  inspect(bb3.min.x, content="5")
  inspect(bb3.min.y, content="5")
  inspect(bb3.max.x, content="5")
  inspect(bb3.max.y, content="5")
}

///|
test "BoundingBox::from_points/normal" {
  let points = [
    vec2(-1.0, -1.0),
    vec2(1.0, -1.0),
    vec2(1.0, 1.0),
    vec2(-1.0, 1.0),
  ]
  let bbox = BoundingBox::from_points(points)
  inspect(bbox.min.x, content="-1")
  inspect(bbox.min.y, content="-1")
  inspect(bbox.max.x, content="1")
  inspect(bbox.max.y, content="1")
}

///|
test "clone/basic" {
  let bbox = BoundingBox::new(min=vec2(1.0, 2.0), max=vec2(3.0, 4.0))
  let cloned = bbox.clone()
  inspect(cloned.min.x, content="1")
  inspect(cloned.min.y, content="2")
  inspect(cloned.max.x, content="3")
  inspect(cloned.max.y, content="4")
}

///|
test "BoundingBox::center" {
  let bbox = BoundingBox::new(min=vec2(0.0, 0.0), max=vec2(1.0, 1.0))
  inspect(bbox.center(), content="{x: 0.5, y: 0.5}")
}

///|
test "BoundingBox::width" {
  let box1 = BoundingBox::new(min=vec2(1.0, 2.0), max=vec2(4.0, 6.0))
  inspect(box1.width(), content="3")
}

///|
test "BoundingBox::height" {
  let bbox = BoundingBox::new(min=vec2(0, 1), max=vec2(10, 5))
  inspect(bbox.height(), content="4")
}

///|
test "BoundingBox::area" {
  let box1 = BoundingBox::new(min=vec2(0, 0), max=vec2(5, 4))
  inspect(box1.area(), content="20")
}

///|
test "BoundingBox::contains_point" {
  let bbox = BoundingBox::new(min=vec2(0.0, 0.0), max=vec2(10.0, 10.0))
  let point = vec2(5.0, 5.0)
  inspect(bbox.contains_point(point), content="true")
  let outside = vec2(15.0, 5.0)
  inspect(bbox.contains_point(outside), content="false")
}

///|
test "BoundingBox::overlaps_bounding_box" {
  let box1 = BoundingBox::new(min=vec2(0, 0), max=vec2(2, 2))
  let box2 = BoundingBox::new(min=vec2(1, 1), max=vec2(3, 3))
  // Partial overlap should be true now
  inspect(box1.overlaps_bounding_box(box2), content="true")
  let box3 = BoundingBox::new(min=vec2(3, 3), max=vec2(4, 4))
  inspect(box1.overlaps_bounding_box(box3), content="false")
}

///|
fn test_in(f : BoundingBox, g : BoundingBox) -> TestError? {
  if not(f.is_in(g)) {
    return Some(TestError("f=\{f}, f.is_in(\{g}): got false, want true"))
  }
  for y = f.min.y; y < f.max.y; y = y + 1 {
    for x = f.min.x; x < f.max.x; x = x + 1 {
      let p = pt(x, y)
      if not(p.is_in(g)) {
        return Some(TestError("p=\{p}, p.is_in(\{g}): got false, want true"))
      }
    }
  }
  None
}

///|
test "every point in f is in g" {
  let rects = [
    rect(0, 0, 10, 10),
    rect(10, 0, 20, 10),
    rect(1, 2, 3, 4),
    rect(4, 6, 10, 10),
    rect(2, 3, 12, 5),
    rect(-1, -2, 0, 0),
    rect(-1, -2, 4, 6),
    rect(-10, -20, 30, 40),
    rect(8, 8, 8, 8),
    rect(88, 88, 88, 88),
    rect(6, 5, 4, 3),
  ]

  // r == s should be equivalent to every point in r being in s, and every
  // point in s being in r. Skip test for two empty rectangles.
  for r in rects {
    for s in rects {
      if r.is_empty() && s.is_empty() {
        continue
      }
      let got = r == s
      let want = test_in(r, s) == None && test_in(s, r) == None
      if got != want {
        raise TestError("Eq: r=\{r}, s=\{s}: got \{got}, want \{want}")
      }
    }
  }

  // The intersection should be the largest rectangle a such that every point
  // in a is both in r and in s.
  for r in rects {
    for s in rects {
      let a = r.intersect(s)
      let err = test_in(a, r)
      if err != None {
        raise TestError("Intersect: r=\{r}, s=\{s}, a\{a}, a not in r: \{err}")
      }
      let err = test_in(a, s)
      if err != None {
        raise TestError("Intersect: r=\{r}, s=\{s}, a\{a}, a not in s: \{err}")
      }
      let (is_zero, overlaps) = (a == BoundingBox::new(), r.overlaps(s))
      if is_zero == overlaps {
        raise TestError(
          "Intersect: r=\{r}, s=\{s}, a\{a}: is_zero=\{is_zero} same as overlaps=\{overlaps}",
        )
      }
      let larger_than_a = [a.clone(), a.clone(), a.clone(), a.clone()]
      larger_than_a[0].min.x -= 1
      larger_than_a[1].min.y -= 1
      larger_than_a[2].max.x += 1
      larger_than_a[3].max.y += 1
      for i, b in larger_than_a {
        if b.is_empty() {
          // b isn't actually larger than a.
          continue
        }
        if test_in(b, r) == None && test_in(b, s) == None {
          raise TestError(
            "Intersect: r=\{r}, s=\{s}, a\{a}, b=\{b}, i=\{i}: intersection could be larger",
          )
        }
      }
    }
  }

  // The union should be the smallest rectangle a such that every point in r
  // is in a and every point in s is in a.
  for r in rects {
    for s in rects {
      let a = r.union(s)
      let err = test_in(r, a)
      if err != None {
        raise TestError("Union: r=\{r}, s=\{s}, a\{a}, r not in a: \{err}")
      }
      let err = test_in(s, a)
      if err != None {
        raise TestError("Union: r=\{r}, s=\{s}, a\{a}, s not in a: \{err}")
      }
      if a.is_empty() {
        // You can't get any smaller than a.
        continue
      }
      let smaller_than_a = [a.clone(), a.clone(), a.clone(), a.clone()]
      smaller_than_a[0].min.x += 1
      smaller_than_a[1].min.y += 1
      smaller_than_a[2].max.x -= 1
      smaller_than_a[3].max.y -= 1
      for i, b in smaller_than_a {
        if test_in(r, b) == None && test_in(s, b) == None {
          raise TestError(
            "Union: r=\{r}, s=\{s}, a\{a}, b=\{b}, i=\{i}: union could be smaller",
          )
        }
      }
    }
  }
}
