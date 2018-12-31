import  math

type
  Plane* = object
    normal: Vec3
    distance: float

  Plane6* = object
    right, left, up, down, near, far: Plane

  Point8* = object
    a, b, c, d, e, f, g, h: Vec3