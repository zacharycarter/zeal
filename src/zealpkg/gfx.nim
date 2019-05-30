import sdl2, bgfxdotnim, bgfxdotnim / [platform], strutils

const
  SDL_MAJOR_VERSION* = 2
  SDL_MINOR_VERSION* = 0
  SDL_PATCHLEVEL* = 5

template sdlVersion*(x: untyped) = ##  \
  ##  Template to determine SDL version program was compiled against.
  ##
  ##  This template fills in a Version object with the version of the
  ##  library you compiled against. This is determined by what header the
  ##  compiler uses. Note that if you dynamically linked the library, you might
  ##  have a slightly newer or older version at runtime. That version can be
  ##  determined with getVersion(), which, unlike version(),
  ##  is not a template.
  ##
  ##  ``x`` Version object to initialize.
  ##
  ##  See also:
  ##
  ##  ``Version``
  ##
  ##  ``getVersion``
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

proc init*(window: sdl2.WindowPtr, width, height: int): bool =
  result = false

  linkSDL2BGFX(window)

  var init: bgfx_init_t
  bgfx_init_ctor(addr init)

  if not bgfx_init(addr init):
    echo "ERROR: BGFX initialization failed"
    return result

  bgfx_set_debug(BGFX_DEBUG_TEXT)

  bgfx_reset(uint32 width, uint32 height, BGFX_RESET_NONE, BGFX_TEXTURE_FORMAT_COUNT)

  bgfx_set_view_rect(0, 0, 0, uint16 width, uint16 height)

  echo "INFO: BGFX initialized"

  result = true

proc shutdown*() =
  bgfx_shutdown()