import create, resume, yield, status, running, wrap from coroutine
import pack, unpack from table

class Thread
  new: (fn) =>
    @fn = ENSURE.func(fn, gf_empty)
    @co = create(->
      while true
        rst = pack(yield!)
        @fn(unpack(rst))
    )
    @resume!
  init: (fn) => @fn = fn
  resume: (...) => resume(@co, ...)
  start: (...) @resume(...)
  status: => status(@co)
  isdead: => @status! == 'dead'

classpool(Thread)