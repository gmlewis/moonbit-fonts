// This file is based on the Go implementation found here:
// https://cs.opensource.google/go/go/+/refs/tags/go1.23.3:src/image/geom_test.go
// which has the copyright notice:
// Copyright 2015 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

type! TestError String derive(Show, Eq)

fn test_in(f : @fonts.Rectangle, g : @fonts.Rectangle) -> TestError? {
  if not(f.is_in(g)) {
    return Some(TestError("f=\{f}, f.is_in(\{g}): got false, want true"))
  }
  for y = f.min.y; y < f.max.y; y = y + 1 {
    for x = f.min.x; x < f.max.x; x = x + 1 {
      let p = @fonts.pt(x, y)
      if not(p.is_in(g)) {
        return Some(TestError("p=\{p}, p.is_in(\{g}): got false, want true"))
      }
    }
  }
  None
}

test "every point in f is in g" {
  let rects = [
    @fonts.rect(0, 0, 10, 10),
    @fonts.rect(10, 0, 20, 10),
    @fonts.rect(1, 2, 3, 4),
    @fonts.rect(4, 6, 10, 10),
    @fonts.rect(2, 3, 12, 5),
    @fonts.rect(-1, -2, 0, 0),
    @fonts.rect(-1, -2, 4, 6),
    @fonts.rect(-10, -20, 30, 40),
    @fonts.rect(8, 8, 8, 8),
    @fonts.rect(88, 88, 88, 88),
    @fonts.rect(6, 5, 4, 3),
  ]

  // r == s should be equivalent to every point in r being in s, and every
  // point in s being in r.
  for r in rects {
    for s in rects {
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
      let (is_zero, overlaps) = (a == @fonts.Rectangle::new(), r.overlaps(s))
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
        if b.empty() {
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
      if a.empty() {
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
