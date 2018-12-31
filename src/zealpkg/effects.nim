import  engine_types

proc newResolveStep*(gfx: var GfxCtx, copyStep: CopyStep): ResolveStep =
  result = newPipelineStep[ResolveStep]()
  result.copyStep = copyStep