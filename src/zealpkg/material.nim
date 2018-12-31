import  engine_types, pipeline

type
  PbrPipelineStep = ref object of PipelineStep

proc newPbrPipelineStep*(): PbrPipelineStep =
  result = newPipelineStep[PbrPipelineStep]()
  let 
    options {.global.} = @[
      "NORMAL_MAP",
      "EMISSIVE",
      "ANISOTROPY",
      "AMBIENT_OCCLUSION",
      "DEPTH_MAPPING",
      "DEEP_PARALLAX",
      "LIGHTMAP"
    ]
  result.shaderStep.options = options