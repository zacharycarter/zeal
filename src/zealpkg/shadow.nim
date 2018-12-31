import  engine_types

proc newShadowStep*(gfx: var GfxCtx, depthStep: DepthStep): ShadowStep =
  result = newDrawStep[ShadowStep]()
  result.depthStep = depthStep

  let options {.global.} = @[
    "CSM_SHADOW"
  ]

  let modes {.global.} = @[
    "CSM_NUM_CASCADES", "CSM_PCF_LEVEL"
  ]

  result.shaderStep.options = options
  result.shaderStep.modes = modes