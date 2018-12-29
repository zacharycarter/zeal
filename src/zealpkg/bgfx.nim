import  engine_types,
        bgfxdotnim, bgfxdotnim / platform

when defined(posix):
  import posix

  proc gettimeofday(tp: var Timeval, unused: pointer = nil) {.
    importc: "gettimeofday", header: "<sys/time.h>".}

proc getHPCounter(): int64 =
  when defined posix:
    var now: Timeval
    gettimeofday(now)
    result = now.tv_sec.int64 * 1000000'i64 + now.tv_usec

proc getFrequency(): int64 =
  when defined posix:
    result = 1000000'i64

const frequency = 1000000'u64

type
  GfxSystemState* = object
    initialized*: bool
    frame*: uint32
    startCounter*: int64
    deltaTime*, frameTime*, lastTime*: float

var
  state: GfxSystemState
  platformData: ptr bgfx_platform_data_t

proc init*(pd: PlatformData, w, h: int): bool =
  platformData = createShared(bgfx_platform_data_t, sizeof(
      bgfx_platform_data_t))
  platformData.nwh = pd.nativeWindowHandle
  platformData.ndt = pd.nativeDisplayType
  platformData.backBuffer = nil
  platformData.backBufferDS = nil
  platformData.context = nil

  bgfx_set_platform_data(platformData)

  var init: bgfx_init_t
  init.resolution.width = w.uint32
  init.resolution.height = h.uint32
  init.resolution.reset = BGFX_RESET_NONE
  bgfx_init_ctor(addr init)

  if not bgfx_init(addr init):
    echo "error initializng BGFX"
    return false

  when defined debug:
    bgfx_set_debug(BGFX_DEBUG_TEXT or BGFX_DEBUG_PROFILER)

  bgfx_set_view_rect(0, 0, 0, w.uint16, h.uint16)
  bgfx_set_view_clear(0, 
    BGFX_CLEAR_COLOR or BGFX_CLEAR_DEPTH, 
    0x303030ff, 
    1.0f, 
    0,
  )

  state.startCounter = getHpCounter()
  state.initialized = true
  result = true

proc advance() =
  let time = (getHpCounter() - state.startCounter).float / getFrequency().float
  state.frameTime = time - state.lastTime
  state.lastTime = time
  state.deltaTime = state.frameTime

proc nextFrame*(): bool = 
  state.frame = bgfx_frame(false)
  advance()
  result = true

proc shutdown*() =
  bgfx_shutdown()
  freeShared(platformData)