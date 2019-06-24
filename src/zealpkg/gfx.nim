import sdl2, bgfxdotnim, bgfxdotnim / [platform], strutils

const
  SDL_MAJOR_VERSION* = 2
  SDL_MINOR_VERSION* = 0
  SDL_PATCHLEVEL* = 5

{.this:self.}

type
  PipelineStep = ref object {.inheritable.}
  
  MaterialStep = ref object of PipelineStep

  FilterStep = ref object of PipelineStep
    options: seq[string]
  
  Pipeline = seq[PipelineStep]

var
  pipeline: Pipeline = @[]

template sdlVersion*(x: untyped) =
  (x).major = SDL_MAJOR_VERSION
  (x).minor = SDL_MINOR_VERSION
  (x).patch = SDL_PATCHLEVEL

when defined(windows):
  type
    SysWMMsgWinObj* = object  ##  when defined(SDL_VIDEO_DRIVER_WINDOWS)
      window*: pointer

    SysWMInfoKindObj* = object ##  when defined(SDL_VIDEO_DRIVER_WINDOWS)
      win*: SysWMMsgWinObj 

proc linkSDL2BGFX(window: sdl2.WindowPtr) =
  var pd: ptr bgfx_platform_data_t = createShared(bgfx_platform_data_t) 
  var info: sdl2.WMinfo
  sdlVersion(info.version)
  assert sdl2.getWMInfo(window, info)
  echo  "INFO: SDL version - $1.$2.$3 - Subsystem: $4".format(info.version.major.int, info.version.minor.int, info.version.patch.int, 
  info.subsystem)
  
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

proc init*(window: sdl2.WindowPtr, width, height: int): bool =
  result = false

  linkSDL2BGFX(window)

  var bgfxInit: bgfx_init_t
  bgfx_init_ctor(addr bgfxInit)

  if not bgfx_init(addr bgfxInit):
    echo "ERROR: BGFX initialization failed"
    return result

  bgfx_set_debug(BGFX_DEBUG_TEXT)

  bgfx_reset(uint32 width, uint32 height, BGFX_RESET_NONE, BGFX_TEXTURE_FORMAT_COUNT)

  bgfx_set_view_rect(0, 0, 0, uint16 width, uint16 height)

  echo "INFO: BGFX initialized"

  result = true

proc init(self: MaterialStep) =
  discard

proc initMinimalPipeline*() =
  pipeline = @[]
  pipeline.add(new MaterialStep)

proc shutdown*() =
  bgfx_shutdown()