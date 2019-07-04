import sdl2 as sdl, shader

proc init*(basePath: string) =
  var displayMode: sdl.DisplayMode
  discard sdl.getDesktopDisplayMode(0, displayMode)

  shader.init(basePath)