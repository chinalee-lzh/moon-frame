import reverse, byte, char, find, upper, gmatch, rep, packsize, lower, format, dump, unpack, pack, sub, match, len, gsub from string
import concat, insert from table

raw_startswith = (str, prefix) -> find(str, prefix, 1, true) == 1
raw_endswith = (str, suffix) ->
  return false unless len(str) >= len(suffix)
  return find(str, suffix, len(str)-len(suffix)+1, true) and true or false
test_affixes = (str, affixes, fn) ->
  if isstring(affixes)
    fn(str, test_affixes)
  elseif istable(affixes)
    for affix in *affixes do return true if fn(str, affix)
    false
  else
    false

string.empty = (str) -> notstring(str) or str == ''
string.at = (str, idx) ->
  return unless isnumber(idx)
  idx = #str+idx+1 if idx < 0
  sub(str, idx, idx)
string.replace = (str, idx, s) ->
  return str unless isnumber(idx) and isstring(s)
  sz = len(str)
  idx = sz+idx+1 if idx < 0
  return str unless idx >= 1 and idx <= sz
  "#{sub(str, 1, idx-1}#{s}#{sub(str, idx+1}"
string.join = (...) -> concat({...}, '')
string.concat = (s1, s2, sep) -> return "#{s1}#{sep}#{s2}" if isstring(s1) and isstring(s2) and isstring(sep)
string.split = (str, sep) ->
  return unless isstring(str) and not string.empty(sep)
  tbl = {}
  for field, s in gmatch(str, '([^' .. sep .. ']*)(' .. sep .. '?)')
    insert(tbl, field)
    break if s == ''
  tbl
string.startswith = (str, prefix) -> test_affixes(str, prefix, raw_startswith)
string.endswith = (str, suffix) -> test_affixes(str, suffix, raw_endswith)
string.ensurestart = (str, prefix) -> if string.startswith(str, prefix) then str else prefix .. str
string.ensureend = (str, suffix) -> if string.endswith(str, suffix) then str else str .. suffix
string.removestart = (str, prefix) -> if string.startswith(str, prefix) then sub(str, len(prefix)+1) else str
string.removeend = (str, suffix) -> if string.endswith(str, suffix) then sub(str, 1, len(str)-len(suffix)) else str
string.trim = (str) -> match(str, '^%s*(.-)%s*$')
string.utf8len = (str) ->
  sz = len(str)
  left, cnt = sz, 0
  arr = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc }
  while left > 0
    tmp = byte(str, -left)
    i = #arr
    while arr[i]
      if tmp >= arr[i]
        left -= 1
        break
      i -= 1
    cnt += 1
  cnt