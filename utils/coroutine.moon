import create, resume, yield, status, running, wrap from coroutine
import pack, unpack, insert from table

call = (fn, ...) -> resume(create(fn), ...)
wrap = (fn) -> (...) -> call(fn, ...)
a2s = (fasync, cbpos) ->
  (...) ->
    co = running!
    error "this function must be running in coroutine" unless notnil(co)
    rst, waiting = nil, false
    callback = (...) ->
      if waiting
        resume(co, ...)
      else
        rst = {...}
    params = pack ...
    cbpos = ENSURE.number(cbpos, #params+1)
    insert(params, cbpos, callback)
    fasync(unpack(params))
    if isni(rst)
      waiting = true
      rst = {yield!}
    unpack(rst)

{
  :call
  :wrap
  :a2s
}