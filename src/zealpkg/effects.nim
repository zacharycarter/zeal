import  engine_types

proc newResolveStep*(gfx: var GfxCtx, copyStep: var CopyStep): ResolveStep =
  result = newPipelineStep[ResolveStep]()
  result.copyStep = copyStep