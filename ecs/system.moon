util = include 'ecs.util'
class System
  new: (...) =>
    @__keyecs__ = util.KEY_SYS
    @init(...)
  init: (category) => @category = category
  getFilter: gf_false
classpool(System)