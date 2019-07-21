import fpmath

type
  Range = object
    begin, `end`: float32

  Obb* = object
    center: Vec3
    axes: array[3, Vec3]
    halfLenghts: array[3, float32]
    corners: array[8, Vec3]

  AABB* = object
    xMin*, xMax*: float32
    yMin*, yMax*: float32
    zMin*, zMax*: float32

  Frustum* = object
    near, far: Plane
    top, bot: Plane
    left, right: Plane
    ntl, ntr, nbl, nbr: Vec3
    ftl, ftr, fbl, fbr: Vec3

proc rangesOverlap(a, b: Range): bool =
  if b.begin >= a.begin and b.begin <= a.`end`:
    return true
  
  if b.`end` >= a.begin and b.`end` <= a.`end`:
    return true
  
  if a.begin >= b.begin and a.begin <= b.`end`:
    return true
  
  if a.`end` >= b.begin and a.`end` <= b.`end`:
    return true

proc separatingAxisExists(axis: Vec3, frustum: Frustum, cuboidCorners: array[8, Vec3]): bool =
  var 
    frustRange, cuboidRange: Range
    frustAxisDots: array[8, float32]
    cuboidAxisDots: array[8, float32]
  
  let frustPoints = [
    frustum.ntl, frustum.ntr, frustum.nbl, frustum.nbr,
    frustum.ftl, frustum.ftr, frustum.fbl, frustum.fbr
  ]

  for i in 0 ..< 8:
    frustAxisDots[i] = vec3Dot(frustPoints[i], axis)
  
  for i in 0 ..< 8:
    cuboidAxisDots[i] = vec3Dot(cuboidCorners[i], axis)
  
  frustRange = Range(begin: min(frustAxisDots), `end`: max(frustAxisDots))
  cuboidRange = Range(begin: min(cuboidAxisDots), `end`: max(cuboidAxisDots))
  
  result = not rangesOverlap(frustRange, cuboidRange)

proc frustumAABBIntersectionExact*(frustum: Frustum, aabb: AABB): bool =
  let 
    aabbAxes = [
      [1.0'f32, 0.0, 0.0],
      [0.0'f32, 1.0, 0.0],
      [0.0'f32, 0.0, 1.0]
    ]

    aabbCorners = [
      [aabb.xMin, aabb.yMin, aabb.zMin],
      [aabb.xMin, aabb.yMin, aabb.zMax],
      [aabb.xMin, aabb.yMax, aabb.zMin],
      [aabb.xMin, aabb.yMax, aabb.zMax],
      [aabb.xMax, aabb.yMin, aabb.zMin],
      [aabb.xMax, aabb.yMin, aabb.zMax],
      [aabb.xMax, aabb.yMax, aabb.zMin],
      [aabb.xMax, aabb.yMax, aabb.zMax]
    ]
    
  for i in 0 ..< len(aabbAxes):
    if separatingAxisExists(aabbAxes[i], frustum, aabbCorners):
      return false
  
  let frustAxes = [
    frustum.near.normal,
    frustum.far.normal,
    frustum.top.normal,
    frustum.bot.normal,
    frustum.left.normal,
    frustum.right.normal
  ]

  for i in 0 ..< len(frustAxes):
    if separatingAxisExists(frustAxes[i], frustum, aabbCorners):
      return false
  
  var frustEdges: array[6, Vec3]
  vec3Sub(frustEdges[0], frustum.ntr, frustum.ntl)
  vec3Sub(frustEdges[1], frustum.ntl, frustum.nbl)
  vec3Sub(frustEdges[2], frustum.ftl, frustum.ntl)
  vec3Sub(frustEdges[3], frustum.ftr, frustum.ntr)
  vec3Sub(frustEdges[4], frustum.fbr, frustum.nbr)
  vec3Sub(frustEdges[5], frustum.fbl, frustum.nbl)

  var edgeCrossProducts: array[len(aabbAxes) * len(frustEdges), Vec3]

  for i in 0 ..< len(aabbAxes):
    for j in 0 ..< len(frustEdges):
      vec3Cross(edgeCrossProducts[i * len(frustEdges) + j], aabbAxes[i], frustEdges[j])
      vec3Norm(edgeCrossProducts[i * len(frustEdges) + j], edgeCrossProducts[i * len(frustEdges) + j])
  
  for i in 0 ..< len(edgeCrossProducts):
    if separatingAxisExists(edgeCrossProducts[i], frustum, aabbCorners):
      return false

  return true

proc makeFrustum*(pos, up, front: Vec3, aspectRatio, fovRad, nearDist, farDist: float32, frustum: var Frustum) =
  let 
    nearHeight = 2 * tan(fovRad/2.0'f32) * nearDist
    nearWidth = nearHeight * aspectRatio

    farHeight = 2 * tan(fovRad/2.0'f32) * farDist
    farWidth = farHeight * aspectRatio

  var
    tmp: Vec3
    nc = pos
    fc = pos
    camRight: Vec3
  
  vec3Cross(camRight, up, front)
  vec3Norm(camRight, camRight)
  
  vec3Mul(tmp, front, nearDist)
  vec3Add(nc, nc, tmp)

  vec3Mul(tmp, front, farDist)
  vec3Add(fc, nc, tmp)

  var 
    upHalfHfar = vec3Mul(up, farHeight / 2.0'f32)
    rightHalfWfar = vec3Mul(camRight, farWidth / 2.0'f32)
    upHalfHnear = vec3Mul(up, nearHeight / 2.0'f32)
    rightHalfWnear = vec3Mul(camRight, nearWidth / 2.0'f32)

  # Far Top Left corner
  vec3Add(tmp, fc, upHalfHfar)
  vec3Sub(frustum.ftl, tmp, rightHalfWfar)

  # Far Top Right corner
  vec3Add(tmp, fc, upHalfHfar)
  vec3Add(frustum.ftr, tmp, rightHalfWfar)

  # Far Bottom Left corner
  vec3Sub(tmp, fc, upHalfHfar)
  vec3Sub(frustum.fbl, tmp, rightHalfWfar)

  # Far Bottom Right corner
  vec3Sub(tmp, fc, upHalfHfar)
  vec3Add(frustum.fbr, tmp, rightHalfWfar)

  # Near Top Left corner
  vec3Add(tmp, nc, upHalfHnear)
  vec3Sub(frustum.ntl, tmp, rightHalfWnear)

  # Near Top Right corner
  vec3Add(tmp, nc, upHalfHnear)
  vec3Add(frustum.ntr, tmp, rightHalfWnear)

  # Near Bottom Left corner
  vec3Sub(tmp, nc, upHalfHnear)
  vec3Sub(frustum.nbl, tmp, rightHalfWnear)

  # Near Bottom Right corner
  vec3Sub(tmp, nc, upHalfHnear)
  vec3Add(frustum.nbr, tmp, rightHalfWnear)

  # Near plane
  frustum.near.point = nc
  frustum.near.normal = front

  # Far plane
  let negativeDir = vec3Mul(front, -1.0'f32)

  frustum.far.point = fc
  frustum.far.normal = negativeDir

  # Right plane
  var pNearToRightEdge: Vec3
  vec3Mul(tmp, camRight, nearWidth / 2.0'f32)
  vec3Add(tmp, nc, tmp)
  vec3Sub(pNearToRightEdge, tmp, pos)
  vec3Norm(pNearToRightEdge, pNearToRightEdge)
  
  frustum.right.point = pos
  vec3Cross(frustum.right.normal, pNearToRightEdge, up)
  
  # Left plane
  var pNearToLeftEdge: Vec3
  vec3Mul(tmp, camRight, nearWidth / 2.0'f32)
  vec3Sub(tmp, nc, tmp)
  vec3Sub(pNearToLeftEdge, tmp, pos)
  vec3Norm(pNearToLeftEdge, pNearToLeftEdge)

  frustum.left.point = pos
  vec3Cross(frustum.left.normal, up, pNearToLeftEdge)
  
  # Top plane
  var pNearToTopEdge: Vec3
  vec3Mul(tmp, up, nearHeight / 2.0'f32)
  vec3Add(tmp, nc, tmp)
  vec3Sub(pNearToTopEdge, tmp, pos)
  vec3Norm(pNearToTopEdge, pNearToTopEdge)

  frustum.top.point = pos
  vec3Cross(frustum.top.normal, camRight, pNearToTopEdge)

  # Bottom plane
  var pNearToBottomEdge: Vec3
  vec3Mul(tmp, up, nearHeight / 2.0'f32)
  vec3Sub(tmp, nc, tmp)
  vec3Sub(pNearToBottomEdge, tmp, pos)
  vec3Norm(pNearToBottomEdge, pNearToBottomEdge)

  frustum.bot.point = pos
  vec3Cross(frustum.bot.normal, pNearToBottomEdge, camRight)