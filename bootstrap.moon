require 'libs.version'
require 'libs.import'

include 'libs.type'
include 'libs.ensure'
include 'libs.function'
include 'libs.string'
include 'libs.table'
include 'libs.math'
include 'libs.class'

setmetatable(_G, {
  __index: (_, k) -> error "attempt to index a unexist global: [ #{k} ]. #{debug.traceback('', 2)}"
  __newindex: (_, k, v) -> error "attempt to write a unexist global: [ #{k} ]=[ #{v} ]. #{debug.traceback('', 2)}"
})