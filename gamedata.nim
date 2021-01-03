import sequtils,glm

type
  CollisionMask* = array[8, bool]
  PosTrackedObj* = object of RootObj
    objname*: string
    pos*: Vec3[float32]
    rot*: Mat3x3[float32]
  Collider* = object of PosTrackedObj
    collide*: CollisionMask
    activate*: CollisionMask
    kill*: CollisionMask
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
    extents*: tuple[a, b: Vec3[float32]]
