util = include 'unity.util'
vector3 = include('unity.vector3').Pool

class Go
  new: (csobj) => @init(csobj)
  init: (csobj) =>
    @csobj = csobj
    @trans = csobj.transform
  find: (path) =>
    return @ if string.empty(path)
    path = path\trim!\gsub('%.', '/')
    rst = @trans\Find(path)
    return Go.Pool.get(rst) unless util.isNull(rst)
  getactive: => @csobj.activeSelf
  setactive: (flag) =>
    flag = ENSURE.boolean(flag, true)
    @csobj\SetActive(flag)
  getpos_xyz: =>
    pos = @trans.position
    pos.x, pos.y, pos.z
  getpos: => vector3.get!\copy(@trans.position)
  setpos_xyz: (x, y, z) => @trans\SetPosition(x, y, z)
  setpos: (pos) => @setpos_xyz(pos\unpack!)
  getlpos_xyz: =>
    lpos = @trans.localPosition
    lpos.x, lpos.y, lpos.z
  getlpos: => vector3.get!\copy(@trans.localPosition)
  setlpos_xyz: (x, y, z) => @trans\SetLocalPosition(x, y, z)
  setlpos: (pos) => @setlpos_xyz(pos\unpack!)
  getscale_xyz: =>
    scale = @trans.localScale
    scale.x, scale.y, scale.z
  getscale: => vector3.get!\copy(@trans.localScale)
  setscale_xyz: (x, y, z) => @trans\SetScale(x, y, z)
  setscale: (scale) => @setscale_xyz(scale\unpack!)

classpool(Go)