import  engine_types

proc newDepthStep*(gfx: var GfxCtx): DepthStep =
  result = newDrawStep[DepthStep]()