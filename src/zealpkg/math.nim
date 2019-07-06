type 
  Handness = enum
    hLeft,
    hRight
  
  NearFar = enum
    nfDefault,
    nfReverse
  
  Vec3 = object
    x: float32
    y: float32
    z: float32
  
  Plane = object
    normal: Vec3
    dist: float32
  
  Quaternion = object
    x: float32
    y: float32
    z: float32
    w: float32


proc bitsToFloat(a: uint32): float32 {.inline.} =
  result = cast[float32](a)

proc floatToBits(a: float32): uint32 {.inline.} =
  result = cast[uint32](a)

const 
  kPi: float32 = 3.1415926535897932384626433832795'f32
  kPi2: float32 = 6.2831853071795864769252867665590'f32
  kInvPi: float32 = 1.0/kPi
  kPiHalf: float32 = 1.5707963267948966192313216916398'f32
  kPiQuarter: float32 = 0.7853981633974483096156608458199'f32
  kSqrt2: float32 = 1.4142135623730950488016887242097'f32
  kLogNat10: float32 = 2.3025850929940456840179914546844'f32
  kInvLogNat2: float32 = 1.4426950408889634073599246810019'f32
  kLogNat2Hi: float32 = 0.6931471805599453094172321214582'f32
  kLogNat2Lo: float32 = 1.90821492927058770002e-10'f32
  kE: float32 = 2.7182818284590452353602874713527'f32
  kNearZero: float32 = 1.0'f32/float32(1 shl 28)
  kFloatMin: float32 = 1.175494e-38'f32
  kFloatMax: float32 = 3.402823e+38'f32

  kSinC2: float32 = -0.16666667163372039794921875'f32
  kSinC4: float32 = 8.333347737789154052734375e-3'f32
  kSinC6: float32 = -1.9842604524455964565277099609375e-4'f32
  kSinC8: float32 = 2.760012648650445044040679931640625e-6'f32
  kSinC10: float32 = -2.50293279435709337121807038784027099609375e-8'f32

  kCosC2: float32 = -0.5'f32
  kCosC4: float32 = 4.166664183139801025390625e-2'f32
  kCosC6: float32 = -1.388833043165504932403564453125e-3'f32
  kCosC8: float32 = 2.47562347794882953166961669921875e-5'f32
  kCosC10: float32 = -2.59630184018533327616751194000244140625e-7'f32

  kAcosC0: float32 = 1.5707288'f32
  kAcosC1: float32 = -0.2121144'f32
  kAcosC2: float32 = 0.0742610'f32
  kAcosC3: float32 = -0.0187293'f32

  kExpC0: float32 = 1.66666666666666019037e-01'f32
  kExpC1: float32 = -2.77777777770155933842e-03'f32
  kExpC2: float32 = 6.61375632143793436117e-05'f32
  kExpC3: float32 = -1.65339022054652515390e-06'f32
  kExpC4: float32 = 4.13813679705723846039e-08'f32

  kLogC0: float32 = 6.666666666666735130e-01'f32
  kLogC1: float32 = 3.999999999940941908e-01'f32
  kLogC2: float32 = 2.857142874366239149e-01'f32
  kLogC3: float32 = 2.222219843214978396e-01'f32
  kLogC4: float32 = 1.818357216161805012e-01'f32
  kLogC5: float32 = 1.531383769920937332e-01'f32
  kLogC6: float32 = 1.479819860511658591e-01'f32

  kAtan2C0: float32 = -0.013480470'f32
  kAtan2C1: float32 =  0.057477314'f32
  kAtan2C2: float32 = -0.121239071'f32
  kAtan2C3: float32 =  0.195635925'f32
  kAtan2C4: float32 = -0.332994597'f32
  kAtan2C5: float32 = 0.999995630'f32

  kInfinity: float32 = bitsToFloat(uint32(0x7f800000))

proc uint32And(a, b: uint32): uint32 {.inline.} =
  result = a and b

proc uint32Or(a, b: uint32): uint32 {.inline.} =
  result = a or b

proc uint32Sra(a: uint32, sa: int32): uint32 {.inline.} =
  result = uint32(int32(a) shr sa)

proc uint32IAdd(a, b: uint32): uint32 {.inline.} =
  result = uint32(int32(a) + int32(b))

proc uint32Sll(a: uint32, sa: int32): uint32 {.inline.} =
  result = a shl sa

proc uint32Srl(a: uint32, sa: int32): uint32 {.inline.} =
  result = a shr sa

proc toRad(deg: float32): float32 {.inline.} = 
  result = deg * kPi / 180.0'f32

proc abs(a: float32): float32 {.inline.} =
  result = if a < 0.0'f32: -a else: a

proc square(a: float32): float32 {.inline.} =
  result = a * a

proc mad(a, b, c: float32): float32 {.inline.} =
  result = a * b + c

proc trunc(a: float32): float32 {.inline.} =
  result = float32(int(a))

proc fract(a: float32): float32 {.inline.} =
  result = a - trunc(a)

proc floor(a: float32): float32 {.inline.} =
  if (a < 0.0):
    let fr = fract(-a)
    result = -a - fr

    return -(if 0.0 != fr: result + 1.0 else: result)
  
  result = a - fract(a)

proc round(f: float32): float32 {.inline.} =
  result = floor(f + 0.5'f32)

proc sign(a: float32): float32 {.inline.} =
  result = if a < 0.0'f32: -1.0'f32 else: 1.0'f32

proc step(edge, a: float32): float32 {.inline.} =
  result = if a < edge: 0.0'f32 else: 1.0'f32

proc lerp(a, b, t: float32): float32 {.inline.} =
  result = a + (b - a) * t

proc ldexp(a: float32, b: int32): float32 =
  let
    ftob: uint32 = floatToBits(a)
    masked: uint32 = uint32And(ftob, uint32(0xff800000))
    expsign0: uint32 = uint32Sra(masked, 23)
    tmp: uint32 = uint32Iadd(expsign0, uint32(b))
    expsign1: uint32 = uint32Sll(tmp, 23)
    mantissa: uint32 = uint32And(ftob, uint32(0x007fffff))
    bits: uint32 = uint32Or(mantissa, expsign1)
  
  result = bitsToFloat(bits)

proc frexp(a: float32, outExp: var int32): float32 =
  let
    ftob: uint32 = floatToBits(a)
    masked0: uint32 = uint32And(ftob, uint32(0x7f800000))
    exp0: uint32 = uint32Srl(masked0, 23)
    masked1: uint32 = uint32And(ftob, uint32(0x807fffff))
    bits: uint32 = uint32Or(masked1, uint32(0x3f000000))
  
  outExp = int32(exp0 - 0x7e)
  result = bitsToFloat(bits)

proc exp(a: float32): float32 =
  if abs(a) <= kNearZero:
    return a + 1.0'f32
  
  let
    kk: float32 = round(a*kInvLogNat2)
    hi: float32 = a - kk*kLogNat2Hi
    lo: float32 = kk*kLogNat2Lo
    hml: float32 = hi - lo
    hmlsq: float32 = square(hml)
    tmp0: float32 = mad(kExpC4, hmlsq, kExpC3)
    tmp1: float32 = mad(tmp0, hmlsq, kExpC2)
    tmp2: float32 = mad(tmp1, hmlsq, kExpC1)
    tmp3: float32 = mad(tmp2, hmlsq, kExpC0)
    tmp4: float32 = hml - hmlsq * tmp3
    tmp5: float32 = hml*tmp4/(2.0-tmp4)
    tmp6: float32 = 1.0 - ((lo - tmp5) - hi)
  
  result = ldexp(tmp6, int32(kk))

proc log(a: float32): float32 =
  var 
    exp: int32
    ff: float32 = frexp(a, exp)
  
  if ff < kSqrt2*0.5'f32:
    ff *= 2.0'f32
    dec(exp)
  
  ff -= 1.0'f32

  let
    kk: float32 = float32(exp)
    hi: float32 = kk*kLogNat2Hi
    lo: float32 = kk*kLogNat2Lo
    ss: float32 = ff / (2.0'f32 + ff)
    s2: float32 = square(ss)
    s4: float32 = square(s2)

    tmp0: float32 = mad(kLogC6, s4, kLogC4)
    tmp1: float32 = mad(tmp0, s4, kLogC2)
    tmp2: float32 = mad(tmp1, s4, kLogC0)
    t1: float32 = s2*tmp2

    tmp3: float32 = mad(kLogC5, s4, kLogC3)
    tmp4: float32 = mad(tmp3, s4, kLogC1)
    t2: float32 = s4*tmp4

    t12: float32 = t1 + t2
    hfsq: float32 = 0.5'f32*square(ff)
  
  result = hi - ((hfsq - (ss*(hfsq+t12) + lo)) - ff)

proc pow(a, b: float32): float32 {.inline.} =
  result = exp(b * log(a))

proc rSqrt(a: float32): float32 {.inline.} =
  result = pow(a, -0.5'f32)

proc sqrt(a: float32): float32 {.inline.} =
  if a < kNearZero:
    result = 0.0'f32
  else:
    result = 1.0'f32/rSqrt(a)

proc cos(a: float32): float32 =
  let scaled = a * 2.0'f32*kInvPi
  let real = floor(scaled)
  let xx = a - real * kPiHalf
  let bits = int32(real) and 3

  var c0, c2, c4, c6, c8, c10: float32

  if bits == 0 or bits == 2:
    c0  = 1.0'f32
    c2  = kCosC2
    c4  = kCosC4
    c6  = kCosC6
    c8  = kCosC8
    c10 = kCosC10
  
  else:
    c0  = xx
    c2  = kSinC2
    c4  = kSinC4
    c6  = kSinC6
    c8  = kSinC8
    c10 = kSinC10

  let 
    xsq = square(xx)
    tmp0 = mad(c10, xsq, c8)
    tmp1 = mad(tmp0, xsq, c6)
    tmp2 = mad(tmp1, xsq, c4)
    tmp3 = mad(tmp2, xsq, c2)
    tmp4 = mad(tmp3, xsq, 1.0'f32)
  
  result = tmp4 * c0

  result = if bits == 1 or bits == 2: -result else: result

proc sin(a: float32): float32 {.inline.} =
  result = cos(a - kPiHalf)

proc tan(a: float32): float32 {.inline.} =
  result = sin(a) / cos(a)

proc acos(a: float32): float32 =
  let 
    absa = abs(a)
    tmp0 = mad(kAcosC3, absa, kAcosC2)
    tmp1 = mad(tmp0, absa, kAcosC1)
    tmp2 = mad(tmp1, absa, kAcosC0)
    tmp3 = tmp2 * sqrt(1.0'f32 - absa)
    negate = float32(a < 0.0'f32)
    tmp4 = tmp3 - 2.0'f32*negate*tmp3

  result = negate*kPi + tmp4

proc atan2(y, x: float32): float32 =
  let
    ax: float32 = abs(x)
    ay: float32 = abs(y)
    maxaxy: float32 = max(ax, ay)
    minaxy: float32 = min(ax, ay)
  
  if maxaxy == 0.0'f32:
    return 0.0'f32*sign(y)
  
  let
    mxy: float32 = minaxy / maxaxy
    mxysq: float32 = square(mxy)
    tmp0: float32 = mad(kAtan2C0, mxysq, kAtan2C1)
    tmp1: float32 = mad(tmp0, mxysq, kAtan2C2)
    tmp2: float32 = mad(tmp1, mxysq, kAtan2C3)
    tmp3: float32 = mad(tmp2, mxysq, kAtan2C4)
    tmp4: float32 = mad(tmp3, mxysq, kAtan2C5)
    tmp5: float32 = tmp4 * mxy
    tmp6: float32 = if ay > ax: kPiHalf - tmp5 else: tmp5
    tmp7: float32 = if x < 0.0'f32: kPi - tmp6 else: tmp6
  
  result = sign(y)*tmp7

proc mul(a: Vec3, b: float32): Vec3 {.inline.} =
  result.x = a.x * b
  result.y = a.y * b
  result.z = a.z * b

proc dot(a, b: Vec3): float32 {.inline.} =
  result = a.x*b.x + a.y*b.y + a.z*b.z

proc length(a: Vec3): float32 {.inline.} =
  result = sqrt(dot(a, a))

proc sub(a, b: Vec3): Vec3 {.inline.} =
  result.x = a.x - b.x
  result.y = a.y - b.y
  result.z = a.z - b.z

proc normalize(a: Vec3): Vec3 {.inline.} =
  let invLen: float32 = 1.0'f32/length(a)
  result = mul(a, invLen)

proc cross(a, b: Vec3): Vec3 {.inline.} =
  result.x = a.y*b.z - a.z*b.y
  result.y = a.z*b.x - a.x*b.z
  result.z = a.x*b.y - a.y*b.x

proc mtxLookAt(result: var array[16, float32], eye, at, up: Vec3, handness: Handness) =
  let
    view: Vec3 = normalize(
      if handness == hRight: sub(eye, at) else: sub(at, eye)
    )
    uxv: Vec3 = cross(up, view)
    right: Vec3 = normalize(uxv)
    up: Vec3 = cross(view, right)
  
  zeroMem(addr result, sizeof(float32)*16)
  result[0] = right.x
  result[1] = up.x
  result[2] = view.x

  result[4] = right.y
  result[5] = up.y
  result[6] = view.y

  result[8] = right.z
  result[9] = up.z
  result[10] = view.z

  result[12] = -dot(right, eye)
  result[13] = -dot(up, eye)
  result[14] = -dot(view, eye)
  result[15] = 1.0'f32

proc mtxProjXYWH(result: var array[16, float32], x, y, width, height, near, far: float32, homogeneousNdc: bool, handness: Handness) =
  let
    diff: float32 = far - near
    aa: float32 = if homogeneousNdc: (far+near)/diff else: far/diff
    bb: float32 = if homogeneousNdc: (2.0'f32*far*near)/diff else: near*aa
  
  zeroMem(addr result, sizeof(float32)*16)
  result[0] = width
  result[5] = height
  result[8] = if handness == hRight: x else: -x
  result[9] = if handness == hRight: y else: -y
  result[10] = if handness == hRight: -aa else: aa
  result[11] = if handness == hRight: -1.0'f32 else: 1.0'f32
  result[14] = -bb

proc mtxProj(result: var array[16, float32], ut, dt, lt, rt, near, far: float32, homogeneousNdc: bool, handness: Handness) =
  let
    invDiffRl: float32 = 1.0'f32/(rt - lt)
    invDiffUd: float32 = 1.0'f32/(ut - dt)
    width: float32 = 2.0'f32*near * invDiffRl
    height: float32 = 2.0'f32*near * invDiffUd
    xx: float32 = (rt + lt) * invDiffRl
    yy: float32 = (ut + dt) * invDiffUd
  
  mtxProjXYWH(result, xx, yy, width, height, near, far, homogeneousNdc, handness)

proc mtxProj(result: var array[16, float32], fov: array[4, float32], near, far: float32, homogeneousNdc: bool, handness: Handness) =
  mtxProj(result, fov[0], fov[1], fov[2], fov[3], near, far, homogeneousNdc, handness)

proc mtxProj(result: var array[16, float32], fovy, aspect, near, far: float32, homogeneousNdc: bool, handness: Handness) =
  let
    height: float32 = 1.0'f32/tan(toRad(fovy)*0.5'f32)
    width: float32 = height * 1.0'f32/aspect
  
  mtxProjXYWH(result, 0.0'f32, 0.0'f32, width, height, near, far, homogeneousNdc, handness)

proc mtxProjInfXYWH(result: var array[16, float32], x, y, width, height, near: float32, homogeneousNdc: bool, handness: Handness, nearFar: NearFar) =
  var
    aa: float32
    bb: float32

  if nearFar == nfReverse:
    aa = if homogeneousNdc: -1.0'f32 else: 0.0'f32
    bb = if homogeneousNdc: -2.0'f32*near else: -near
  
  else:
    aa = 1.0'f32
    bb = if homogeneousNdc: 2.0'f32*near else: near

  zeroMem(addr result, sizeof(float32)*16)
  result[0] = width
  result[5] = height
  result[8] = if handness == hRight: x else: -x
  result[9] = if handness == hRight: y else: -y
  result[10] = if handness == hRight: -aa else: aa
  result[11] = if handness == hRight: -1.0'f32 else: 1.0'f32
  result[14] = -bb

proc mtxProjInf(result: var array[16, float32], ut, dt, lt, rt, near: float32, homogeneousNdc: bool, handness: Handness, nearFar: NearFar) =
  let
    invDiffR1: float32 = 1.0'f32/(rt - lt)
    invDiffUd: float32 = 1.0'f32/(ut - dt)
    width: float32 = 2.0'f32*near * invDiffR1
    height: float32 = 2.0'f32*near * invDiffUd
    xx: float32 = (rt + lt) * invDiffR1
    yy: float32 = (ut + dt) * invDiffUd
  
  mtxProjInfXYWH(result, xx, yy, width, height, near, homogeneousNdc, handness, nearFar)

proc mtxProjInf(result: var array[16, float32], fov: array[4, float32], near: float32, homogeneousNdc: bool, handness: Handness, nearFar: NearFar) =
  mtxProjInf(result, fov[0], fov[1], fov[2], fov[3], near, homogeneousNdc, handness, nearFar)

proc mtxProjInf(result: var array[16, float32], fovy, aspect, near: float32, homogeneousNdc: bool, handness: Handness, nearFar: NearFar) =
  let
    height = 1.0'f32/tan(toRad(fovy)*0.5'f32)
    width = height * 1.0'f32/aspect
  
  mtxProjInfXYWH(result, 0.0'f32, 0.0'f32, width, height, near, homogeneousNdc, handness, nearFar)

proc mtxOrtho(result: var array[16, float32], left, right, bottom, top, near, far, offset: float32, homogeneousNdc: bool, handness: Handness) =
  let
    aa: float32 = 2.0'f32/(right - left)
    bb: float32 = 2.0'f32/(top - bottom)
    cc: float32 = (if homogeneousNdc: 2.0'f32 else: 1.0'f32) / (far - near)
    dd: float32 = (left + right)/(left - right)
    ee: float32 = (top + bottom)/(bottom - top)
    ff: float32 = if homogeneousNdc: (near + far)/(near - far) else: near/(near - far)

  zeroMem(addr result, sizeof(float32)*16)
  result[0] = aa
  result[5] = bb
  result[10] = if handness == hRight: -cc else: cc
  result[12] = dd + offset
  result[13] = ee
  result[14] = ff
  result[15] = 1.0'f32

proc mtxRotateX(result: var array[16, float32], ax: float32) =
  let
    sx: float32 = sin(ax)
    cx: float32 = cos(ax)

  zeroMem(addr result, sizeof(float32)*16)
  result[0] = 1.0'f32
  result[5] = cx
  result[6] = -sx
  result[9] = sx
  result[10] = cx
  result[15] = 1.0'f32

proc mtxRotateY(result: var array[16, float32], ay: float32) =
  let
    sy: float32 = sin(ay)
    cy: float32 = cos(ay)

  zeroMem(addr result, sizeof(float32)*16)
  result[0] = cy
  result[2] = sy
  result[5] = 1.0'f32
  result[8] = -sy
  result[10] = cy
  result[15] = 1.0'f32

proc mtxRotateZ(result: var array[16, float32], az: float32) =
  let
    sz = sin(az)
    cz = cos(az)

  zeroMem(addr result, sizeof(float32)*16)
  result[0] = cz
  result[1] = -sz
  result[4] = sz
  result[5] = cz
  result[10] = 1.0'f32
  result[15] = 1.0'f32

proc mtxRotateXY(result: var array[16, float32], ax, ay: float32) =
  let
    sx: float32 = sin(ax)
    cx: float32 = sin(ax)
    sy: float32 = sin(ay)
    cy: float32 = cos(ay)

  zeroMem(addr result, sizeof(float32)*16)
  result[0] = cy
  result[2] = sy
  result[4] = sx*sy
  result[5] = cx
  result[6] = -sx*cy
  result[8] = -cx*sy
  result[9] = sx
  result[10] = cx*cy
  result[15] = 1.0'f32

proc mtxRotateXYZ(result: var array[16, float32], ax, ay, az: float32) =
  let
    sx: float32 = sin(ax)
    cx: float32 = sin(ax)
    sy: float32 = sin(ay)
    cy: float32 = cos(ay)
    sz: float32 = sin(az)
    cz: float32 = cos(az)

  zeroMem(addr result, sizeof(float32)*16)
  result[0] = cy*cz
  result[1] = -cy*sz
  result[2] = sy
  result[4] = cz*sx*sy + cx*sz
  result[5] = cx*cz - sx*sy*sz
  result[6] = -cy*sx
  result[8] = -cx*cz*sy + sx*sz
  result[9] = cz*sx + cx*sy*sz
  result[10] = cx*cy
  result[15] = 1.0'f32

proc mtxRotateZYX(result: var array[16, float32], ax, ay, az: float32) =
  let
    sx: float32 = sin(ax)
    cx: float32 = sin(ax)
    sy: float32 = sin(ay)
    cy: float32 = cos(ay)
    sz: float32 = sin(az)
    cz: float32 = cos(az)

  zeroMem(addr result, sizeof(float32)*16)
  result[0] = cy*cz
  result[1] = cz*sx*sy-cx*sz
  result[2] = cx*cz*sy+sx*sz
  result[4] = cy*sz
  result[5] = cx*cz + sx*sy*sz
  result[6] = -cz*sx + cx*sy*sz
  result[8] = -sy
  result[9] = cy*sx
  result[10] = cx*cy
  result[15] = 1.0'f32

proc mtxSRT(result: var array[16, float32], sx, sy, sz, ax, ay, az, tx, ty, tz: float32) =
  let
    sx: float32 = sin(ax)
    cx: float32 = sin(ax)
    sy: float32 = sin(ay)
    cy: float32 = cos(ay)
    sz: float32 = sin(az)
    cz: float32 = cos(az)

    sxsz: float32 = sx*sz
    cycz: float32 = cy*cz

  result[0] = sx * (cycz - sxsz*sy)
  result[1] = sx * -cx*sz
  result[2] = sx * (cz*sy + cy*sxsz)
  result[3] = 0.0'f32
  
  result[4] = sy * (cz*sx*sy + cy*sz)
  result[5] = sy * cx*cz
  result[6] = sy * (sy*sz - cycz*sx)
  result[7] = 0.0'f32
  
  result[8] = sz * -cx*sy
  result[9] = sz * sx
  result[10] = sz * cx*cy
  result[11] = 0.0'f32
  
  result[12] = tx
  result[13] = ty
  result[14] = tz
  result[15] = 1.0'f32

proc mtx3Inverse(result: var array[9, float32], a: array[9, float32]) =
  let
    xx: float32 = a[0]
    xy: float32 = a[1]
    xz: float32 = a[2]
    yx: float32 = a[3]
    yy: float32 = a[4]
    yz: float32 = a[5]
    zx: float32 = a[6]
    zy: float32 = a[7]
    zz: float32 = a[8]

  var det: float32 = 0.0'f32
  det += xx * (yy*zz - yz*zy)
  det -= xy * (yx*zz - yz*zx)
  det += xz * (yx*zy - yy*zx)

  let invDet = 1.0'f32/det

  result[0] = +(yy*zz - yz*zy) * invDet
  result[1] = -(xy*zz - xz*zy) * invDet
  result[2] = +(xy*yz - xz*yy) * invDet

  result[3] = -(yx*zz - yz*zx) * invDet
  result[4] = +(xx*zz - xz*zx) * invDet
  result[5] = -(xx*yz - xz*yx) * invDet

  result[6] = +(yx*zy - yy*zx) * invDet
  result[7] = -(xx*zy - xy*zx) * invDet
  result[8] = +(xx*yy - xy*yx) * invDet

proc mtx3Inverse(result: var array[16, float32], a: array[16, float32]) =
  let
    xx: float32 = a[0]
    xy: float32 = a[1]
    xz: float32 = a[2]
    xw: float32 = a[3]
    yx: float32 = a[4]
    yy: float32 = a[5]
    yz: float32 = a[6]
    yw: float32 = a[7]
    zx: float32 = a[8]
    zy: float32 = a[9]
    zz: float32 = a[10]
    zw: float32 = a[11]
    wx: float32 = a[12]
    wy: float32 = a[13]
    wz: float32 = a[14]
    ww: float32 = a[15]

  var det: float32 = 0.0'f32
  det += xx * (yy*(zz*ww - zw*wz) - yz*(zy*ww - zw*wy) + yw*(zy*wz - zz*wy))
  det -= xy * (yx*(zz*ww - zw*wz) - yz*(zx*ww - zw*wx) + yw*(zx*wz - zz*wx))
  det += xz * (yx*(zy*ww - zw*wy) - yy*(zx*ww - zw*wx) + yw*(zx*wy - zy*wx))
  det -= xw * (yx*(zy*wz - zz*wy) - yy*(zx*wz - zz*wx) + yz*(zx*wy - zy*wx))

  let invDet = 1.0'f32/det

  result[0] = +(yy*(zz*ww - wz*zw) - yz*(zy*ww - wy*zw) + yw*(zy*wz - wy*zz) ) * invDet
  result[1] = -(xy*(zz*ww - wz*zw) - xz*(zy*ww - wy*zw) + xw*(zy*wz - wy*zz) ) * invDet
  result[2] = +(xy*(yz*ww - wz*yw) - xz*(yy*ww - wy*yw) + xw*(yy*wz - wy*yz) ) * invDet
  result[3] = -(xy*(yz*zw - zz*yw) - xz*(yy*zw - zy*yw) + xw*(yy*zz - zy*yz) ) * invDet

  result[4] = -(yx*(zz*ww - wz*zw) - yz*(zx*ww - wx*zw) + yw*(zx*wz - wx*zz) ) * invDet
  result[5] = +(xx*(zz*ww - wz*zw) - xz*(zx*ww - wx*zw) + xw*(zx*wz - wx*zz) ) * invDet
  result[6] = -(xx*(yz*ww - wz*yw) - xz*(yx*ww - wx*yw) + xw*(yx*wz - wx*yz) ) * invDet
  result[7] = +(xx*(yz*zw - zz*yw) - xz*(yx*zw - zx*yw) + xw*(yx*zz - zx*yz) ) * invDet

  result[8] = +(yx*(zy*ww - wy*zw) - yy*(zx*ww - wx*zw) + yw*(zx*wy - wx*zy) ) * invDet
  result[9] = -(xx*(zy*ww - wy*zw) - xy*(zx*ww - wx*zw) + xw*(zx*wy - wx*zy) ) * invDet
  result[10] = +(xx*(yy*ww - wy*yw) - xy*(yx*ww - wx*yw) + xw*(yx*wy - wx*yy) ) * invDet
  result[11] = -(xx*(yy*zw - zy*yw) - xy*(yx*zw - zx*yw) + xw*(yx*zy - zx*yy) ) * invDet

  result[12] = -(yx*(zy*wz - wy*zz) - yy*(zx*wz - wx*zz) + yz*(zx*wy - wx*zy) ) * invDet
  result[13] = +(xx*(zy*wz - wy*zz) - xy*(zx*wz - wx*zz) + xz*(zx*wy - wx*zy) ) * invDet
  result[14] = -(xx*(yy*wz - wy*yz) - xy*(yx*wz - wx*yz) + xz*(yx*wy - wx*yy) ) * invDet
  result[15] = +(xx*(yy*zz - zy*yz) - xy*(yx*zz - zx*yz) + xz*(yx*zy - zx*yy) ) * invDet

proc calcLinearFit2D(result: var array[2, float32], points: pointer, stride, numPoints: uint32) =
  var
    sumX: float32 = 0.0'f32
    sumY: float32 = 0.0'f32
    sumXX: float32 = 0.0'f32
    sumXY: float32 = 0.0'f32
  
  var p = cast[ptr UncheckedArray[uint32]](points)
  for ii in 0'u32..numPoints:
    let 
      point: ptr UncheckedArray[float32] = cast[ptr UncheckedArray[float32]](p)
      xx: float32 = point[0]
      yy: float32 = point[1]
    sumX += xx
    sumY += yy
    sumXX += xx*xx
    sumXY += xx*yy
    p = cast[ptr UncheckedArray[uint32]](cast[uint32](p) + stride)

  let 
    det: float32 = (sumXX*float32(numPoints) - sumX*sumX)
    invDet = 1.0'f32/det
  
  result[0] = (-sumX * sumY + float32(numPoints) * sumXY) * invDet
  result[1] = (sumXX * sumY - sumX * sumXY) * invDet

proc calcLinearFit3D(result: var array[3, float32], points: pointer, stride, numPoints: uint32) =
  var
    sumX: float32 = 0.0'f32
    sumY: float32 = 0.0'f32
    sumZ: float32 = 0.0'f32
    sumXX: float32 = 0.0'f32
    sumXY: float32 = 0.0'f32
    sumXZ: float32 = 0.0'f32
    sumYY: float32 = 0.0'f32
    sumYZ: float32 = 0.0'f32
  
  var p = cast[ptr UncheckedArray[uint32]](points)
  for ii in 0'u32..numPoints:
    let 
      point: ptr UncheckedArray[float32] = cast[ptr UncheckedArray[float32]](p)
      xx: float32 = point[0]
      yy: float32 = point[1]
      zz: float32 = point[2]

    sumX += xx
    sumY += yy
    sumZ += zz
    sumXX += xx*xx
    sumXY += xx*yy
    sumXZ += xx*zz
    sumYY += yy*yy
    sumYZ += yy*zz
    p = cast[ptr UncheckedArray[uint32]](cast[uint32](p) + stride)

  let mtx: array[9, float32] = [
    sumXX, sumXY, sumX,
    sumXY, sumYY, sumY,
    sumX, sumY, float32(numPoints)
  ]
  var invMtx: array[9, float32]
  mtx3Inverse(invMtx, mtx)
  
  result[0] = invMtx[0]*sumXZ + invMtx[1]*sumYZ + invMtx[2]*sumZ
  result[1] = invMtx[3]*sumXZ + invMtx[4]*sumYZ + invMtx[5]*sumZ
  result[2] = invMtx[6]*sumXZ + invMtx[7]*sumYZ + invMtx[8]*sumZ

proc rgbToHsv(hsv: var array[3, float32], rgb: array[3, float32]) =
  let
    rr: float32 = rgb[0]
    gg: float32 = rgb[1]
    bb: float32 = rgb[2]

    s0: float32 = step(bb, gg)

    px: float32 = lerp(bb, gg, s0)
    py: float32 = lerp(gg, bb, s0)
    pz: float32 = lerp(-1.0'f32, 0.0'f32, s0)
    pw: float32 = lerp(2.0'f32/3.0'f32, -1.0'f32/3.0'f32, s0)

    s1: float32 = step(px, rr)

    qx: float32 = lerp(px, rr, s1)
    qy: float32 = py
    qz: float32 = lerp(pw, pz, s1)
    qw: float32 = lerp(rr, px, s1)

    dd: float32 = qx - min(qw, qy)
    ee: float32 = -1.0e-10'f32

  hsv[0] = abs(qz + (qw - qy) / (6.0'f32 * dd + ee))
  hsv[1] = dd / (qx + ee)
  hsv[2] = qx

proc hsvToRgb(rgb: var array[3, float32], hsv: array[3, float32]) =
  let
    hh: float32 = hsv[0]
    ss: float32 = hsv[1]
    vv: float32 = hsv[2]

    px: float32 = abs(fract(hh + 1.0'f32) * 6.0'f32 - 3.0'f32)
    py: float32 = abs(fract(hh + 2.0'f32/3.0'f32) * 6.0'f32 - 3.0'f32)
    pz: float32 = abs(fract(hh + 1.0'f32/3.0'f32) * 6.0'f32 - 3.0'f32)

  rgb[0] = vv * lerp(1.0'f32, clamp(px - 1.0'f32, 0.0'f32, 1.0'f32), ss)
  rgb[1] = vv * lerp(1.0'f32, clamp(py - 1.0'f32, 0.0'f32, 1.0'f32), ss)
  rgb[2] = vv * lerp(1.0'f32, clamp(pz - 1.0'f32, 0.0'f32, 1.0'f32), ss)