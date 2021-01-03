import gamedata,glm

type
  Physical = object of Collider
    rawspeed*, impulse*: Vec3[float64]
    mimpmod*, rimpmod*: float64
    rawrot*, rotimpulse*: Mat3x3[float64]
    run*, resetraw*: bool
