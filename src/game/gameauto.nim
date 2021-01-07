import gamemath,gamedata,times

var pacer = cpuTime()

var globj*: seq[Extensible] = @[]

proc takePace*(): float =
  var p1 = cpuTime()
  var p2 = pacer - cpuTime()
  pacer = p1
  return p2

proc submitGameObj*(obj: Extensible): uint =
  globj.add(obj)
  return globj.high.uint

proc autoRun*() =
  for i in 0..globj.high:
    globj[i].runExts()
    globj[i].receive()
    if globj[i] of PosTrackedObj:
      if globj[i] of Collider:
        var col: bool = false
        block collisiontest:
          for x in 0..globj.high:
            if (not x == i) and (globj[x] of Collider):
              col = (globj[i].Collider).maybeCollide(globj[x].Collider)
              if col: break collisiontest
      (globj[i].Collider).passRunExts()

