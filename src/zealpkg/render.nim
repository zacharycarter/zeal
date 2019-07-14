import bgfxdotnim, sdl2 as sdl, shader, terrain, mesh, material

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

proc init*(basePath: string) =
  var displayMode: sdl.DisplayMode
  discard sdl.getDesktopDisplayMode(0, displayMode)

  shader.init(basePath)

proc shutdown*() =
  terrain.destroy()
  shader.destroy()
  bgfx_shutdown()