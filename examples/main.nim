import sdl2, zeal

proc appUpdate(window: sdl2.WindowPtr) =
  discard

zeal.init(960, 540)
zeal.run(appUpdate)
zeal.shutdown()