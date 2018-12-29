import  sequtils, tables,
        engine_types, bgfx, pipeline, program

const RENDER_PASS_ID = 100

# const ZEAL_GFX_STATE_DEFAULT = 0 or 
#         BGFX_STATE_WRITE_RGB or 
#         BGFX_STATE_WRITE_A or 
#         BGFX_STATE_DEPTH_TEST_LEQUAL or 
#         BGFX_STATE_WRITE_Z or
#         BGFX_STATE_CULL_CW or
#         BGFX_STATE_MSAA

# const ZEAL_GFX_STATE_DEFAULT_ALPHA = 0 or 
#               BGFX_STATE_WRITE_RGB or 
#               BGFX_STATE_WRITE_A or 
#               BGFX_STATE_DEPTH_TEST_LESS or 
#               BGFX_STATE_MSAA or
#               BGFX_STATE_BLEND_ALPHA.int64

var
  width, height: int
  gfxPipeline: Pipeline
  programs: Table[string, Program]
  state: GfxSystemState

proc init*(pd: PlatformData, w, h: int): bool =
  width = w
  height = h
  
  result = bgfx.init(pd, w, h)

  return true

proc newFrame(frame: uint32, time: float, deltaTime: float, renderPass: int): RenderFrame = 
  result = (frame: state.frame, time: state.lastTime, deltaTime: state.deltaTime, renderPass: RENDER_PASS_ID, numDrawCalls: 0, numVertices: 0, numTriangles: 0)

proc beginFrame*() =
  let frame = newFrame(state.frame, state.lastTime, state.deltaTime, RENDER_PASS_ID)

  for _, program in programs:
    program.updateVersions()

  for step in gfxPipeline.steps:
    step.beginFrame(frame)

proc nextFrame*(): bool =
  # bgfx_set_view_rect(0, 0, 0, width.uint16, height.uint16)

  # bgfx_touch(0)

  # bgfx_dbg_text_clear(0, false)

  # bgfx_dbg_text_printf(0, 1, 0x4f, "Red vs Blue")

  # discard bgfx_frame(false)
  bgfx.nextFrame()

proc shutdown*() =
  bgfx.shutdown()