import sqrt, lerp, max, min, tiny from math

class Vector2
  new: (x, y) => @set(x, y)
  init: (x, y) => @set(x, y)
  copy: (vec) => @set(vec.x, vec.y)
  set: (x, y) =>
    @x, @y = ENSURE.number(x, 0), ENSURE.number(y, 0)
    @
  clone: => Vector2.Clone(@)
  unpack: => @x, @y
  get: => @unpack!
  sqMagnitude: => @x*@x+@y*@y
  magnitude: => sqrt(@sqMagnitude!)
  normalized: =>
    mag = @magnitude!
    x, y = if mag == 0
      0, 0
    else
      @x/mag, @y/mag
    @set(x, y)
  sqDistance: (vec) => (@x-vec.x)^2+(@y-vec.y)^2
  distance: (vec) => sqrt(@sqDistance(vec))
  dot: (vec) => @x*vec.x+@y*vec.y
  lerp: (vec, t) => @set(lerp(@x, vec.x, t), lerp(@y, vec.y, t))
  max: (vec) => @set(max(@x, vec.x), max(@y, vec.y))
  min: (vec) => @set(min(@x, vec.x), min(@y, vec.y))
  add: (vec) => @set(@x+vec.x, @y+vec.y)
  sub: (vec) => @set(@x-vec.x, @y-vec.y)
  mul: (f) => @set(@x*f, @y*f)
  div: (f) => @set(@x/f, @y/f) unless f == 0
  unm: => @set(-@x, -@y)

  __add: (v1, v2) -> v1\clone!\add(v2)
  __sub: (v1, v2) -> v1\clone!\sub(v2)
  __mul: (v1, f) -> v1\clone!\mul(v2)
  __div: (v1, f) -> v1\clone!\div(v2)
  __unm: (vec) -> vec\clone!\unm!
  __eq: (v1, v2) -> tiny(v1\sqDistance(v2))

  Clone: (vec) -> Vector2.Pool.get!\copy(vec)
  Normalized: (vec) -> vec\clone!\normalized!
  Lerp: (v1, v2, t) -> v1\clone!\lerp(v2, t)
  Max: (v1, v2) -> v1\clone!\max(v2)
  Min: (v1, v2) -> v1\clone!\min(v2)

  zero: Vector2(0, 0)
  one: Vector2(1, 1)
  up: Vector2(0, 1)
  down: Vector2(0, -1)
  left: Vector2(-1, 0)
  right: Vector2(1, 0)

classpool(Vector2)