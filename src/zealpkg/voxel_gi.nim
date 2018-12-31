import  engine_types

proc newGITraceStep*(gfx: var GfxCtx): GITraceStep =
  result = GITraceStep(newDrawStep[GITraceStep]())

  let options {.global.} = @["GI_CONETRACE"]
  result.shaderStep.options = options