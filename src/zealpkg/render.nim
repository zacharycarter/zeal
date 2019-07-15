import bgfxdotnim, sdl2 as sdl, shader, terrain, mesh, material, tables, vertex

const
  vertsPerSideFace* = 6
  vertsPerTopFace*  = 24
  vertsPerTile*     = 5 * vertsPerSideFace + vertsPerTopFace

type
  RenderData* = object
    mesh*: Mesh
    numMaterials*: int
    materials*: Material
    shaderProgram*: bgfx_program_handle_t
    depthShaderProgram*: bgfx_program_handle_t

var rendererType: bgfx_renderer_type_t

proc initVBuff*(renderData: var RenderData, shader: string, vBuff: var seq[Vertex]) =
  bgfx_vertex_decl_begin(addr renderData.mesh.vDecl, rendererType)
  bgfx_vertex_decl_add(addr renderData.mesh.vDecl, BGFX_ATTRIB_POSITION, 3, BGFX_ATTRIB_TYPE_FLOAT, false, false)
  bgfx_vertex_decl_add(addr renderData.mesh.vDecl, BGFX_ATTRIB_TEXCOORD0, 2, BGFX_ATTRIB_TYPE_FLOAT, false, false)
  bgfx_vertex_decl_add(addr renderData.mesh.vDecl, BGFX_ATTRIB_NORMAL, 3, BGFX_ATTRIB_TYPE_FLOAT, false, false)
  bgfx_vertex_decl_add(addr renderData.mesh.vDecl, BGFX_ATTRIB_TEXCOORD3, 1, BGFX_ATTRIB_TYPE_INT16, false, false)
  bgfx_vertex_decl_skip(addr renderData.mesh.vDecl, 24)
  bgfx_vertex_decl_skip(addr renderData.mesh.vDecl, 24)
  bgfx_vertex_decl_add(addr renderData.mesh.vDecl, BGFX_ATTRIB_TEXCOORD4, 1, BGFX_ATTRIB_TYPE_INT16, false, false)
  bgfx_vertex_decl_add(addr renderData.mesh.vDecl, BGFX_ATTRIB_TEXCOORD5, 4, BGFX_ATTRIB_TYPE_INT16, false, false)
  bgfx_vertex_decl_end(addr renderData.mesh.vDecl)

  var mem = bgfx_make_ref(
    cast[pointer](addr vBuff[0]), 
    uint32(renderData.mesh.numVerts * sizeof(Vertex))
  )
  renderData.mesh.vBuffHandle = bgfx_create_vertex_buffer(mem, addr renderData.mesh.vDecl, BGFX_BUFFER_NONE)

  renderData.shaderProgram = programHandles[shader]
  assert(renderData.shaderProgram.idx != BGFX_INVALID_HANDLE.idx)
  
  bgfx_destroy_vertex_buffer(renderData.mesh.vBuffHandle)

proc init*(basePath: string) =
  var displayMode: sdl.DisplayMode
  discard sdl.getDesktopDisplayMode(0, displayMode)

  rendererType = bgfx_get_renderer_type()

  shader.init(basePath)

  bgfx_set_view_clear(0, BGFX_CLEAR_COLOR or BGFX_CLEAR_DEPTH, 0x303030ff, 1.0, 0)

proc shutdown*() =
  terrain.destroy()
  shader.destroy()
  bgfx_shutdown()