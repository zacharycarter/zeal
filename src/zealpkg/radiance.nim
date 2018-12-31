import  engine_types

proc newRadianceStep*(gfx: var GfxCtx, filter: FilterStep, copy: CopyStep): RadianceStep =
  result = newDrawStep[RadianceStep]()
  result.filter = filter
  result.copy = copy
  result.prefilterProgram = gfx.newProgram("filter/prefilter_envmap")
  
  let 
    options {.global.} = @["RADIANCE_ENVMAP", "RADIANCE_ARRAY"]
  result.shaderStep.options = options