import fpmath

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


