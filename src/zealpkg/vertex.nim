import fpmath, bgfxdotnim

type
  Vertex* = object
    pos*: Vec3
    uv*: Vec2
    normal*: Vec3
    materialIdx*: int
    jointIndices*: array[6, int]
    weights*: array[6, float32]
    blendMode*: int
    adjacentMatIndices*: array[4, int]
  
  ColoredVert* = object
    pos*: Vec3
    color*: Vec4
  
  TexturedVert* = object
    pos*: Vec3
    uv*: Vec2