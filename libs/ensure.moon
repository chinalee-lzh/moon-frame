check = (fn, v1, v2, ...) ->
  return v1 if fn(v1)
  return v2 if fn(v2)
  sz = select('#', ...)
  for i = 1, sz
    v = select(i, ...)
    return v if fn(v)
export ENSURE = {
  number: (...) -> check(isnumber, ...)
  string: (...) -> check(isstring, ...)
  boolean: (...) -> check(isboolean, ...)
  table: (...) -> check(istable, ...)
  func: (...) -> check(isfunction, ...)
}