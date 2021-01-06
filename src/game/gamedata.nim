import glm,with,gamemath,sequtils

type
  Extension* = object of RootObj
    active*: bool
method run*(this: var Extension) =
  #extend methodology from here
  #this is only here because every extension has to have this method, so default
  #to a dummy for extensions that don't use it
  return

type
  Collision* = object of Extension
    colliding*: bool
    scale*: float
    activedist*: float
    collrot: Mat3f
method nearest*(this: Collision, pos: Vec3f, thatpos: Vec3f): Vec3f =
  #varies between collisions.
  return vec3f(0)
method coll*(this: var Collision, thispos: Vec3f, that: var Collision, thatpos: Vec3f): bool =
  #varies between collisions.
  return false
method largestDist(this: Collision): float =
  return 0.0
method run*(this: var Collision) =
  this.colliding = false

type
  CollisionRect* = object of Collision
    size*: Vec3f
method genCorners*(this: CollisionRect): array[8, Vec3f] =
  with this:
    var size2: Vec3f = vec3f(size / 2)
    var size2r: Vec3f = -size
    result[0] = vec3f(size2)
    result[1] = vec3f(size2r)
    result[2] = vec3f(size2.x, size2.y, size2r.z)
    result[3] = vec3f(size2r.x, size2r.y, size2.z)
    result[4] = vec3f(size2.x, size2r.y, size2r.z)
    result[5] = vec3f(size2r.x, size2.y, size2.z)
    result[6] = vec3f(size2r.x, size2.y, size2r.z)
    result[7] = vec3f(size2.x, size2r.y, size2.z)
method nearest*(this: CollisionRect, pos: Vec3f, thatpos: Vec3f): Vec3f =
  var corners: array[8, Vec3f] = this.genCorners()
  var cornerdists: array[8, float]
  for i, corn in corners:
    cornerdists[i] = dist3D((corn + pos), thatpos)
  return corners[cornerdists.minIndex()]
method furthest*(this: CollisionRect, pos: Vec3f, thatpos: Vec3f): Vec3f =
  var corners: array[8, Vec3f] = this.genCorners()
  var cornerdists: array[8, float]
  for i, corn in corners:
    cornerdists[i] = dist3d((corn + pos), thatpos)
  return corners[cornerdists.maxIndex()]
method largestDist*(this: CollisionRect): float =
  return dist3D(this.size, vec3f(0))
method coll*(this: var CollisionRect, thispos: Vec3f, that: var Collision, thatpos: Vec3f):bool =
  var thatnear: Vec3f = that.nearest(thatpos, thispos).toLocal3D(thispos, this.collrot)
  if thatnear.x <= (this.size.x / 2) and thatnear.y <= (this.size.y / 2):
    if thatnear.x >= (-this.size.x / 2) and thatnear.y >= (-this.size.y / 2):
      return true
    else: return false
  else: return false

type
  Extensible* = object of RootObj
    ext*: Extension
method receive*(this: var Extensible) =
   #extend methodology from here
   #same as the run method above. this is a sort of "test and apply" method.
   if this.ext.active: this.ext.run()
   return

type
  ExtWithPass* = object of Extension
method passRun(this: var ExtWithPass, parent: var Extensible) =
  #this one is spicy
  return

type
  CollisionMask* = array[8, bool]
  PosTrackedObj* = object of Extensible
    objname*: string
    pos*: Vec3f
    rot*: Mat3f
    iphysical*: bool
    phys*: ExtWithPass
  Collider* = object of PosTrackedObj
    collides*: CollisionMask
    collidedby*: CollisionMask
    activates*: CollisionMask
    activatedby*: CollisionMask
    kills*: CollisionMask
    killedby*: CollisionMask
    collext*: Collision
method canCollide*(this:Collider, that:Collider): bool =
  for layer in 0..7:
    if this.collides[layer] and that.collidedby[layer]:
      return true
    elif this.collidedby[layer] and that.collides[layer]:
      return true
  return false
method canActivate*(this:Collider, that:Collider): bool =
  for layer in 0..7:
    if this.activates[layer] and that.activatedby[layer]:
      return true
  return false
method canBeActivated*(this:Collider, that:Collider): bool =
  for layer in 0..7:
    if this.activatedby[layer] and that.activates[layer]:
      return true
  return false
method canKill*(this:Collider, that:Collider): bool =
  for layer in 0..7:
    if this.kills[layer] and that.killedby[layer]:
      return true
  return false
method canBeKilled(this:Collider, that:Collider): bool =
  for layer in 0..7:
    if this.killedby[layer] and that.kills[layer]:
      return true
  return false
method collidedWith*(this: var Collider) =
  this.collext.colliding = true

type
  Simp* = object of Collider
    name: string
    alive*, grounded*, moving*, movable*, player*, invincible*: bool
    bar16*: seq[uint16]
method killable*(this:Simp): bool =
  return (this.alive and not this.invincible)
method walking*(this:Simp): bool =
  return (this.grounded and this.moving)
