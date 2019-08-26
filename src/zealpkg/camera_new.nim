import fpmath

type
  Camera = object
    eye: Vec3
    at: Vec3
    up: Vec3
    horizontalAngle: float32
    verticleAngle: float32

var camera: Camera

proc reset() =
  camera.eye = [0.0'f32, 0.0, -35.0]
  camera.at = [0.0'f32, 0.0, -1.0]
  camera.up = [0.0'f32, 1.0, 0.0]
  camera.horizontalAngle = 0.01'f32
  camera.verticleAngle = 0.0'f32

proc setCameraPosition*(pos: Vec3) =
  camera.eye = pos

proc setCameraVerticalAngle*(angle: float32) =
  camera.verticleAngle = angle

proc getCameraViewMtx*(mtx: var Mat4) =
  mtxLookAt(mtx, camera.eye, camera.at, camera.up)

proc createCamera*() =
  reset()