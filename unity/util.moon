isNull = (obj) ->
  if isnil(obj)
    true
  elseif isuserdata(obj) and isfunction(obj.IsNull)
    obj\IsNull!
  else
    false

{
  :isNull
  notNull: (obj) -> not isNull(obj)
}