import sdl2

type
  AppUpdateProc* = (proc(window: sdl2.WindowPtr))

var 
  window: sdl2.WindowPtr
  appUpdateProc: AppUpdateProc

proc init*(width, height: int) =
  sdl2.init(INIT_TIMER or INIT_VIDEO)

  window = createWindow("zeal", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, width.cint, height.cint, SDL_WINDOW_SHOWN)

  if window.isNil:
    quit(QUIT_FAILURE)

proc beginFrame(): bool =
  true

proc endFrame() =
  discard

proc update(): bool =
  result = beginFrame()
  if appUpdateProc != nil:
    appUpdateProc(window)
  endFrame()
  
proc run*(updateApp: AppUpdateProc) =
  appUpdateProc = updateApp

  while update():
    discard

proc shutdown*() =
  window.destroyWindow()
  sdl2.quit()