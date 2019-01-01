import  engine_types, renderer

proc newGITraceStep*(gfx: var GfxCtx): GITraceStep =
  result = newDrawStep[GITraceStep]()

  let options {.global.} = @["GI_CONETRACE"]
  result.shaderStep.options = options

proc newGIBakeStep*(gfx: var GfxCtx, lightStep: LightStep, giTraceStep: GITraceStep): GIBakeStep =
  result = newDrawStep[GIBakeStep]()
  result.lightStep = lightStep
  result.giTraceStep = giTraceStep

proc newGIProbesPass*(gfx: var GfxCtx, lightStep: LightStep, giBakeStep: GIBakeStep): GIProbesPass =
  result = newRenderPass[GIProbesPass](gfx, "voxelGI", rpkVoxelGI)