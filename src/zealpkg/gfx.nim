import  sequtils, tables,
        engine_types, bgfx, pipeline, program

const RENDER_PASS_ID = 100

proc init*(gfx: var GfxCtx, pd: PlatformData, rps: openArray[string], pk: PipelineKind, w, h: int): bool =
  gfx.width = w
  gfx.height = h
  gfx.resourcePaths = @[ZEAL_DATA_DIR]
  gfx.resourcePaths.add(rps)
  gfx.pipeline.steps = @[]
  gfx.programs = initTable[string, Program]()
  
  result = bgfx.init(pd, w, h)

  if pk == pkPbr:
    pbr(gfx)

  return true

proc newFrame(frame: uint32, time: float, deltaTime: float, renderPass: int): RenderFrame = 
  result = (frame: frame, time: time, deltaTime: deltaTime, renderPass: RENDER_PASS_ID, numDrawCalls: 0, numVertices: 0, numTriangles: 0)

proc beginFrame*(gfx: var GfxCtx) =
  let frame = newFrame(gfx.state.frame, gfx.state.lastTime, gfx.state.deltaTime, RENDER_PASS_ID)

  for _, program in gfx.programs:
    gfx.updateVersions(program)

  for step in gfx.pipeline.steps:
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