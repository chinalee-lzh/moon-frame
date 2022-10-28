util = include 'ecs.util'
class World
  new: =>
    @entities = {}
    @systems = {}
  addEntity: (entity) =>
    return unless util.isentity(entity)
    idx = #@entities+1
    @entities[idx] = entity
    entity\setWorldIdx(idx)
  delEntity: (entity) =>
    return unless util.isentity(entity)
    idx = entity\getWorldIdx!
    sz = #@entities
    @entities[idx] = @entities[sz]
    @entities[sz] = nil
  update: (delta) =>
    for sys in *@systems
      filter = sys\getFilter!
      for entity in *@entities
        sys\process(entity, delta) if filter(entity)