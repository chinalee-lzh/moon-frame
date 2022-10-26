export property = (cls, propname, getter, setter) ->
  return if string.empty(propname)
  getter = ENSURE.boolean(getter, true)
  setter = ENSURE.boolean(setter, true)
  fsuffix = "#{string.upper(string.sub(propname, 1, 1))}#{string.sub(propname, 2)}"
  if getter
    fname = "get#{fsuffix}"
    cls[fname] = => @[propname] unless isfunction(rawget(cls, fname))
  if setter
    fname = "set#{fsuffix}"
    cls[fname] = (value) => @[propname] = value unless isfunction(rawget(cls, fname))
export classpool = (cls) ->
  pool = {sz: 0, cache: {}}
  pool.get = (...) ->
    local obj
    if pool.sz == 0
      obj = cls(...)
    else
      obj = pool.cache[pool.sz]
      pool.cache[pool.sz] = nil
      pool.sz -= 1
      assert(obj.__free__, "get a busy item from pool. #{cls.__name}")
      safecall(obj.init, obj, ...)
    obj.__free__ = false
    obj
  pool.free = (...) ->
    n = select('#', ...)
    for i = 1, n
      obj = select(i, ...)
      assert(obj.__class == cls, "the obj to free is not from this class. #{cls.__name}")
      assert(not obj.__free__, "duplicate free. #{cls.__name}")
      safecall(obj.free, obj)
      obj.__free__ = true
      pool.sz += 1
      pool.cache[pool.sz] = obj
  pool.clear = ->
    table.clear(pool.cache)
    pool.sz = 0
  cls.Pool = pool
  cls