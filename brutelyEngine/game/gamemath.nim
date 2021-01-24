import glm,math

proc dist3D*(v1, v2: Vec3f): float =
  var step1: Vec3f = vec3f((v2.x - v1.x), (v2.y - v1.y), (v2.z - v1.z))
  var step2: Vec3f = vec3f(pow(step1.x, 2), pow(step1.y, 2), pow(step1.z, 2))
  var step3: float = step2.x + step2.y + step2.z
  return sqrt(step3)
proc dist2D*(v1, v2: Vec2f): float =
  var step1: Vec2f = vec2f((v2.x - v1.x), (v2.y - v1.y))
  var step2: Vec2f = vec2f(pow(step1.x, 2), pow(step1.y, 2))
  var step3: float = step2.x + step2.y
  return sqrt(step3)

proc normDirec3D*(v1, v2: Vec3f): Vec3f =
  return (v2 / dist3D(v2, vec3f(0))) -  (v1 / dist3D(v1, vec3f(0)))

proc toLocal3D*(vecin, grel: Vec3f, rot: Mat3f): Vec3f =
  return (vecin - grel) * (rot * -1)
