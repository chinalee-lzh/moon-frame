import abs, floor from math

ERROR = 1e-20

math.tiny = (value) -> abs(value) < ERROR
math.gcd = (m, n) ->
  return m if m == n
  if m > n
    math.gcd(m-n, n)
  else
    math.gcd(n-m, m)
math.clamp = (value, minvalue, maxvalue) ->
  if value < minvalue
    minvalue
  elseif value > maxvalue
    maxvalue
  else
    value
math.clamp01 = (value) -> math.clamp(value, 0, 1)
math.lerp = (x, y, t) -> x+(y-x)*math.clamp01(t)
math.round = (value) -> floor(value+0.5)
math.approximately = (x, y) -> math.tiny(x-y)