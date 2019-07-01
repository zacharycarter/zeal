import sdl2, gfx

type
  AppUpdateProc* = (proc(window: sdl2.WindowPtr))

var window: sdl2.WindowPtr

proc init*(width, height: int):bool =
  result = false

  if not sdl2.init(sdl2.InitVideo):
    echo "ERROR: SDL initialization failed: ", sdl2.getError()
    return result

  window = sdl2.createWindow("".cstring,  SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, width.cint, height.cint, SDL_WINDOW_SHOWN)

  if window == nil:
    echo "ERROR: Failed creating SDL window: %s", sdl2.getError()
    return result

  echo "INFO: SDL initialized"

  result = gfx.init(window, width, height)

  gfx.minimalPipeline().init()

proc run*(appUpdateProc: AppUpdateProc) =
  var event {.global.}: sdl2.Event = sdl2.defaultEvent
  while true:
    if(sdl2.pollEvent(event)):
      if event.kind == sdl2.QuitEvent:
        break

proc shutdown*() =
  gfx.shutdown()
  window.destroyWindow()
  echo "INFO: SDL shutdown complete"
  sdl2.quit()
