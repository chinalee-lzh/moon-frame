List = (include 'utils.list').Pool

KEY_ENTITY = '__ECS_KEY_ENTITY__'
KEY_SYS = '__ECS_KEY_SYS__'
KEY_COM = '__ECS_KEY_COM__'

isentity = (obj) -> obj.__keyecs__ == KEY_ENTITY
issys = (obj) -> obj.__keyecs__ == KEY_SYS
iscom = (obj) -> obj.__keyecs__ == KEY_COM
createFilter = (prefix, seperator, ...) ->
  n = select('#', ...)
  l = List.get!
  for i = 1, n
    com = select(i, ...)
    l\add "entity:hascom(#{com})"
  script = "return function(entity) return #{prefix}(#{l\concat(seperator)})"
  List.free(l)
  fn = loadstring(script)
  fn!

{
  :KEY_ENTITY
  :KEY_SYS
  :KEY_COM

  :isentity
  :issys
  :iscom
  notentity: (...) -> not isentity(...)
  notsys: (...) -> not issys(...)
  notcom: (...) -> not iscom(...)

  requireAll: (...) -> createFilter('', 'and', ...)
  requireAny: (...) -> createFilter('', 'or', ...)
  rejectAll: (...) -> createFilter('not', 'or', ...)
  rejectAny: (...) -> createFilter('not', 'and', ...)
}