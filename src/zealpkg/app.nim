import gfx

type
  App* = object
    updateFunc: UpdateFunc
    gfx*: GfxSystem

  UpdateFunc = (proc(a: App))

proc run*(a: var App, updateFunc: UpdateFunc) =
  a.updateFunc = updateFunc

proc newApp*(): App =
  result