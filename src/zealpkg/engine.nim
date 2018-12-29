import  engine_types, gfx

proc init*(pd: PlatformData, width: int = 1280, height: int = 720): bool =
  result = gfx.init(pd, width, height)

proc shutdown*() =
  gfx.shutdown()

proc update*(): bool =
  gfx.beginFrame()
  result = gfx.nextFrame()