import  engine_types, math, primitive, mesh, program, render_target,
        bgfxdotnim

type  
  RenderQuad = object
    source: Vec4
    dest: Vec4
    fboFlip: bool

  ScreenQuadVertex = object
    pos: Vec3
    rgba: uint32
    texcoord: Vec2

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
  var options {.global.} = @[
    "UNPACK_DEPTH",
    "SOURCE_DEPTH",
    "SOURCE_0_CUBE",
    "SOURCE_0_ARRAY",
    "FILTER_DEBUG_UV"
  ]
  result.shaderStep.options = options

proc drawQuad(size: Vec2, fboFlip: bool) =
  if 3'u32 == bgfx_get_avail_transient_vertex_buffer(3, addr decl()):
    var vertexBuffer: bgfx_transient_vertex_buffer_t
    bgfx_alloc_transient_vertex_buffer(addr vertexBuffer, 3, addr decl())

    let zz = -1.0

    let min = [-size[0], 0.0]
    let max = [size[0], size[1] * 2.0]

    var minUV = [-1.0'f32, 0.0]
    var maxUV = [1.0'f32, 2.0]

    if fboFlip and bgfx_get_caps().originBottomLeft:
      minUV = [-1.0'f32, 1.0]
      maxUV = [1.0'f32, -1.0]
    
    var vertex = cast[CArray[ScreenQuadVertex]](vertexBuffer.data)
    vertex[0] = ScreenQuadVertex(pos: [min[0], min[1], zz], rgba: 0xffffffff'u32, texcoord: [minUV[0], minUV[1]])
    vertex[1] = ScreenQuadVertex(pos: [max[0], max[1], zz], rgba: 0xffffffff'u32, texcoord: [maxUV[0], maxUV[1]])
    vertex[2] = ScreenQuadVertex(pos: [max[0], min[1], zz], rgba: 0xffffffff'u32, texcoord: [maxUV[0], minUV[1]])

    bgfx_set_transient_vertex_buffer(0, addr vertexBuffer, 0, 3)

proc drawUnitQuad(fboFlip: bool) =
  drawQuad([1.0'f32, 1.0'f32], fboFlip)

proc submitQuad(fs: FilterStep, target: var FrameBuffer, view: int, fbo: bgfx_frame_buffer_handle_t, program: bgfx_program_handle_t, quad: var RenderQuad, flags: uint64, render: bool) =
  if quad.source[2] > 1.0 or quad.source[3] > 1.0:
    echo "WARNING: Source rect expected in relative coordinates"
  
  bgfx_set_view_frame_buffer(bgfx_view_id_t(view), fbo)
  bgfx_set_view_transform(bgfx_view_id_t(view), addr target.screenView[0], addr target.screenProj[0])
  bgfx_set_view_rect(bgfx_view_id_t(view), quad.dest[0].uint16, quad.dest[1].uint16, quad.dest[2].uint16, quad.dest[3].uint16)

  drawUnitQuad(quad.fboFlip)

  bgfx_set_uniform(fs.uniform.sourceCrop, addr quad.source, 1)

  bgfx_set_state(BGFX_STATE_WRITE_RGB or BGFX_STATE_WRITE_A or BGFX_STATE_CULL_CW or flags, 0)
  bgfx_submit(bgfx_view_id_t(view), program, 0, false)

  if render:
    discard bgfx_frame(false)

proc submitQuad(fs: FilterStep, target: var FrameBuffer, view: int, fbo: bgfx_frame_buffer_handle_t, program: bgfx_program_handle_t, rect: var Vec4, flags: uint64, render: bool) =
  var renderQuad = newRenderQuad(target.sourceQuad(rect), target.destQuad(rect), true)
  fs.submitQuad(target, view, fbo, program, renderQuad, flags, render)

proc submitQuad(fs: FilterStep, target: var FrameBuffer, view: int, program: bgfx_program_handle_t, renderQuad: var RenderQuad, flags: uint64, render: bool) =
  fs.submitQuad(target, view, target.fbo, program, renderQuad, flags, render) # BGFX_INVALID_HANDLE

proc submitQuad(fs: FilterStep, target: var FrameBuffer, view: int, program: bgfx_program_handle_t, rect: var Vec4, flags: uint64, render: bool) =
  var renderQuad = newRenderQuad(target.sourceQuad(rect), target.destQuad(rect), true)
  fs.submitQuad(target, view, program, renderQuad, flags, render)

proc submitQuad(fs: FilterStep, target: var FrameBuffer, view: int, program: bgfx_program_handle_t, flags: uint64, render: bool) =
  var rect = vec4(vec2(0.0), target.size)
  var renderQuad = newRenderQuad(target.sourceQuad(rect), target.destQuad(rect), true)
  fs.submitQuad(target, view, program, renderQuad, flags, render)

proc newCopyStep*(gfx: var GfxCtx, filter: FilterStep): CopyStep =
  result = newPipelineStep[CopyStep]()
  result.filter = filter
  result.program = newProgram("filter/copy")
  result.program.registerStep(PipelineStep(filter))