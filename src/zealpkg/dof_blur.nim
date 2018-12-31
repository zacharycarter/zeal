import  engine_types, program

proc newDOFBlurStep*(gfx: var GfxCtx, filterStep: FilterStep): DOFBlurStep =
  result = newPipelineStep[DOFBlurStep]()
  result.filterStep = filterStep
  result.program = gfx.newProgram("filter/dof_blur")

  let options {.global.} = @["DOF_FIRST_PASS"]
  result.shaderStep.options = options
  result.program.registerStep(result)