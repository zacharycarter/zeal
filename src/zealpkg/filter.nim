import  engine_types, math, primitive, mesh, render_target,
        bgfxdotnim

type
  FilterStep = ref object of PipelineStep
    quadProgram: Program
  
  RenderQuad = object
    source: Vec4
    dest: Vec4
    fboFlip: bool

proc decl(): var bgfx_vertex_decl_t =
  var d {.global.} = vertexDecl(VERTEX_ATTRIBUTE_POSITION or VERTEX_ATTRIBUTE_COLOR or VERTEX_ATTRIBUTE_TEXCOORD0)
  result = d

proc newRenderQuad(crop: Vec4, dest: Vec4, fboFlip: bool = false): RenderQuad =
  result.source = crop
  result.dest = dest
  result.fboFlip = fboFlip

proc newFilterStep*(gfx: var GfxCtx): FilterStep =
  result = newPipelineStep[FilterStep]()
  result.quadProgram = gfx.newProgram("filter/quad")
  result.shaderBlock.options = @[
    "UNPACK_DEPTH",
    "SOURCE_DEPTH",
    "SOURCE_0_CUBE",
    "SOURCE_0_ARRAY",
    "FILTER_DEBUG_UV"
  ]

proc drawQuad(size: Vec2, fboFlip: bool) =
  if 3'u32 == bgfx_get_avail_transient_vertex_buffer(3, addr decl()):
    discard

proc drawUnitQuad(fboFlip: bool) =
  drawQuad(newVec2(1.0, 1.0), fboFlip)

proc submitQuad(fs: FilterStep, target: var FrameBuffer, view: int, fbo: bgfx_frame_buffer_handle_t, program: bgfx_program_handle_t, quad: RenderQuad, flags: int, render: bool) =
  if quad.source[2] > 1.0 or quad.source[3] > 1.0:
    echo "WARNING: Source rect expected in relative coordinates"
  
  bgfx_set_view_frame_buffer(bgfx_view_id_t(view), fbo)
  bgfx_set_view_transform(bgfx_view_id_t(view), addr target.screenView[0], addr target.screenProj[0])
  bgfx_set_view_rect(bgfx_view_id_t(view), quad.dest[0].uint16, quad.dest[1].uint16, quad.dest[2].uint16, quad.dest[3].uint16)

  drawUnitQuad(quad.fboFlip)