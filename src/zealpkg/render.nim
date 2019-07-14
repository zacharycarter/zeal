import bgfxdotnim, sdl2 as sdl, shader, terrain, mesh, material, vertex

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

proc initVBuff*(renderData: var RenderData, shader: string, vBuff: seq[Vertex]) =
  bgfx_vertex_decl_begin(addr renderData.mesh.vDecl, rendererType)
  bgfx_vertex_decl_add(addr renderData.mesh.vDecl, BGFX_ATTRIB_POSITION, 3, BGFX_ATTRIB_TYPE_FLOAT, false, false)
  bgfx_vertex_decl_add(addr renderData.mesh.vDecl, BGFX_ATTRIB_TEXCOORD0, 2, BGFX_ATTRIB_TYPE_FLOAT, false, false)
  bgfx_vertex_decl_add(addr renderData.mesh.vDecl, BGFX_ATTRIB_NORMAL, 3, BGFX_ATTRIB_TYPE_FLOAT, false, false)
  bgfx_vertex_decl_add(addr renderData.mesh.vDecl, BGFX_ATTRIB_TEXCOORD1, 1, BGFX_ATTRIB_TYPE_FLOAT, false, false)
  bgfx_vertex_decl_end(addr renderData.mesh.vDecl)

proc init*(basePath: string) =
  var displayMode: sdl.DisplayMode
  discard sdl.getDesktopDisplayMode(0, displayMode)

  rendererType = bgfx_get_renderer_type()

  shader.init(basePath)

proc shutdown*() =
  terrain.destroy()
  shader.destroy()
  bgfx_shutdown()