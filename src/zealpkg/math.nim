type Mat4* = array[16, float32]

proc mtxIdentity*(): Mat4 {.inline.} =
  result = [
      1.0'f32, 0.0'f32, 0.0'f32, 0.0'f32,
      0.0'f32, 1.0'f32, 0.0'f32, 0.0'f32,
      0.0'f32, 0.0'f32, 1.0'f32, 0.0'f32,
      0.0'f32, 0.0'f32, 0.0'f32, 1.0'f32
    ]

type Vec2* = array[2, float32]

proc newVec2*(x, y: float32): Vec2 =
  result = [x, y]

type Vec4* = array[4, float32]