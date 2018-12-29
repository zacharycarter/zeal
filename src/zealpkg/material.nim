import  engine_types, pipeline

type
  PbrPipelineStep = ref object of PipelineStep

proc newPbrPipelineStep*(): PbrPipelineStep =
  result = newPipelineStep[PbrPipelineStep]()
  result.shaderBlock.options = @[
    "NORMAL_MAP",
    "EMISSIVE",
    "ANISOTROPY",
    "AMBIENT_OCCLUSION",
    "DEPTH_MAPPING",
    "DEEP_PARALLAX",
    "LIGHTMAP"
  ]