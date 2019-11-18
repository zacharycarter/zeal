import event, fpmath, collision, render, sdl2 as sdl

const camZNearDist = 0.1'f32
const camFovRad = PI/4.0'f32

type
  BoundingBox* = object
    x, z: float32
    w, h: float32

  Camera* = object
    speed: float32
    sensitivity: float32

    pos*: Vec3
    front: Vec3
    up: Vec3

    pitch: float32
    yaw: float32

    prevFrameTs: uint32

    # When 'bounded' is true, the camera position must
    # always be within the 'bounds' box */
    bounded: bool
    bounds: BoundingBox

proc posInBounds(camera: Camera): bool =
  return camera.pos[0] <= camera.bounds.x and camera.pos[0] >= (camera.bounds.x - camera.bounds.w) and
         camera.pos[2] >= camera.bounds.z and (camera.pos[2] <=
             camera.bounds.z + camera.bounds.h)

proc getYaw*(camera: Camera): float32 =
  result = camera.yaw

proc setSpeed*(camera: var Camera, speed: float32) =
  camera.speed = speed

proc setSensitivity*(camera: var Camera, sensitivity: float32) =
  camera.sensitivity = sensitivity

proc setPitchAndYaw*(camera: var Camera, pitch, yaw: float32) =
  camera.pitch = pitch
  camera.yaw = yaw

  var front: Vec3
  front[0] = cos(degToRad(camera.yaw)) * cos(degToRad(camera.pitch))
  front[1] = sin(degToRad(camera.pitch))
  front[2] = sin(degToRad(camera.yaw)) * cos(degToRad(camera.pitch)) * -1
  vec3Norm(camera.front, front)

  # Find a vector that is orthogonal to 'front' in the XZ plane
  let xz = [camera.front[2], 0.0'f32, -camera.front[0]]
  vec3Cross(camera.up, camera.front, xz)
  vec3Norm(camera.up, camera.up)

proc setPosition*(camera: var Camera, position: Vec3) =
  camera.pos = position

  assert(not camera.bounded or posInBounds(camera))

proc makeFrustum*(camera: Camera, frustum: var Frustum) =
  let aspectRatio = 1280.0'f32 / 720.0'f32

  makeFrustum(camera.pos, camera.up, camera.front, aspectRatio, camFovRad,
      camZNearDist, 1000, frustum)

proc tickFinishPerspective*(cam: var Camera) =
  var
    view: Mat4
    target: Vec3

  vec3Add(target, cam.pos, cam.front)
  mtxLookAt(view, cam.pos, target, cam.up)
  setViewTransform(view)

  cam.prevFrameTs = sdl.getTicks()


proc moveWithinBounds(cam: var Camera) =
  cam.pos[0] = min(cam.pos[0], cam.bounds.x)
  cam.pos[0] = max(cam.pos[0], cam.bounds.x - cam.bounds.w)

  cam.pos[2] = max(cam.pos[2], cam.bounds.z)
  cam.pos[2] = min(cam.pos[2], cam.bounds.z + cam.bounds.h)

proc moveDirectionTick*(cam: var Camera, dir: var Vec3) =
  var
    tDelta: uint32
    vDelta: Vec3

  if cam.prevFrameTs == 0:
    cam.prevFrameTs = sdl.getTicks()

  let mag = sqrt(pow(dir[0], 2) + pow(dir[1], 2) + pow(dir[2], 2))
  if mag == 0.0:
    return

  vec3Norm(dir, dir)

  let curr = sdl.getTicks()
  tDelta = curr - cam.prevFrameTs

  vec3Mul(vDelta, dir, float32(tDelta) * cam.speed)
  vec3Add(cam.pos, cam.pos, vDelta)

  if cam.bounded: moveWithinBounds(cam)
  assert(not cam.bounded or posInBounds(cam))
