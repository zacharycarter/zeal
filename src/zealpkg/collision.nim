import fpmath

type
  Obb* = object
    center: Vec3
    axes: array[3, Vec3]
    halfLenghts: array[3, float32]
    corners: array[8, Vec3]