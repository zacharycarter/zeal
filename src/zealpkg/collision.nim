import fpmath

type
  Obb* = object
    center: Vec3
    axes: array[3, Vec3]
    halfLenghts: array[3, float32]
    corners: array[8, Vec3]

  Frustum* = object
    near, far: Plane
    top, bot: Plane
    left, right: Plane
    ntl, ntr, nbl, nbr: Vec3
    ftl, ftr, fbl, fbr: Vec3


proc makeFrustum*(pos, up, front: Vec3, aspectRatio, fovRad, nearDist, farDist: float32, frustum: var Frustum) =
  let 
    nearHeight = 2 * tan(fovRad/2.0'f32) * nearDist
    nearWidth = nearHeight * aspectRatio

    farHeight = 2 * tan(fovRad/2.0'f32) * nearDist
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
    rightHalfWfar = vec3Mul(camRight, farHeight / 2.0'f32)
    upHalfHnear = vec3Mul(camRight, nearHeight / 2.0'f32)
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
  frustum.far.point = fc
  vec3Mul(frustum.far.normal, front, -1.0'f32)

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
  vec3Cross(frustum.bot.normal, pNearToTopEdge, camRight)