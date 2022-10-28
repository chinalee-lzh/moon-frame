util = include 'ecs.util'
class Entity
  new: (...) =>
    @__keyecs__ = KEY_ENTITY
    @init(...)
  init: (...) =>
    @coms = {}
    @setWorldIdx(-1)
  hascom: (category) => notnil(category) and notnil(@coms[category])
  getcom: (category) => @coms[category] unless isnil(category)
  addcom: (category, com) =>
    return unless notnil(category) and notnil(com)
    @coms[category] = com
    @
  delcom: (category) =>
    com = @getcom(category)
    return unless notnil(com)
    @coms[category] = nil
    com
property(Entity, 'worldIdx')
classpool(Entity)