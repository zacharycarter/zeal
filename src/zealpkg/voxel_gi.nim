import  engine_types

proc newGITraceStep*(gfx: var GfxCtx): GITraceStep =
  result = GITraceStep(newDrawStep[GITraceStep]())

  let options {.global.} = @["GI_CONETRACE"]
  result.shaderStep.options = options

proc newGIBakeStep*(gfx: var GfxCtx, lightStep: var LightStep, giTraceStep: var GITraceStep): GIBakeStep =
  result = GIBakeStep(newDrawStep[GIBakeStep]())
  result.lightStep = lightStep
  result.giTraceStep = giTraceStep