import  engine_types

proc newLightmapStep*(gfx: var GfxCtx, lightStep: var LightStep, giBakeStep: var GIBakeStep): LightmapStep =
  result = newDrawStep[LightmapStep]()
  result.lightStep = lightStep
  result.giBakeStep = giBakeStep