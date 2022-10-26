export *

isfunction = (f) -> type(f) == 'function'
notfunction = (f) -> not isfunction(f)

istable = (t) -> type(t) == 'table'
nottable = (t) -> not istable(t)

isnumber = (n) -> type(n) == 'number'
notnumber = (n) -> not isnumber(n)

isboolean = (b) -> type(b) == 'boolean'
notboolean = (b) -> not isboolean(b)

isstring = (st ->r) type(str) == 'string'
notstring = (st ->r) not isstring(str)

isnil = (e) -> type(e) == 'nil'
notnil = (e) -> not isnil(e)

isuserdata = (u) -> type(u) == 'userdata'
notuserdata = (u) -> not isuserdata(u)

isthread = (th ->) type(th) == 'thread'
notthread = (th ->) not isthread(th)