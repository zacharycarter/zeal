import fpmath, bgfxdotnim

type
  BlendMode* {.size: sizeof(int16).} = enum
    bmNoBlend,
    bmBlur

  Vertex* = object
    pos*: Vec3
    uv*: Vec2
    normal*: Vec3
    materialIdx*: int16
    jointIndices*: array[6, int]
    weights*: array[6, float32]
    blendMode*: BlendMode
    adjacentMatIndices*: array[4, int16]
  
  ColoredVert* = object
    pos*: Vec3
    color*: Vec4
  
  TexturedVert* = object
    pos*: Vec3
    uv*: Vec2