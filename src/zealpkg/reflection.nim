import  engine_types

proc newReflectionAtlas*(size: int, subdiv: int): ReflectionAtlas =
  result.size = size
  result.subdiv = subdiv

proc newReflectionStep*(gfx: var GfxCtx): ReflectionStep =
  result = newDrawStep[ReflectionStep]()
  result.atlas = newReflectionAtlas(1024, 16)