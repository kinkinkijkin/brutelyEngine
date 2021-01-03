import gamedata,glm,with

var defgravity* = vec3f(0.0, -32.0, 0.0)

type
  Physical* = object of ExtWithPass
    rawspeed*, simpulse*, gravity*: Vec3f
    rawrot*, rimpulse*: Mat3f
    simpmult*, rimpmult*: float
    run*, resetraw*: bool
method integ(this: var Physical) =
  with this:
    if not run: return
    if not resetraw:
      rawspeed += (simpulse * simpmult) + gravity
      rawrot = rawrot + (rimpulse * rimpmult)
    else:
      rawspeed = vec3f(0)
      rawrot = mat3f(0)
      resetraw = false
    simpulse = vec3f(0)
    rimpulse = mat3f(0)
method updatePos(this: var Physical, that: var Vec3f) =
  with this:
    if not run: return
    that += rawspeed
method updateRot(this: var Physical, that: var Mat3f) =
  with this:
    if not run: return
    that = that + rawrot
method setupPhysical*(this: var Physical) =
  with this:
    gravity = defgravity
    simpmult = 1.0
    rimpmult = 1.0
    run = true
method passRun*(this: var Physical, parent: var PosTrackedObj) =
  this.integ()
  this.updatePos(parent.pos)
  this.updateRot(parent.rot)
