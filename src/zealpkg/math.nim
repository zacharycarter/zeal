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


proc bitsToFloat(a: uint32): float32 =
  result = cast[float32](a)

proc floatToBits(a: float32): uint32 =
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

proc uint32And(a, b: uint32): uint32 =
  result = a and b

proc uint32Or(a, b: uint32): uint32 =
  result = a or b

proc uint32Sra(a: uint32, sa: int32): uint32 =
  result = uint32(int32(a) shr sa)

proc uint32IAdd(a, b: uint32): uint32 =
  result = uint32(int32(a) + int32(b))

proc uint32Sll(a: uint32, sa: int32): uint32 =
  result = a shl sa

proc uint32Srl(a: uint32, sa: int32): uint32 =
  result = a shr sa

proc toRad(deg: float32): float32 =
  result = deg * kPi / 180.0'f32

proc abs(a: float32): float32 =
  result = if a < 0.0'f32: -a else: a

proc square(a: float32): float32 =
  result = a * a

proc mad(a, b, c: float32): float32 =
  result = a * b + c

proc trunc(a: float32): float32 =
  result = float32(int(a))

proc fract(a: float32): float32 =
  result = a - trunc(a)

proc floor(a: float32): float32 =
  if (a < 0.0):
    let fr = fract(-a)
    result = -a - fr

    return -(if 0.0 != fr: result + 1.0 else: result)
  
  result = a - fract(a)

proc round(f: float32): float32 =
  result = floor(f + 0.5'f32)

proc sign(a: float32): float32 =
  result = if a < 0.0'f32: -1.0'f32 else: 1.0'f32

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

proc frexp(a: float32, outExp: var int32): float32 =
  let
    ftob: uint32 = floatToBits(a)
    masked0: uint32 = uint32And(ftob, uint32(0x7f800000))
    exp0: uint32 = uint32Srl(masked0, 23)
    masked1: uint32 = uint32And(ftob, uint32(0x807fffff))
    bits: uint32 = uint32Or(masked1, uint32(0x3f000000))
  
  outExp = int32(exp0 - 0x7e)
  result = bitsToFloat(bits)

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

proc pow(a, b: float32): float32 =
  result = exp(b * log(a))

proc rSqrt(a: float32): float32 =
  result = pow(a, -0.5'f32)

proc sqrt(a: float32): float32 =
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

proc sin(a: float32): float32 =
  result = cos(a - kPiHalf)

proc tan(a: float32): float32 =
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

proc mul(a: Vec3, b: float32): Vec3 =
  result.x = a.x * b
  result.y = a.y * b
  result.z = a.z * b

proc dot(a, b: Vec3): float32 =
  result = a.x*b.x + a.y*b.y + a.z*b.z

proc length(a: Vec3): float32 =
  result = sqrt(dot(a, a))

proc sub(a, b: Vec3): Vec3 =
  result.x = a.x - b.x
  result.y = a.y - b.y
  result.z = a.z - b.z

proc normalize(a: Vec3): Vec3 =
  let invLen: float32 = 1.0'f32/length(a)
  result = mul(a, invLen)

proc cross(a, b: Vec3): Vec3 =
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