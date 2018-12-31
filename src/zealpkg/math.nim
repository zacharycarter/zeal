type Mat4* = array[16, float32]

proc mtxIdentity*(): Mat4 {.inline.} =
  result = [
      1.0'f32, 0.0'f32, 0.0'f32, 0.0'f32,
      0.0'f32, 1.0'f32, 0.0'f32, 0.0'f32,
      0.0'f32, 0.0'f32, 1.0'f32, 0.0'f32,
      0.0'f32, 0.0'f32, 0.0'f32, 1.0'f32
    ]

type Vec2* = array[2, float32]
type Vec3* = array[3, float32]
type Vec4* = array[4, float32]

proc vec2*(a: float32): Vec2 =
  result = [a, a]

proc vec4*(a, b: Vec2): Vec4 =
  result = [
    a[0],
    a[1],
    b[0],
    b[1]
  ]

proc `/`*(a, b: Vec2): Vec2 =
  result = [
    a[0] / b[0],
    a[1] / b[1]
  ]