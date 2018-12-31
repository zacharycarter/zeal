import  engine_types, program

proc newGlowStep*(gfx: var GfxCtx, filterStep: FilterStep, copyStep: CopyStep, blurStep: BlurStep): GlowStep =
  result = newPipelineStep[GlowStep]()
  result.filterStep = filterStep
  result.copyStep = copyStep
  result.blurStep = blurStep
  result.bleedProgram = gfx.newProgram("filter/glow_bleed")
  result.mergeProgram = gfx.newProgram("filter/glow")