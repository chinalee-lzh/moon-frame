import pack, unpack from table
cachenumber = {}

export *
safecall = (fn, ...) -> fn(...) unless notfunction(fn)
ifcall = (cond, fn, ...) -> fn(...) unless not cond or notfunction(fn)
gf_empty = ->
gf_true = -> true
gf_false = -> false
gf_number = (n) ->
  cachenumber[n] = ENSURE.func(cachenumber[n], -> n)
  cachenumber[n]
gf_bind = (fn, ...) ->
  return unless isfunction(fn)
  params = pack ...
  (...) -> fn(unpack(params), ...)

local ENUM_HOLDER_STRING
ENUM_HOLDER_STRING = '__holder__'
enum = (tbl, startvalue) ->
  return unless istable(tbl)
  startvalue = ENSURE.number(startvalue, 1)
  rst = {}
  mt = {}
  idxholder = 0
  for v in *tbl
    if v == ENUM_HOLDER_STRING
      idxholder += 1
      v = "#{ENUM_HOLDER_STRING}#{idxholder}"
    rst[v] = startvalue
    startvalue += 1
    mt[startvalue] = v
  mt.n = #tbl
  setmetatable(rst, {__index: mt})
enum0 = (tbl) -> enum(tbl, 0)
setfenv = (fn, env) ->
  i = 1
  while true
    name = debug.getupvalue(fn, i)
    break unless notnil(name)
    debug.upvaluejoin(fn, i, (-> env), 1) if name == '_ENV'
    i += 1
  fn