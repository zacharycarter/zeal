import  engine_types, program,
        bgfxdotnim

type
  ShaderOptionBlur = enum
    sobGaussianHorizontal, sobGaussianVertical
  
  BlurKernel = object
    horizontal: array[7, float]
    vertical: array[5, float]

proc newBlurStep*(gfx: var GfxCtx, filter: var FilterStep): BlurStep =
  result = newPipelineStep[BlurStep]()
  result.filter = filter
  result.program = newProgram("filter/gaussian_blur")

  var 
    options {.global.} = @["GAUSSIAN_HORIZONTAL", "GAUSSIAN_VERTICAL"]
  result.shaderBlock.options = options
  result.program.registerStep(PipelineStep(result))