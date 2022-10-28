KEY_DEFAULT = '__default'
cache = {}
export include = (module, category, notcache) ->
  category = category or KEY_DEFAULT
  cache[category] = cache[category] or {}
  rst = cache[category][module]
  if rst == nil
    module = string.format('%s.lua', module\gsub('%.', '/'))
    rst = dofile(module)
    cache[category][module] = rst unless notcache
  rst
export clearinc = (category) ->
  category = category or KEY_DEFAULT
  cache[category] = {}