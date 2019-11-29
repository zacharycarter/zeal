import bgfxdotnim, bgfxdotnim/platform, os, sdl2 as sdl, nimLUA, ../lib/nuklear
import zealpkg / [event, game, simulation, render, script, fpmath, script_ui]

const
  SDL_MAJOR_VERSION* = 2
  SDL_MINOR_VERSION* = 0
  SDL_PATCHLEVEL* = 10

type
  Foo* = object
    style: nk_style_window

var
  quit = false
  prevTickEvents: seq[sdl.Event]

template sdlVersion*(x: untyped) =
  (x).major = SDL_MAJOR_VERSION
  (x).minor = SDL_MINOR_VERSION
  (x).patch = SDL_PATCHLEVEL

when defined(windows):
  type
    SysWMMsgWinObj* = object
      window*: pointer

    SysWMInfoKindObj* = object
      win*: SysWMMsgWinObj
elif defined(macosx):
  type
    SysWMinfoCocoaObj = object
      window: pointer

    SysWMinfoKindObj = object
      cocoa: SysWMinfoCocoaObj

var
  window: sdl.WindowPtr

proc newWindow*(): Window =
  result

proc onUserQuit(user: pointer, event: pointer) =
  quit = true

proc processSDLEvents() =
  prevTickEvents.setLen(0)
  var event = sdl.default_event

  while sdl.pollEvent(event):
    prevTickEvents.add(event)
    globalNotify(EventKind(event.kind), addr prevTickEvents[len(
      prevTickEvents) - 1], esEngine)
    case event.kind
    of sdl.KeyDown:
      case event.key.keysym.scancode
      of SDL_SCANCODE_ESCAPE:
        quit = true
      else:
        discard
    of sdl.UserEvent:
      echo event.user.code
    else:
      discard

proc linkSDL2BGFX() =
  var pd: bgfx_platform_data_t
  var info: sdl.WMinfo
  sdlVersion(info.version)
  assert sdl.getWMInfo(window, info)

  case(info.subsystem):
    of SysWM_Windows:
      when defined(windows):
        let info = cast[ptr SysWMInfoKindObj](addr info.padding[0])
        pd.nwh = cast[pointer](info.win.window)
      pd.ndt = nil
    of SysWM_Cocoa:
      when defined(macosx):
        let info = cast[ptr SysWMinfoKindObj](addr info.padding[0])
        pd.nwh = info.cocoa.window
      pd.ndt = nil
    else:
      discard

  pd.backBuffer = nil
  pd.backBufferDS = nil
  pd.context = nil
  bgfx_set_platform_data(addr pd)

proc init(): bool =
  prevTickEvents = @[]

  if sdl.init(sdl.INIT_VIDEO or sdl.INIT_TIMER) < sdl.SdlSuccess:
    stderr.writeLine("Failed to initialize SDL: $1\n" % $sdl.getError())
    return false

  window = sdl.createWindow(
    "Zeal",
    sdl.SDL_WINDOWPOS_UNDEFINED,
    sdl.SDL_WINDOWPOS_UNDEFINED,
    1280,
    720,
    SDL_WINDOW_SHOWN or SDL_WINDOW_RESIZABLE
  )

  linkSDL2BGFX()

  var bgfxInit: bgfx_init_t
  bgfx_init_ctor(addr bgfxInit)
  if not bgfx_init(addr bgfxInit):
    stderr.writeLine("Failed to initialize BGFX")
    return false


  render.init(".")
  event.init()

  event.globalRegister(EventKind(sdl.QuitEvent), onUserQuit, nil, int32(
      ssRunning) or int32(ssPausedUiRunning) or int32(ssPausedFull))

  game.init()

  result = true

proc shutdown() =
  echo "shutting down"
  game.shutdown()
  render.shutdown()
  sdl.destroyWindow(window)
  sdl.quit()

proc run*() =
  var
    deltaTime, accumulator = 0.0'f64
    lastFrameTime = float64(sdl.getPerformanceCounter())
    ret = QUIT_SUCCESS

  if not init():
    ret = QUIT_FAILURE
    quit(ret)

  let
    physDeltaTime = 1.0 / 60.0
    slowestFrame = 1.0 / 15.0

  try:
    newGame("assets/maps", "demo.zmap")
    while not quit:
      var currentFrameTime = float64(sdl.getPerformanceCounter())
      deltaTime = float64(currentFrameTime - lastFrameTime) / float64(
          sdl.getPerformanceFrequency())
      lastFrameTime = currentFrameTime

      if deltaTime > slowestFrame:
        deltaTime = slowestFrame

      accumulator += deltaTime
      while accumulator >= physDeltaTime:
        processSDLEvents()
        event.serviceQueue()
        # game.update()
        accumulator -= physDeltaTime
      render()
  except:
    echo getCurrentExceptionMsg()
  finally:
    # L.close()
    shutdown()

  quit(ret)

when isMainModule:
  run()
