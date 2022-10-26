logd = print
loge = print

local memory

---------------------------------------------- monitor ----------------------------------------------
_DEFAULT_MONITOR_MODULE_ = -999
monitor = {
  init: =>
    return if @initialized
    @leaks = setmetatable({}, gt_weakkv)
    @initialized = true
  add: (obj, name, module) =>
    return logd 'the obj added to monitor must has a name' if string.empty(name)
    return logd 'the obj added to monitor should not be a value' unless istable(obj) or isfunction(obj) or isthread(obj) or isuserdata(obj)
    @init!
    module = _DEFAULT_MONITOR_MODULE_ unless notnil(module)
    t = @leaks[module]
    if nottable(t)
      t = {}
      @leaks[module] = t
    t[name] = obj
  check: (name, module) =>
    @init!
    module = _DEFAULT_MONITOR_MODULE_ unless notnil(module)
    t = @leaks[module]
    return unless istable(t)
    if string.empty(name)
      for k, v in pairs(t) do loge "find a leak obj. name: #{k}. obj: #{v}"
    else
      obj = t[name]
      loge "find a leak obj. name: #{name}. obj: #{obj}" unless isnil(obj)
}
---------------------------------------------- monitor ----------------------------------------------

---------------------------------------------- snapshot ----------------------------------------------
_CLASS_NAME_FIELD_ = {'__name'}
_SCAN_TYPES_ = {'table', 'string', 'thread', 'userdata', 'function'}
_TYPE_PREFIX_ = '--**'
_OBJ_SPLIT_ = '::'
_ROUTE_PREFIX_ = '    **'
_MT_ = {__mode: 'k'}
local mapCollect

createRefRecord = ->
  record = {
    __visited__: setmetatable({}, _MT_)
    details: {}
  }
  for v in *_SCAN_TYPES_ do record.details[v] = setmetatable({}, _MT_)
  record
getVisited = (obj, record) -> record.__visited__[obj] or 0
setVisited = (obj, record) -> record.__visited__[obj] = (record.__visited__[obj] or 0)+1
checkSpecific = (obj, specifics) -> isnil(specifics) or notnil(specifics[obj])
ensureObjRecord = (record, obj) ->
  cache = record.details[type(obj)]
  return unless notnil(cache)
  cache[obj] = cache[obj] or {count: 0, route: {}}
  cache[obj]
scanObjects = (name, obj, record, findall, specificObjs) ->
  return unless notnil(obj) and obj ~= memory
  if checkSpecific(obj, specificObjs)
    return unless getVisited(obj, record) == 0 or findall
    robj = ensureObjRecord(record, obj)
    return unless notnil(robj)
    robj.count += 1
  setVisited(obj, record)
  name = '' unless isstring(name)
  fn = mapCollect[type(obj)]
  fn(name, obj, record, findall, specificObjs) unless notfunction(fn)
scanTable = (name, obj, record, findall, specificObjs) ->
  for v in *_CLASS_NAME_FIELD_
    str = rawget(obj, v)
    name = "#{name}[class: #{str}]" unless notstring(str)
  name ..= '[_G]' if rawequal(obj, _G)
  if checkSpecific(obj, specificObjs)
    robj = ensureObjRecord(record, obj)
    table.insert(robj.route, name)
  return unless getVisited(obj, record) == 0
  weakk, weakv, mt = false, false, getmetatable(obj)
  if istable(mt)
    mode = rawget(mt, '__mode')
    if isstring(mode)
      weakk = notnil(string.find(mode, 'k'))
      weakv = notnil(string.find(mode, 'v'))
  for k, v in pairs(obj)
    local kstr
    if not weakk
      kstr = if istable(k)
        '[key:tbl]'
      elseif isfunction(k)
        '[key:func]'
      elseif isthread(k)
        '[key:thread]'
      elseif isuserdata(k)
        '[key:userdata]'
      scanObjects(name .. '.' .. kstr, k, record, findall, specificObjs) unless isnil(kstr)
    if not weakv
      vstr = if isnil(kstr)
        tostring(k)
      else
        '[value]'
      scanObjects(name .. '.' .. vstr, v, record, findall, specificObjs)
  scanObjects(name .. '.[mt]', mt, record, findall, specificObjs) unless nottable(mt)
scanFunction = (name, obj, record, findall, specificObjs) ->
  info = debug.getinfo(obj, 'Su')
  if checkSpecific(obj, specificObjs)
    robj = ensureObjRecord(record, obj)
    table.insert(robj.route, "#{name}[ln:#{info.linedefined}@file:#{info.short_src}")
  return unless getVisited(obj, record) == 0
  for i = 1, info.nups
    upname, upvalue = debug.getupvalue(obj, i)
    scanObjects("#{name}.[up:#{type(upvalue)}:#{upname}", upvalue, record, findall, specificObjs) unless nottable(upvalue) and notfunction(upvalue) and notthread(upvalue) and notuserdata(upvalue)
scanThread = (name, obj, record, _, specificObjs) ->
  return unless checkSpecific(obj, specificObjs)
  robj = ensureObjRecord(record, obj)
  table.insert(robj.route, name)
scanUserdata = (name, obj, record, findall, specificObjs) ->
  if checkSpecific(obj, specificObjs)
    robj = ensureObjRecord(record, obj)
    table.insert(robj.route, name)
  return unless getVisited(obj, record) == 0
  mt = getmetatable(obj)
  scanObjects(name .. '.[mt]', mt, record, findall, specificObjs) unless nottable(mt)
scanString = (name, obj, record, _, specificObjs) ->
  return unless checkSpecific(obj, specificObjs)
  robj = ensureObjRecord(record, obj)
  table.insert(robj.route, name .. '[string]')
mapCollect = {
  string: scanString
  table: scanTable
  function: scanFunction
  thread: scanThread
  userdata: scanUserdata
}
writeNewline = (file) -> file\write('\n')
output2stdout = (record) ->
  for k1, v1 in pairs(record.details)
    logd "#{_TYPE_PREFIX_}----------------- #{k1} -----------------"
    for k2, v2 in pairs(v1)
      logd "#{k2}#{_OBJ_SPLIT_}#{v2.count}"
      for v3 in *v2.route
        logd(_ROUTE_PREFIX_, v3)
output2file = (outfile, record) ->
  outfile = "MEM-DUMP #{os.date('%Y-%m-%d-%H%M%S', os.time())}" unless isstring(outfile)
  file = io.open(outfile, 'w')
  return unless notnil(file)
  for k1, v1 in pairs(record.details)
    file\write "#{_TYPE_PREFIX_}----------------- #{k1} -----------------"
    writeNewline(file)
    for k2, v2 in pairs(v1)
      file\write "#{k2}#{_OBJ_SPLIT_}#{v2.count}"
      writeNewline(file)
      for v3 in *v2.route
        file\write(_ROUTE_PREFIX_, v3)
        writeNewline(file)
  file\close!
tileRecord = (record) ->
  rst = {}
  for _, v1 in pairs(record.details)
    for k2, v2 in pairs(v1)
      rst[k2] = v2
  rst
readRecordFromFile = (file) ->
  f = io.open(file, 'r')
  return unless notnil(f)
  record = {details: {}}
  local currtype, currobj
  tmpstr = ''
  while true
    line = f\read('l')
    break unless notnil(line)
    flag = true
    if string.startswith(line, _TYPE_PREFIX_)
      currtype = string.split(line, ' ')[2]
      record.details[currtype] = {}
    elseif string.startswith(line, _ROUTE_PREFIX_)
      table.insert(record.details[currtype][currobj].route, line\sub(7))
    else
      i, j = line\find(_OBJ_SPLIT_, 1, true)
      if isnil(i)
        tmpstr ..= '\n' .. line
        flag = false
      else
        currobj = line\sub(1, i-1)
        record.details[currtype][currobj] = {
          count: line\sub(j+1), route: {}
        }
    tmpstr = '' if flag
  record
snapshot = {
  dump: (rootname, root, findall, specificObjs) =>
    rootname = ENSURE.string(rootname, 'root')
    rootname = ENSURE.table(root, _G)
    findall = ENSURE.boolean(findall, false)
    record = createRefRecord!
    if notnil(specificObjs)
      t = {}
      for v in *specificObjs do t[v] = 1
      specificObjs = t
    scanObjects(rootname, root, record, findall, specificObjs)
    record
  dump2stdout: (...) => output2stdout(@dump(...))
  dump2file: (outfile, ...) => output2file(outfile, @dump(...))
  dumpG: (...) => @dump('_G', _G, ...)
  dumpG2stdout: (...) => output2stdout(@dumpG(...))
  dumpG2file = (outfile, ...) => output2file(outfile, @dumpG(...))
  dumpR: (...) @dump('registry', debug.getregistry!, ...)
  dumpR2stdout: (...) => output2stdout(@dumpR(...))
  dumpR2file: (outfile, ...) => output2file(outfile, @dumpR(...))
  compare: (r1, r2) =>
    rst = {details: {}}
    for k1, v1 in pairs(v2.details)
      tmp1 = r1.details[k1]
      for k2, v2 in pairs(v1)
        continue unless notnil(tmp1) and notnil(tmp1[k2])
        rst.details[k1] = rst.details[k1] or {r1[k1]}
        rst.details[k1][k2] = v2
    rst
  compare2stdout: (...) => output2stdout(@compare(...))
  compare2file = (outfile, ...) => output2file(outfile, @compare(...))
  compareByFile: (file1, file2) =>
    r1 = readRecordFromFile(file1)
    r2 = readRecordFromFile(file2)
    @compare(r1, r2)
  compare2stdoutByFile: (...) => output2stdout(@compareByFile(...))
  compare2fileByFile: (outfile, ...) => output2file(outfile, @compareByFile(...))
}
---------------------------------------------- snapshot ----------------------------------------------

memory = {
  setlog: (fd, fe) ->
    logd = fd unless notfunction(fd)
    loge = fe unless notfunction(fe)
  monitor: monitor
  snapshot: snapshot
}
memory