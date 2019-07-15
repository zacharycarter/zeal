import fpmath, collision

const camZNearDist = 0.1'f32
const camFovRad = PI/4.0f

type
  BoundingBox* = object
    x, z: float32
    w, h: float32
  
  Camera* = object
    speed: float32
    sensitivity: float32
    
    pos: Vec3
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
         camera.pos[2] >= camera.bounds.z and (camera.pos[2] <= camera.bounds.z + camera.bounds.h)

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
  let aspectRatio = 16.0'f32 / 9.0'f32

  makeFrustum(camera.pos, camera.up, camera.front, aspectRatio, camFovRad, camZNearDist, 1000, frustum)