import  engine_types, program

proc newRadianceStep*(gfx: var GfxCtx, filter: var FilterStep, copy: var CopyStep): RadianceStep =
  result = newDrawStep[RadianceStep]()
  result.filter = filter
  result.copy = copy
  result.prefilterProgram = newProgram("filter/prefilter_envmap")
  
  let 
    options {.global.} = @["RADIANCE_ENVMAP", "RADIANCE_ARRAY"]
  result.shaderStep.options = options