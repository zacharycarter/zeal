import sdl2 as sdl, bgfxdotnim, bgfxdotnim/platform, strutils

const
  SDL_MAJOR_VERSION* = 2
  SDL_MINOR_VERSION* = 0
  SDL_PATCHLEVEL* = 5

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

var 
  quit = false
  window: sdl.WindowPtr

proc linkSDL2BGFX() =
  var pd: ptr bgfx_platform_data_t = createShared(bgfx_platform_data_t) 
  var info: sdl.WMinfo
  sdlVersion(info.version)
  assert sdl.getWMInfo(window, info)
  
  case(info.subsystem):
    of SysWM_Windows:
      when defined(windows):
        let info = cast[ptr SysWMInfoKindObj](addr info.padding[0])
        pd.nwh = cast[pointer](info.win.window)
      pd.ndt = nil
    else:
      discard

  pd.backBuffer = nil
  pd.backBufferDS = nil
  pd.context = nil
  bgfx_set_platform_data(pd)
  freeShared(pd)

proc engineInit(): bool =
  if sdl.init(sdl.INIT_VIDEO or sdl.INIT_TIMER) < sdl.SdlSuccess:
    stderr.writeLine("Failed to initialize SDL: $1\n" % $sdl.getError())
    return false
  
  window = sdl.createWindow(
    "Zeal",
    sdl.SDL_WINDOWPOS_UNDEFINED,
    sdl.SDL_WINDOWPOS_UNDEFINED,
    960,
    540,
    SDL_WINDOW_SHOWN
  )

  linkSDL2BGFX()

  var bgfxInit: bgfx_init_t
  bgfx_init_ctor(addr bgfxInit)
  if not bgfx_init(addr bgfxInit):
    stderr.writeLine("Failed to initialize BGFX")
    return false

  bgfx_set_view_clear(0, BGFX_CLEAR_COLOR or BGFX_CLEAR_DEPTH, 0x303030ff, 1.0, 0)

  result = true

proc processSDLEvents() =
  var event = sdl.default_event

  while sdl.pollEvent(event):
    case event.kind
    of sdl.KeyDown:
      case event.key.keysym.scancode
      of SDL_SCANCODE_ESCAPE:
        quit = true
        break
      else:
        discard
      break
    else:
      discard

proc render() =
  discard

when is_main_module:
  var ret = QUIT_SUCCESS

  if not engineInit():
    ret = QUIT_FAILURE
    quit(ret)

  while not quit:
    processSDLEvents()
    render()