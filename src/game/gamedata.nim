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
method nearest*(this: Collision, pos: Vec3f): Vec3f =
  #varies between collisions.
  return vec3f(0)
method coll*(this: var Collision, thispos: Vec3f, that: var Collision, thatpos: Vec3f) =
  #varies between collisions.
  return
method run*(this: var Collision) =
  this.colliding = false

type
  CollisionRect* = object of Collision
    size*: Vec3f
method genCorners*(this: CollisionRect): array[8, Vec3f] =
  with this:
    result[0] = vec3f(size / 2)
    result[1] = vec3f(-size / 2)
    result[2] = vec3f(size.x / 2, size.y / 2, -size.z / 2)
    result[3] = vec3f(-size.x / 2, -size.y / 2, size.z / 2)
    result[4] = vec3f(size.x / 2, -size.y / 2, -size.z / 2)
    result[5] = vec3f(-size.x / 2, size.y / 2, size.z / 2)
    result[6] = vec3f(-size.x / 2, size.y / 2, -size.z / 2)
    result[7] = vec3f(size.x / 2, -size.y / 2, size.z / 2)
method nearest*(this: CollisionRect, pos: Vec3f, thatpos: Vec3f): Vec3f =
  var corners: array[8, Vec3f] = this.genCorners()
  var cornerdists: array[8, float]
  for i, corn in corners:
    cornerdists[i] = dist3D((corn + pos), thatpos)
  return corners[cornerdists.minIndex()]
#method coll*(this: var CollisionRect, thispos: Vec3f, that: var Collision, thatpos: Vec3f) =
  

type
  Extensible* = object of RootObj
    ext*: Extension
method receive*(this: var Extensible) =
   #extend methodology from here
   #same as the run method above. this is a sort of "test and apply" method.
   this.ext.run()
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
    collide*: CollisionMask
    activate*: CollisionMask
    kill*: CollisionMask
    collext*: Collision
method canCollide*(this:Collider, that:Collider): bool =
  for layer in 0..7:
    if this.collide[layer] and that.collide[layer]:
      return true
  return false
method canActivate*(this:Collider, that:Collider): bool =
  for layer in 0..7:
    if this.activate[layer] and that.activate[layer]:
      return true
  return false
method canKill*(this:Collider, that:Collider): bool =
  for layer in 0..7:
    if this.kill[layer] and that.kill[layer]:
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
