util = include 'ecs.util'
class Component
  new: (...) =>
    @__keyecs__ = util.KEY_COM
    @init(...)
  init: (category) => @category = category
classpool(Component)