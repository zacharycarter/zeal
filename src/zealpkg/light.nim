import  strutils,
        engine_types

proc newLightStep*(gfx: var GfxCtx, shadowStep: ShadowStep): LightStep =
  result = newDrawStep[LightStep]()
  result.shadowStep = shadowStep

  let options {.global.} = @[
    "FOG", "DIRECT_LIGHT"
  ]

  result.shaderStep.options = options

  let sMaxLights {.global.} = intToStr(MAX_LIGHTS)
  let sMaxShadows {.global.} = intToStr(MAX_SHADOWS)
  let sMaxDirLights {.global.} = intToStr(MAX_DIRECT_LIGHTS)

  let defines {.global.} = @[
    ShaderDefine(name: "MAX_LIGHTS", value: sMaxLights),
    ShaderDefine(name: "MAX_SHADOWS", value: sMaxShadows),
    ShaderDefine(name: "MAX_DIRECT_LIGHTS", value: sMaxDirLights)
  ]

  result.shaderStep.defines = defines