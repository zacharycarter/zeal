import  engine_types

proc newLightmapStep*(gfx: var GfxCtx, lightStep: LightStep, giBakeStep: GIBakeStep): LightmapStep =
  result = newDrawStep[LightmapStep]()
  result.lightStep = lightStep
  result.giBakeStep = giBakeStep