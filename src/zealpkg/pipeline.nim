import  engine_types, math, program, render_target, filter, blur,
        bgfxdotnim

const ZEAL_GFX_STATE_DEFAULT = 0'u64 or 
        BGFX_STATE_WRITE_RGB or 
        BGFX_STATE_WRITE_A or 
        BGFX_STATE_DEPTH_TEST_LEQUAL or 
        BGFX_STATE_WRITE_Z or
        BGFX_STATE_CULL_CW or
        BGFX_STATE_MSAA

const ZEAL_GFX_STATE_DEFAULT_ALPHA = 0'u64 or 
              BGFX_STATE_WRITE_RGB or 
              BGFX_STATE_WRITE_A or 
              BGFX_STATE_DEPTH_TEST_LESS or 
              BGFX_STATE_MSAA or
              BGFX_STATE_BLEND_ALPHA

proc beginFrame*[T](s: T, frame: RenderFrame) =
  discard frame

proc beginPass*(s: PipelineStep, r: var Render) =
  discard r

proc beginRender*(s: PipelineStep, r: var Render) =
  discard r

proc addStep[T](p: var Pipeline, s: T): T =
  p.steps.add(s)
  result = s

proc pbr*(gfx: var GfxCtx) =
  var filter = gfx.pipeline.addStep(newFilterStep(gfx))
  var copy = gfx.pipeline.addStep(newCopyStep(gfx, filter))
  var blur = gfx.pipeline.addStep(newBlurStep(gfx, filter))