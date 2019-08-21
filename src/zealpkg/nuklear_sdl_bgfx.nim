import sdl2 as sdl, ../../lib/nuklear
export sdl, nuklear

type
  NkSDL = object
    win: WindowPtr
    ctx: nk_context
    atlas: nk_font_atlas

var nkSDL: NkSDL

proc init*(w: sdl.WindowPtr): ptr nk_context =
  nkSDL.win = w
  assert nk_init_default(addr nkSDL.ctx, nil) != 0
  result = addr nkSDL.ctx

proc shutdown*() =
  nk_free(addr nkSDL.ctx)