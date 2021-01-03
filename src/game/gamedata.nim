import glm

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
method coll*(this: var Collision, thisposition: Vec3f, that:Collision, thatposition: Vec3f) =
  #varies between collisions.
  return
method run*(this: var Collision) =
  this.colliding = false

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

type
  CollidableRect* = object of Collider
    extents*: tuple[a, b: Vec3f]
