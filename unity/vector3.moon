import sqrt, lerp, max, min, tiny from math

project = (v1, v2) ->
  n1 = v2\sqMagnitude!
  return 0, 0, 0 if tiny(n1)
  n2 = v1\dot(v2)
  n = n2/n1
  v2.x*n, v2.y*n, v2.z*n

class Vector3
  new: (x, y, z) => @set(x, y, z)
  init: (x, y, z) => @set(x, y, z)
  copy: (vec) => @set(vec.x, vec.y, vec.z)
  set: (x, y, z) =>
    @x, @y, @z = ENSURE.number(x, 0), ENSURE.number(y, 0), ENSURE.number(z, 0)
    @
  clone: => Vector3.Clone(@)
  unpack: => @x, @y, @z
  get: => @unpack!
  sqMagnitude: => @x*@x+@y*@y+@z*@z
  magnitude: => sqrt(@sqMagnitude!)
  normalized: =>
    mag = @magnitude!
    x, y, z = if mag == 0
      0, 0, 0
    else
      @x/mag, @y/mag, @z/mag
    @set(x, y)
  sqDistance: (vec) => (@x-vec.x)^2+(@y-vec.y)^2+(@z-vec.z)^2
  distance: (vec) => sqrt(@sqDistance(vec))
  dot: (vec) => @x*vec.x+@y*vec.y+@z*vec.z
  cross: (vec) => @set(@y*vec.z-@z*vec.y, @z*vec.x-@x*vec.z, @x*vec.y-@y*vec.x)
  project: (vec) => @set(project(@, vec))
  projectOnPlane: (plane) =>
    x, y, z = project(@, plane)
    @set(@x-x, @y-y, @z-z)
  lerp: (vec, t) => @set(lerp(@x, vec.x, t), lerp(@y, vec.y, t), lerp(@z, vec.z, t))
  max: (vec) => @set(max(@x, vec.x), max(@y, vec.y), max(@z, vec.z))
  min: (vec) => @set(min(@x, vec.x), min(@y, vec.y), min(@z, vec.z))
  add: (vec) => @set(@x+vec.x, @y+vec.y, @z+vec.z)
  sub: (vec) => @set(@x-vec.x, @y-vec.y, @z-vec.z)
  mul: (f) => @set(@x*f, @y*f, @z*f)
  div: (f) => @set(@x/f, @y/f, @z/f) unless f == 0
  unm: => @set(-@x, -@y, -@z)

  __add: (v1, v2) -> v1\clone!\add(v2)
  __sub: (v1, v2) -> v1\clone!\sub(v2)
  __mul: (v1, f) -> v1\clone!\mul(v2)
  __div: (v1, f) -> v1\clone!\div(v2)
  __unm: (vec) -> vec\clone!\unm!
  __eq: (v1, v2) -> tiny(v1\sqDistance(v2))

  Clone: (vec) -> Vector3.Pool.get!\copy(vec)
  Normalized: (vec) -> vec\clone!\normalized!
  Lerp: (v1, v2, t) -> v1\clone!\lerp(v2, t)
  Max: (v1, v2) -> v1\clone!\max(v2)
  Min: (v1, v2) -> v1\clone!\min(v2)
  Cross: (v1, v2) -> v1\clone!\cross(v2)
  Project: (v1, v2) -> v1\clone!\project(v2)
  ProjectOnPlane: (v1, plane) -> v1\clone!\projectOnPlane(v2)

  zero: Vector3(0, 0, 0)
  one: Vector3(1, 1, 1)
  up: Vector3(0, 1, 0)
  down: Vector3(0, -1, 0)
  left: Vector3(-1, 0, 0)
  right: Vector3(1, 0, 0)
  forward: Vector3(0, 0, 1)
  back: Vector3(0, 0, -1)

classpool(Vector3)