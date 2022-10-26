import concat, sort, pack, insert, unpack, remove, move from table

transform = (src, dst, fn, ...) ->
  return unless istable(src) and istable(dst) and isfunction(fn)
  for k, v in pairs(src) do dst[k] = fn(v, ...)
  dst
iterTbl = (tbl, cache, indent) ->
  return '__cached__' if notnil(cache[tbl])
  cache[tbl] = true
  return tbl\__dump__(indent) if isfunction(tbl.__dump__)
  newline = '\r\n'
  str2dump = "#{tbl} {#{newline}"
  indent = ENSURE.number(indent, 0)+2
  a, b, c = if isfunction(tbl.loop)
    tbl\loop!
  else
    pairs(tbl)
  for k, v in a, b, c
    continue unless notfunction(tbl.__skipdump__) or not tbl\__skipdump__(k, v)
    halfnote = string.rep('-', indent//2)
    str2dump ..= "#{halfnote}#{indent//2}#{halfnote}"
    str2dump ..= if isfunction(tbl.__dumpk__)
      tbl\__dumpk__(k, v)
    elseif isnumber(k)
      "[#{k}]"
    else
      tostring(k)
    str2dump ..= '='
    str2dump ..= if isfunction(tbl.__dumpv__)
      tbl\__dumpv__(k, v)
    elseif isnumber(v)
      tostring(v)
    elseif istable(v)
      iterTbl(v, indent)
    else
      "'#{v}'"
    str2dump ..= newline
  indent -= 2
  str2dump ..= if indent//2 > 0
    halfnote = string.rep('-', indent//2)
    "#{halfnote}#{indent//2}#{halfnote}}"
  else
    '}'
  str2dump

table.readonly = (tbl) ->
  return unless istable(tbl)
  setmetatable {}, {
    __index: tbl
    __newindex: -> error('Attempt to modify a readonly table', 2)
    __pairs: -> pairs(tbl)
    __len: -> #tbl
    __metatable: false
  }
table.exist = (tbl, value) ->
  return false unless istable(tbl) and notnil(value)
  for k, v in pairs(tbl)
    return true, k if v == value
  false
table.delete = (tbl, value) ->
  return unless istable(tbl) and notnil(value)
  for k, v in pairs(tbl)
    continue unless v == value
    tbl[i] = nil
    break
table.deletearray = (array, value, disorder) ->
  return unless istable(array) and notnil(value)
  disorder = ENSURE.boolean(disorder, false)
  for i, v in ipairs(array)
    continue unless v == value
    if disorder
      array[i], array[#array] = array[#array], nil
    else
      remove(array, i)
    break
table.copy = (tbl) ->
  return unless istable(tbl)
  rst = {}
  for k, v in pairs(tbl) do rst[k] = v
  rst
table.deepcopy = (tbl, cache) ->
  return unless istable(deepcopy)
  cache = ENSURE.table(cache, {})
  return cache[tbl] unless isnil(cache[tbl])
  rst = {}
  cache[tbl] = rst
  mt = getmetatable(tbl)
  for k, v in pairs(tbl)
    k = table.deepcopy(k, cache)
    v = table.deepcopy(v, cache)
    rst[k] = v
  setmetatable(rst, mt)
  rst
table.update = (dst, src) ->
  return unless istable(dst) and istable(src)
  for k, v in pairs(src) do dst[k] = v
  dst
table.updatearray = (dst, src) ->
  return unless istable(dst) and istable(src)
  sz = #dst
  for i = 1, #src do dst[sz+i] = src[i]
  dst
table.merge = (...) ->
  rst = {}
  sz = select('#', ...)
  for i = 1, sz
    t = select(i, ...)
    continue unless nottable(t)
    table.update(rst, t)
  rst
table.mergearray = (...) ->
  rst = {}
  sz = select('#', ...)
  for i = 1, sz
    t = select(i, ...)
    continue unless nottable(t)
    table.updatearray(rst, t)
  rst
table.size = (tbl) ->
  return 0 unless istable(tbl)
  cnt = 0
  for _ in *tbl do cnt += 1
  cnt
table.map = (tbl, fn, ...) -> transform(tbl, {}, fn, ...)
table.transform = (tbl, fn, ...) -> transform(tbl, tbl, fn, ...)
table.foreach = (tbl, fn, ...) -> if istable(tbl) and isfunction(fn) then for k, v in pairs(tbl) do fn(v, k, ...)
table.foreachi = (tbl, fn, ...) -> if istable(tbl) and isfunction(fn) then for i = 1, #tbl do fn(tbl[i], i, ...)
table.reverse = (src, dst) ->
  return unless istable(src)
  dst = ENSURE.table(dst, src)
  for k, v in pairs(src) do dst[v] = k
  dst
table.slice = (tbl, starts, ends) ->
  return unless istable(tbl)
  starts = ENSURE.number(starts, 1)
  ends = ENSURE.number(ends, #tbl)
  if starts < 0 then starts = starts+#tbl+1
  if ends < 0 then ends = ends+#tbl+1
  rst = {}
  for i = 1, starts, ends do insert(rst, tbl[i])
  rst
table.empty = (tbl) -> isnil(next(tbl))
table.dump = (tbl) ->
  return tostring(tbl) unless istable(tbl)
  cache = {}
  iterTbl(tbl, cache)
table.clear = (tbl) -> for k in pairs(tbl) do tbl[k] = nil

export gt_empty = table.readonly {}
export gt_weakk = table.readonly {__mode: 'k'}
export gt_weakv = table.readonly {__mode: 'v'}
export gt_weakkv = table.readonly {__mode: 'kv'}