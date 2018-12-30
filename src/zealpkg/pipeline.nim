import  engine_types, program,
        bgfxdotnim

const ZEAL_GFX_STATE_DEFAULT = 0 or 
        BGFX_STATE_WRITE_RGB or 
        BGFX_STATE_WRITE_A or 
        BGFX_STATE_DEPTH_TEST_LEQUAL or 
        BGFX_STATE_WRITE_Z or
        BGFX_STATE_CULL_CW or
        BGFX_STATE_MSAA

const ZEAL_GFX_STATE_DEFAULT_ALPHA = 0 or 
              BGFX_STATE_WRITE_RGB or 
              BGFX_STATE_WRITE_A or 
              BGFX_STATE_DEPTH_TEST_LESS or 
              BGFX_STATE_MSAA or
              BGFX_STATE_BLEND_ALPHA.int64

type
  FilterStep = ref object of PipelineStep
    quadProgram: Program

proc newFilterStep(gfx: var GfxCtx): FilterStep =
  result = newPipelineStep[FilterStep]()
  result.quadProgram = gfx.newProgram("filter/quad")
  result.shaderBlock.options = @[
    "UNPACK_DEPTH",
    "SOURCE_DEPTH",
    "SOURCE_0_CUBE",
    "SOURCE_0_ARRAY",
    "FILTER_DEBUG_UV"
  ]

proc beginFrame*[T](s: T, frame: RenderFrame) =
  discard frame

proc addStep(p: var Pipeline, s: PipelineStep): PipelineStep =
  p.steps.add(s)
  result = s

proc pbr*(gfx: var GfxCtx) =
  let filter = gfx.pipeline.addStep(newFilterStep(gfx))
