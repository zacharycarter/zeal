import  os,
        engine_types, gfx

var 
  gfxCtx: GfxCtx

proc init*(pd: PlatformData, width: int = 1280, height: int = 720, rps: openArray[string] = [], pk: PipelineKind = pkPbr): bool =
  result = gfxCtx.init(pd, rps, pk, width, height)

proc shutdown*() =
  gfx.shutdown()

proc update*(): bool =
  gfxCtx.beginFrame()
  result = gfx.nextFrame()