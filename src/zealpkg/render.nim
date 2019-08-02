import bgfxdotnim, sdl2 as sdl, shader, terrain, mesh, material, tables, vertex, fpmath

const
  vertsPerSideFace* = 6
  vertsPerTopFace*  = 24
  vertsPerTile*     = 5 * vertsPerSideFace + vertsPerTopFace

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

var 
  rendererType: bgfx_renderer_type_t
  rendererCaps*: ptr bgfx_caps_t

proc setViewTransform*(view: var Mat4) =
  var proj: Mat4
  mtxProj(proj, 45.0'f32, 1280.0 / 720.0, 0.1, 1000.0, rendererCaps.homogeneousDepth)
  bgfx_set_view_transform(0, addr view[0], addr proj[0])

proc draw*(renderData: RenderData, model: var Mat4) =
  bgfx_set_view_rect(0, 0, 0, 1280'u16, 720'u16)

  bgfx_touch(0)
  
  # var modelT: Mat4
  # mtxIdentity(modelT)
  discard bgfx_set_transform(addr model[0], 1)
  
  bgfx_set_dynamic_vertex_buffer(0'u8, renderData.mesh.vBuffHandle, 0'u32, uint32(renderData.mesh.numVerts))
  # bgfx_set_index_buffer(renderData.mesh.iBuffHandle, 0'u32, 36'u32)

  bgfx_set_texture(0, sTexColor, mapTextures.handle, high(uint32))

  # bgfx_set_state( 0'u64 or BGFX_STATE_WRITE_RGB or BGFX_STATE_WRITE_Z or BGFX_STATE_DEPTH_TEST_LESS or  BGFX_STATE_MSAA, 0)
  bgfx_set_state( 0'u64 or BGFX_STATE_WRITE_RGB or BGFX_STATE_WRITE_Z or BGFX_STATE_DEPTH_TEST_LESS or BGFX_STATE_CULL_CCW, 0)

  bgfx_submit(0, renderData.shaderProgram, 0, false)

proc fillVBuff*(renderData: var RenderData, vBuff: var seq[Vertex]) =
  var mem = bgfx_copy(cast[pointer](addr vbuff[0]), uint32(sizeof(Vertex) * renderData.mesh.numVerts))
  renderData.mesh.vBuffHandle = bgfx_create_dynamic_vertex_buffer_mem(mem, addr renderData.mesh.vDecl, BGFX_BUFFER_ALLOW_RESIZE)

proc initVBuff*(renderData: var RenderData, shader: string, vBuff: var seq[Vertex]) =
  bgfx_vertex_decl_begin(addr renderData.mesh.vDecl, rendererType)
  bgfx_vertex_decl_add(addr renderData.mesh.vDecl, BGFX_ATTRIB_POSITION, 3, BGFX_ATTRIB_TYPE_FLOAT, false, false)
  bgfx_vertex_decl_add(addr renderData.mesh.vDecl, BGFX_ATTRIB_TEXCOORD0, 2, BGFX_ATTRIB_TYPE_FLOAT, false, false)
  bgfx_vertex_decl_add(addr renderData.mesh.vDecl, BGFX_ATTRIB_NORMAL, 3, BGFX_ATTRIB_TYPE_FLOAT, false, false)
  bgfx_vertex_decl_add(addr renderData.mesh.vDecl, BGFX_ATTRIB_TEXCOORD2, 1, BGFX_ATTRIB_TYPE_INT16, false, false)
  bgfx_vertex_decl_add(addr renderData.mesh.vDecl, BGFX_ATTRIB_TEXCOORD3, 1, BGFX_ATTRIB_TYPE_INT16, false, false)
  bgfx_vertex_decl_add(addr renderData.mesh.vDecl, BGFX_ATTRIB_TEXCOORD4, 4, BGFX_ATTRIB_TYPE_INT16, false, false)
  bgfx_vertex_decl_end(addr renderData.mesh.vDecl)
  # bgfx_vertex_decl_begin(addr renderData.mesh.vDecl, rendererType)
  # bgfx_vertex_decl_add(addr renderData.mesh.vDecl, BGFX_ATTRIB_POSITION, 3, BGFX_ATTRIB_TYPE_FLOAT, false, false)
  # bgfx_vertex_decl_add(addr renderData.mesh.vDecl, BGFX_ATTRIB_COLOR0, 4, BGFX_ATTRIB_TYPE_UINT8, true, false)
  # bgfx_vertex_decl_end(addr renderData.mesh.vDecl)

  # type 
  #   PosColorVertex = object
  #     x, y, z: float32
  #     abgr: uint32

  # var verts = [
  #   PosColorVertex(x: -1.0'f32, y: 1.0f,  z: 1.0f, abgr: 0xff000000'u32),
  #   PosColorVertex(x: 1.0'f32,  y: 1.0f,  z: 1.0f, abgr: 0xff0000ff'u32),
  #   PosColorVertex(x: -1.0'f32, y: -1.0f, z: 1.0f, abgr: 0xff00ff00'u32),
  #   PosColorVertex(x: 1.0'f32,  y: -1.0f, z: 1.0f, abgr: 0xff00ffff'u32),
  #   PosColorVertex(x: -1.0'f32, y: 1.0f,  z: -1.0f, abgr: 0xffff0000'u32),
  #   PosColorVertex(x: 1.0'f32,  y: 1.0f,  z: -1.0f, abgr: 0xffff00ff'u32),
  #   PosColorVertex(x: -1.0'f32, y: -1.0f, z: -1.0f, abgr: 0xffffff00'u32),
  #   PosColorVertex(x: 1.0'f32,  y: -1.0f, z: -1.0f, abgr: 0xffffffff'u32)
  # ]

  # var mem = bgfx_copy(cast[pointer](addr vbuff[0]), uint32(sizeof(Vertex) * renderData.mesh.numVerts))
  # renderData.mesh.vBuffHandle = bgfx_create_dynamic_vertex_buffer_mem(mem, addr renderData.mesh.vDecl, BGFX_BUFFER_ALLOW_RESIZE)
  
  # var triList = [
  #   0'u16, 1, 2, # 0
  #   1, 3, 2,
  #   4, 6, 5, # 2
  #   5, 6, 7,
  #   0, 2, 4, # 4
  #   4, 2, 6,
  #   1, 5, 3, # 6
  #   5, 7, 3,
  #   0, 4, 1, # 8
  #   4, 5, 1,
  #   2, 3, 6, # 10
  #   6, 3, 7,
  # ]

  # var mem1 = bgfx_copy(cast[pointer](addr triList[0]), sizeof(uint16) * 36)
  # renderData.mesh.iBuffHandle = bgfx_create_index_buffer(mem1, BGFX_BUFFER_NONE)
  
  renderData.shaderProgram = programHandles[shader]
  assert(renderData.shaderProgram.idx != BGFX_INVALID_HANDLE.idx)

proc init*(basePath: string) =
  var displayMode: sdl.DisplayMode
  discard sdl.getDesktopDisplayMode(0, displayMode)

  rendererType = bgfx_get_renderer_type()
  rendererCaps = bgfx_get_caps()

  shader.init(basePath)

  # bgfx_set_debug(BGFX_DEBUG_WIREFRAME)
  bgfx_reset(950, 540, BGFX_RESET_VSYNC, BGFX_TEXTURE_FORMAT_COUNT)
  bgfx_set_view_clear(0, BGFX_CLEAR_COLOR or BGFX_CLEAR_DEPTH, 0x303030ff, 1.0, 0)

proc shutdown*() =
  terrain.destroy()
  shader.destroy()
  bgfx_shutdown()