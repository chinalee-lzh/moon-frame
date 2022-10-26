List = include 'utils.list'

eIter = enum {'v', 'kv'}
class c_iter
  new: (d) =>
    @fns = setmetatable({}, gt_weakv)
    @d = d
  init: (type, ...) =>
    @type = type
    @idx = 0
    @sz = select('#', ...)
    for i = 1, @sz do @fns[i] = select(i, ...)
    @
  loop: =>
    while true
      @idx += 1
      break unless @idx <= @d\size!
      value, key = @d\at(@idx)
      flag = true
      for i = 1, @sz
        flag = @fns[i](value, key)
        break unless flag
      continue unless flag
      return switch @type
        when eIter.v then value
        when eIter.kv then key, value

class Dict
  loop = (...) =>
    @__iter\init(...)
    @__iter.loop, @__iter
  new: =>
    @__container = {}
    @__iter = c_iter(@)
    @init!
  init: => @__keylist = List.Pool.get!
  free: => @clear!
  clear: =>
    @__container = {}
    List.Pool.free(@__keylist)
  size: => @__keylist\size!
  get: (key) => return @__container[key], key unless isnil(key)
  exist: (key) => notnil(@get(key))
  has: (...) => @exist(...)
  set: (key, value) =>
    return unless notnil(key) and notnil(value)
    @__keylist\add(key) unless @__keylist\has(key)
    @__container[key] = value
    value
  add: (key, value) =>
    return unless notnil(key) and notnil(value)
    return if @__keylist\has(key)
    @__keylist\add(key)
    @__container[key] = value
    value
  del: (key) =>
    return unless notnil(key)
    value = @get(key)
    return unless notnil(value)
    @__container[key] = nil
    @__keylist\remove(key)
    value
  at: (idx) => @get(@__keylist\at(idx))
  head: => @at(1)
  tail: => @at(@size!)
  copy: => (d) =>
    return unless istable(d) and d.__class == Dict
    @clear!
    for k, v in d\loop! do @add(k, v)
    @
  sort: (fn) => @__keylist\sort(fn)
  loop: (...) => loop(@, eIter.kv, ...)
  loopv: (...) => loop(@, eIter.v, ...)

classpool(Dict)