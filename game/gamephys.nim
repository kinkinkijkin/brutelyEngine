import gamedata,glm,with

var defgravity* = vec3f(0.0, -40.0, 0.0)

type
  Physical* = object of Collider
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
method updatePos(this: var Physical) =
  with this:
    if not run: return
    this.pos += rawspeed
method updateRot(this: var Physical) =
  with this:
    if not run: return
    this.rot = this.rot + rawrot
method setupPhysical(this: var Physical) =
  with this:
    gravity = defgravity
    simpmult = 1.0
    rimpmult = 1.0
    run = true
method basicPhysics*(this: var Physical) =
  this.integ()
  this.updateRot()
  this.updatePos()
  #this is an extremely basic physics method. you probably want something more complex.
