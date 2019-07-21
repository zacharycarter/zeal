import camera, event, fpmath, simulation, sdl2 as sdl

type
  FPSCamCtx = object
    moveFront: bool
    moveBack: bool
    moveLeft: bool
    moveRight: bool

  RTSCamCtx = object
    moveUp: bool
    moveDown: bool
    moveLeft: bool
    moveRight: bool
    panDisabled: bool

  ActiveCtx {.union.} = object
    fps: FPSCamCtx
    rts: RTSCamCtx

  CameraCtx = object
    active: Camera
    activeCtx: ActiveCtx
    onKeyDown: HandlerProc
    onKeyUp: HandlerProc
    onMouseMove: HandlerProc
    onMouseDown: HandlerProc
    onMouseUp: HandlerProc
    onUpdateEnd: HandlerProc

var camCtx: CameraCtx

proc rtsOnMouseMove(unused: pointer, eventArg: pointer) =
  var 
    ctx = camCtx.activeCtx.rts
    mouseX, mouseY: cint
    width, height: cint

  let e = cast[sdl.MouseMotionEventPtr](eventArg)
  sdl.getMouseState(mouseX, mouseY)

  ctx.moveUp = (mouseY == 0)
  ctx.moveDown = (mouseY == 540 - 1)
  ctx.moveLeft = (mouseX == 0)
  ctx.moveRight = (mouseX == 960 - 1)

proc rtsOnMouseDown(unused: pointer, eventArg: pointer) =
  var ctx = camCtx.activeCtx.rts

  let e = cast[sdl.MouseButtonEventPtr](eventArg)

  if ctx.moveUp or ctx.moveDown or ctx.moveLeft or ctx.moveRight:
    return

  if e.button == sdl.BUTTON_LEFT:
    ctx.panDisabled = true

proc rtsOnMouseUp(unused: pointer, eventArg: pointer) =
  var ctx = camCtx.activeCtx.rts

  let e = cast[sdl.MouseButtonEventPtr](eventArg)
  
  if e.button == sdl.BUTTON_LEFT:
    ctx.panDisabled = false

proc rtsOnUpdateEnd(unused: pointer, eventArg: pointer) =
  var 
    ctx = camCtx.activeCtx.rts
    cam = camCtx.active
  
  let yaw = getYaw(cam)

  #
  # Our yaw represents the following rotations:
  #          90*
  #           ^
  #  sin +ve  | sin +ve
  #  cos -ve  | cos +ve
  #           |
  # 180* <----+----> 0*
  #           |
  #  sin -ve  | sin -ve
  #  cos -ve  | cos +ve
  #           v
  #          270*
  #
  # Our coodinate system is the following:
  #         -Z
  #          ^
  #          |
  #   +X <---+---> -X
  #          |
  #          v
  #          +Z
  #
  # We want the behavior in which the camera is always scrolled up, down, left, right
  # depending on which corner/edge of the screen the mouse is touching. However, which
  # direction is 'up' or 'left' depends completely on where the camera is facing. For example,
  # 'up' becomes 'down' when the camera pitch is changed from 90* to 270*.
  #

  let
    up = [1.0'f32 * cos(degToRad(yaw)), 0.0, -1.0 * sin(degToRad(yaw))]
    left = [1.0'f32 * sin(degToRad(yaw)), 0.0, 1.0 * cos(degToRad(yaw))]
    down = [-up[0], up[1], -up[2]]
    right = [-left[0], left[1], -left[2]]
  
  assert(not (ctx.moveLeft and ctx.moveRight))
  assert(not (ctx.moveUp and ctx.moveDown))

  var dir = [0.0'f32, 0.0, 0.0]

  if not ctx.panDisabled:
    if ctx.moveLeft: vec3Add(dir, left, dir)
    if ctx.moveRight: vec3Add(dir, right, dir)
    if ctx.moveUp: vec3Add(dir, up, dir)
    if ctx.moveDown: vec3Add(dir, down, dir)

  moveDirectionTick(cam, dir)
  tickFinishPerspective(cam)


proc resetControls*() =
  globalUnregister(EventKind(sdl.KeyDown), camCtx.onKeyDown)
  globalUnregister(EventKind(sdl.KeyUp), camCtx.onKeyUp)
  globalUnregister(EventKind(sdl.MouseMotion), camCtx.onMouseMove)
  globalUnregister(EventKind(sdl.MouseButtonDown), camCtx.onMouseDown)
  globalUnregister(EventKind(sdl.MouseButtonUp), camCtx.onMouseUp)
  globalUnregister(ekUpdateEnd, camCtx.onUpdateEnd)

proc rtsControls*(camera: Camera) =
  resetControls()

  globalRegister(EventKind(sdl.MouseMotion), rtsOnMouseMove, nil, int32(ssRunning))
  globalRegister(EventKind(sdl.MouseButtonDown), rtsOnMouseDown, nil, int32(ssRunning))
  globalRegister(EventKind(sdl.MouseButtonUp), rtsOnMouseUp, nil, int32(ssRunning))
  globalRegister(ekUpdateEnd, rtsOnUpdateEnd, nil, int32(ssRunning.ord or ssPausedFull.ord or ssPausedUiRunning.ord))

  camCtx.onMouseMove = rtsOnMouseMove
  camCtx.onMouseDown = rtsOnMouseDown
  camCtx.onMouseUp = rtsOnMouseUp
  camCtx.onUpdateEnd = rtsOnUpdateEnd
  camCtx.active = camera