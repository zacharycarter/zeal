import nuklear_sdl_bgfx as nkSDL

type
  Rect* = object
    x*, y*, w*, h*: int


proc init*(w: WindowPtr): ptr nk_context =
  result = nkSDL.init(w)

proc shutdown*() =
  nkSDL.shutdown()