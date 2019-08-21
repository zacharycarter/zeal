import ../../lib/nuklear, ui

type
  Window* = object
    name: string
    rect: Rect
    flags: int32
    style: nk_style_window
    resizeMask: int
    virtRes: nk_vec_2i

var 
  nkCtx: ptr nk_context

proc init*(ctx: ptr nk_context) =
  nkCtx = ctx