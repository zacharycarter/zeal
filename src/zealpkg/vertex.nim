import fpmath, bgfxdotnim

type
  BlendMode* {.size: sizeof(int32).} = enum
    bmNoBlend = 0,
    bmBlur

  MaterialIndex16 = object
    when cpuEndian == littleEndian:
      lo, hi: int16
    else:
      hi, lo: int16

  AdjacentMaterialIndex {.union.} = object
    idx*: int32
    idx16*: MaterialIndex16


  Vertex* = object
    pos*: Vec3
    uv*: Vec2
    normal*: Vec3
    materialIdx*: float32
    # jointIndices*: array[6, int]
    # weights*: array[6, float32]
    blendMode*: float32
    adjacentMatIndices*: array[4, AdjacentMaterialIndex]

  ColoredVert* = object
    pos*: Vec3
    color*: Vec4

  TexturedVert* = object
    pos*: Vec3
    uv*: Vec2
