import  engine_types, program

proc newTonemapStep*(gfx: var GfxCtx, filterStep: FilterStep, copyStep: CopyStep): TonemapStep =
  result = newPipelineStep[TonemapStep]()
  result.filterStep = filterStep
  result.copyStep = copyStep
  result.program = gfx.newProgram("filter/tonemap")

  let options {.global.} = @[
    "ADJUST_BCS",
    "COLOR_CORRECTION",
  ]

  let modes {.global.} = @[
    "TONEMAP_MODE",
  ]

  result.shaderStep.options = options
  result.shaderStep.modes = modes

  result.program.registerStep(result)