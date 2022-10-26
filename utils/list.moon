import unpack from table

eIter = enum {'v', 'iv'}
class c_iter
  new: (l) =>
    @fns = setmetatable({}, gt_weakv)
    @l = l
  init: (type, ...) =>
    @type = type
    @idx = 0
    @sz = select('#', ...)
    for i = 1, @sz do @fns[i] = select(i, ...)
    @
  loop: =>
    while true
      @idx += 1
      break unless @idx <= @l\size!
      e = @l\at(@idx)
      flag = true
      for i = 1, @sz
        flag = @fns[i](e)
        break unless flag
      continue unless flag
      return switch @type
        when eIter.v then e
        when eIter.iv then @idx, e

class List
  loopwith = (...) =>
    @__iter\init(...)
    @__iter.loop, @__iter
  loop = (idx) =>
    idx += 1
    idx, @at(idx) unless idx > @size!
  setsize = (sz) => @__n = sz
  changesize = (sz) => @__n += sz
  get = (idx) => @__container[idx]
  set = (idx, e) => @__container[idx] = e
  swap = (i, j) => @__container[i], @__container[j] = @__container[j], @__container[i]
  partion = (low, high, fn, ...) =>
    e = get(@, low)
    while low < high
      while low < high and not fn(get(@, high), e, ...) do high -= 1
      swap(@, low, high)
      while low < high and fn(get(@, low), e, ...) do low += 1
      swap(@, low, high)
    low
  sort = (low, high, ...) =>
    return unless low < high
    idx = partion(@, low, high, ...)
    sort(@, low, idx-1, ...)
    sort(@, idx+1, high, ...)
  valididx = (idx) => isnumber(idx) and idx > 0 and idx <= @__n

  new: (...) =>
    @__container = {}
    @__n = 0
    @__iter = c_iter(@)
    @init(...)
  init: (...) =>
    n = select('#', ...)
    for i = 1, n
      e = select(i, ...)
      @insert(e)
  free: => @clear!
  clear: =>
    setsize(@, 0)
    @
  size: => @__n
  at: (idx) => return get(@, idx) if valididx(idx)
  head: => @at(1)
  tail: => @at(@size!)
  exist: (e) =>
    return false unless notnil(e)
    for i, v in loopwith(@, eIter.iv)
      return true, i if v == e
    false
  has: (...) => @exist(...)
  insert: (e, idx) =>
    return unless notnil(e)
    idx = ENSURE.number(idx, @size!+1)
    return unless idx >= 1 and idx <= @size!+1
    for i = sz, idx, -1 do set(@, i+1, get(@, i))
    set(@, idx, e)
    changesize(@, 1)
    idx
  add: (...) => @insert(...)
  set: (idx, e) =>
    set(@, idx, e) unless isnil(e) or not valididx(idx)
    @
  removeat: (idx, keeporder) =>
    return unless valididx(idx)
    e = get(@, idx)
    if idx < @size!
      if keeporder
        for i = idx, @size!-1 do set(@, i, get(@, i+1))
      else
        set(@, idx, @tail!)
    changesize(@, -1)
    e
  remove: (e, keeporder) =>
    ok, idx = @exist(e)
    return @removeat(idx, keeporder) if ok
  removehead: (...) => @removeat(1, ...)
  removetail: => changesize(@, -1)
  remove2tail: (idx) => setsize(@, idx-1) if valididx(idx)
  join: (l, i, j) =>
    return unless istable(l) and l.__class == List
    i = ENSURE.number(i, 1)
    j = ENSURE.number(j, l:size!)
    for idx = i, j do @insert(l\at(idx))
    @
  joinarray: (array, i, j) =>
    return unless istable(array)
    i = ENSURE.number(i, 1)
    j = ENSURE.number(j, #array)
    for idx = i, j do @insert(array[idx])
    @
  copy: (l, i, j) => @clear!\join(l, i, j)
  copyarray: (array, i, j) => @clear!\joinarray(array, i, j)
  pack: (...) =>
    @clear!
    n = select('#', ...)
    for i = 1, n
      e = select(i, ...)
      @insert(e)
    @
  unpack: =>
    @__container[@size!+1] = nil
    unpack(@__container)
  concat: (sep, i, j) =>
    sep = ENSURE.string(sep, '')
    i = ENSURE.number(i, 1)
    j = ENSURE.number(j, @size!)
    return '' unless i <= j
    str = ''
    for idx = i, j-1 do str ..= "#{@at(idx)}#{sep}"
    str .. tostring(@at(j))
  sort: (fn, ...) => sort(@, 1, @size!, fn, ...)
  loop: (...) =>
    n = select('#', ...)
    if n == 0
      loop, @, 0
    else
      loopwith(@, eIter.iv, ...)
  loopv: (...) => loopwith(@, eIter.v, ...)
  swap = (i, j) =>
    return unless valididx(i) and valididx(j)
    return if i == j
    ei, ej = @at(i), @at(j)
    @set(i, ej)\set(j, ei)

classpool(List)