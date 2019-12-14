import bgfxdotnim, sdl2 as sdl, shader, mesh, material, tables, texture, vertex, fpmath

template `+`*[T](p: ptr T, off: int): ptr T =
  cast[ptr type(p[])](cast[ByteAddress](p) +% off * sizeof(p[]))

const
  vertsPerSideFace* = 6
  vertsPerTopFace* = 24
  vertsPerTile* = 4 * vertsPerSideFace + vertsPerTopFace

  bottom = -1.0'f32
  top = 3.0'f32
  left = -1.0'f32
  right = 3.0'f32

  maxView = 199'u16

type
  RenderPass* = enum
    rpDepth,
    rpRegular

  RenderData* = object
    mesh*: Mesh
    numMaterials*: int
    materials*: Material
    shaderProgram*: bgfx_program_handle_t
    depthShaderProgram*: bgfx_program_handle_t

  MapRenderData* = object
    sTexColor*: bgfx_uniform_handle_t
    textures*: TextureArray

  PosVertex = object
    x, y, z: float32

var
  rendererType: bgfx_renderer_type_t
  rendererCaps*: ptr bgfx_caps_t

  uAmbientColor: bgfx_uniform_handle_t
  uEmitLightColor: bgfx_uniform_handle_t
  uEmitLightPos: bgfx_uniform_handle_t
  uViewPos: bgfx_uniform_handle_t

  frameBuffer: bgfx_frame_buffer_handle_t

  posVertexLayout: bgfx_vertex_layout_t

  blitSampler: bgfx_uniform_handle_t
  camPosUniform: bgfx_uniform_handle_t
  normalMatrixUniform: bgfx_uniform_handle_t
  exposureVecUniform: bgfx_uniform_handle_t
  tonemappingModeVecUniform: bgfx_uniform_handle_t

  blitTriangleBuffer: bgfx_vertex_buffer_handle_t

proc setAmbientLightColor*(val: var Vec3) =
  bgfx_set_uniform(uAmbientColor, addr val[0], 1)

proc setEmitLightColor*(val: var Vec3) =
  bgfx_set_uniform(uEmitLightColor, addr val[0], 1)

proc setEmitLightPos*(val: var Vec3) =
  bgfx_set_uniform(uEmitLightPos, addr val[0], 1)

proc setViewTransform*(view: var Mat4) =
  var proj: Mat4
  mtxProj(proj, 45.0'f32, 1280.0 / 720.0, 0.1, 1000.0,
      rendererCaps.homogeneousDepth)
  bgfx_set_view_transform(0, addr view[0], addr proj[0])

proc draw*(mapRenderData: MapRenderData, renderData: RenderData,
    model: var Mat4) =

  bgfx_set_view_rect(0, 0, 0, 1280'u16, 720'u16)

  bgfx_touch(0)

  discard bgfx_set_transform(addr model[0], 1)

  bgfx_set_vertex_buffer(0'u8, renderData.mesh.vBuffHandle, 0'u32, uint32(
      renderData.mesh.numVerts))

  bgfx_set_texture(0, mapRenderData.sTexColor, mapRenderData.textures.handle,
      high(uint32))

  bgfx_set_state(0'u64 or BGFX_STATE_WRITE_RGB or
    BGFX_STATE_WRITE_Z or
    BGFX_STATE_DEPTH_TEST_LESS or BGFX_STATE_CULL_CCW, 0)

  bgfx_submit(0, renderData.shaderProgram, 0, false)

proc fillVBuff*(renderData: var RenderData, vBuff: var seq[Vertex]) =
  var mem = bgfx_copy(cast[pointer](addr vbuff[0]), uint32(sizeof(Vertex) *
      renderData.mesh.numVerts))
  renderData.mesh.vBuffHandle = bgfx_create_vertex_buffer(mem,
      addr renderData.mesh.vLayout, BGFX_BUFFER_NONE)

proc initVBuff*(renderData: var RenderData, shader: string, vBuff: var seq[Vertex]) =
  bgfx_vertex_layout_begin(addr renderData.mesh.vLayout, rendererType)
  bgfx_vertex_layout_add(addr renderData.mesh.vLayout, BGFX_ATTRIB_POSITION, 3,
      BGFX_ATTRIB_TYPE_FLOAT, false, false)
  bgfx_vertex_layout_add(addr renderData.mesh.vLayout, BGFX_ATTRIB_TEXCOORD0, 2,
      BGFX_ATTRIB_TYPE_FLOAT, false, false)
  bgfx_vertex_layout_add(addr renderData.mesh.vLayout, BGFX_ATTRIB_NORMAL, 3,
      BGFX_ATTRIB_TYPE_FLOAT, false, false)
  bgfx_vertex_layout_add(addr renderData.mesh.vLayout, BGFX_ATTRIB_TEXCOORD2, 1,
      BGFX_ATTRIB_TYPE_FLOAT, false, false)
  bgfx_vertex_layout_add(addr renderData.mesh.vLayout, BGFX_ATTRIB_TEXCOORD3, 1,
      BGFX_ATTRIB_TYPE_FLOAT, false, false)
  bgfx_vertex_layout_add(addr renderData.mesh.vLayout, BGFX_ATTRIB_TEXCOORD4, 4,
      BGFX_ATTRIB_TYPE_INT16, false, false)
  bgfx_vertex_layout_add(addr renderData.mesh.vLayout, BGFX_ATTRIB_TEXCOORD5, 4,
      BGFX_ATTRIB_TYPE_INT16, false, false)
  bgfx_vertex_layout_end(addr renderData.mesh.vLayout)

  renderData.shaderProgram = programHandles[shader]
  assert(renderData.shaderProgram.idx != BGFX_INVALID_HANDLE.idx)

proc findDepthFormat(textureFlags: uint64;
    stencil: bool = false): bgfx_texture_format_t =

  let
    formats = if stencil: @[BGFX_TEXTURE_FORMAT_D24S8] else: @[
      BGFX_TEXTURE_FORMAT_D16, BGFX_TEXTURE_FORMAT_D32]

  result = BGFX_TEXTURE_FORMAT_COUNT
  for i in 0 ..< len(formats):
    if bgfx_is_texture_valid(0, false, 1, formats[i], textureFlags):
      result = formats[i]
      break

  assert(result != BGFX_TEXTURE_FORMAT_COUNT)

proc createFrameBuffer(hdr, depth: bool): bgfx_frame_buffer_handle_t =
  var
    textures: array[2, bgfx_texture_handle_t]
    attachments = 0'u8

  let
    samplerFlags = uint64(BGFX_SAMPLER_MIN_POINT or BGFX_SAMPLER_MAG_POINT or
      BGFX_SAMPLER_MIP_POINT or BGFX_SAMPLER_U_CLAMP or BGFX_SAMPLER_V_CLAMP)
    format = if hdr: BGFX_TEXTURE_FORMAT_RGBA16F else: BGFX_TEXTURE_FORMAT_BGRA8

  assert(bgfx_is_texture_valid(0, false, 1, format, BGFX_TEXTURE_RT or samplerFlags))
  textures[attachments] = bgfx_create_texture_2d_scaled(
    BGFX_BACKBUFFER_RATIO_EQUAL, false, 1, format, BGFX_TEXTURE_RT or samplerFlags)
  inc(attachments)

  if depth:
    let depthFormat = findDepthFormat(BGFX_TEXTURE_RT_WRITE_ONLY or samplerFlags)
    assert(depthFormat != BGFX_TEXTURE_FORMAT_COUNT)
    textures[attachments] = bgfx_create_texture_2d_scaled(
        BGFX_BACKBUFFER_RATIO_EQUAL, false, 1, depthFormat,
        BGFX_TEXTURE_RT_WRITE_ONLY or samplerFlags)
    inc(attachments)

  result = bgfx_create_frame_buffer_from_handles(attachments, addr textures[0], true)

  if result.idx == high(uint16):
    echo "failed to create framebuffer"

proc init*(basePath: string) =
  var displayMode: sdl.DisplayMode
  discard sdl.getDesktopDisplayMode(0, displayMode)

  rendererType = bgfx_get_renderer_type()
  rendererCaps = bgfx_get_caps()

  shader.init(basePath)

  bgfx_reset(1280, 720, BGFX_RESET_MAXANISOTROPY or BGFX_RESET_VSYNC, BGFX_TEXTURE_FORMAT_COUNT)
  bgfx_set_view_clear(0, BGFX_CLEAR_COLOR or BGFX_CLEAR_DEPTH, 0x303030ff, 1.0, 0)

  frameBuffer = createFrameBuffer(true, true)

  bgfx_vertex_layout_begin(addr posVertexLayout, BGFX_RENDERER_TYPE_NOOP)
  bgfx_vertex_layout_add(addr posVertexLayout, BGFX_ATTRIB_POSITION, 3,
      BGFX_ATTRIB_TYPE_FLOAT, false, false)
  bgfx_vertex_layout_end(addr posVertexLayout)

  blitSampler = bgfx_create_uniform("s_texColor", BGFX_UNIFORM_TYPE_SAMPLER, 1)
  camPosUniform = bgfx_create_uniform("u_camPos", BGFX_UNIFORM_TYPE_VEC4, 1)
  normalMatrixUniform = bgfx_create_uniform("u_normalMatrix",
    BGFX_UNIFORM_TYPE_MAT3, 1)
  exposureVecUniform = bgfx_create_uniform("u_exposureVec",
    BGFX_UNIFORM_TYPE_VEC4, 1)
  tonemappingModeVecUniform = bgfx_create_uniform("u_tonemappingModeVec",
    BGFX_UNIFORM_TYPE_VEC4, 1)

  uAmbientColor = bgfx_create_uniform("ambient_color", BGFX_UNIFORM_TYPE_VEC4, 1)
  uEmitLightColor = bgfx_create_uniform("light_color", BGFX_UNIFORM_TYPE_VEC4, 1)
  uEmitLightPos = bgfx_create_uniform("light_pos", BGFX_UNIFORM_TYPE_VEC4, 1)
  uViewPos = bgfx_create_uniform("view_pos", BGFX_UNIFORM_TYPE_VEC4, 1)

  var vertices = [
    PosVertex(x: left, y: bottom, z: 0.0'f32),
    PosVertex(x: right, y: bottom, z: 0.0'f32),
    PosVertex(x: left, y: top, z: 0.0'f32)
  ]
  blitTriangleBuffer = bgfx_create_vertex_buffer(bgfx_copy(addr vertices[0],
      uint32(sizeof(vertices))), addr posVertexLayout, BGFX_BUFFER_NONE)

proc blitToScreen(view: bgfx_view_id_t) =
  bgfx_set_view_clear(view, BGFX_CLEAR_NONE, 255'u32, 1.0'f32, 0'u8)
  bgfx_set_view_rect(view, 0, 0, 1280, 720)
  bgfx_set_view_frame_buffer(view, bgfx_frame_buffer_handle_t(idx: high(uint16)))
  bgfx_set_state(BGFX_STATE_WRITE_RGB or BGFX_STATE_CULL_CW, 0'u32)
  let frameBufferTexture = bgfx_get_texture(frameBuffer, 0)
  bgfx_set_texture(0'u8, blitSampler, frameBufferTexture, high(uint32))
  var exposureVec = [1.0'f32, 1.0'f32, 1.0'f32, 1.0'f32]
  bgfx_set_uniform(exposureVecUniform, addr exposureVec[0], 1)
  var toneMappingModeVec = [0.0'f32, 0.0'f32, 0.0'f32, 0.0'f32]
  bgfx_set_uniform(tonemappingModeVecUniform, addr toneMappingModeVec[0], 1)
  bgfx_set_vertex_buffer(0'u8, blitTriangleBuffer, 0'u32, high(uint32))
  bgfx_submit(view, programHandles["blit"], 0'u32, false)

proc render*() =
  blitToScreen(maxView)

proc shutdown*() =
  bgfx_destroy_uniform(blitSampler)
  bgfx_destroy_uniform(camPosUniform)
  bgfx_destroy_uniform(normalMatrixUniform)
  bgfx_destroy_uniform(exposureVecUniform)
  bgfx_destroy_uniform(tonemappingModeVecUniform)

  bgfx_destroy_vertex_buffer(blitTriangleBuffer)

  bgfx_destroy_uniform(uAmbientColor)
  bgfx_destroy_uniform(uEmitLightColor)
  bgfx_destroy_uniform(uEmitLightPos)
  bgfx_destroy_uniform(uViewPos)

  shader.destroy()
  bgfx_shutdown()
