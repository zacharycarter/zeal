import  engine_types, renderer

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

proc newShadowmapPass*(gfx: var GfxCtx, shadowStep: ShadowStep): ShadowmapPass =
  result = newRenderPass[ShadowmapPass](gfx, "shadowmap", rpkShadowmap)
  result.shadowStep = shadowStep