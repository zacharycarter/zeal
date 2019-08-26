import bgfxdotnim, sdl2 as sdl, tables

type
  ShaderResource = object
    programHandle: bgfx_program_handle_t
    name: string
    vertexPath: string
    fragPath: string
    computePath: string

var 
  shaders: seq[ShaderResource] = @[
    ShaderResource(
      name: "basic",
      vertexPath: "vertex/basic_vs.bin",
      fragPath: "fragment/basic_fs.bin"
    ),
    # ShaderResource(
    #   name: "terrain",
    #   vertexPath: "vertex/terrain_vs.bin",
    #   fragPath: "fragment/terrain_fs.bin"
    # ),
    ShaderResource(
      name: "terrainRender",
      vertexPath: "vertex/terrain_render_vs.bin",
      fragPath: "fragment/terrain_render_fs.bin"
    ),
    ShaderResource(
      name: "terrainRenderNormal",
      vertexPath: "vertex/terrain_render_vs.bin",
      fragPath: "fragment/terrain_render_normal_fs.bin"
    ),
    ShaderResource(
      name: "terrainLOD",
      computePath: "compute/terrain_lod_cs.bin"
    ),
    ShaderResource(
      name: "terrainUpdateIndirect",
      computePath: "compute/terrain_update_indirect_cs.bin"
    ),
    ShaderResource(
      name: "terrainUpdateDraw",
      computePath: "compute/terrain_update_draw_cs.bin"
    ),
    ShaderResource(
      name: "terrainInitIndirect",
      computePath: "compute/terrain_init_cs.bin"
    )
  ]
  programHandles*: Table[string, bgfx_program_handle_t]

proc loadShader(basePath: string, filePath: string, shaderName: string): bgfx_shader_handle_t =
  var shaderPath: string
  case bgfx_get_renderer_type()
  of BGFX_RENDERER_TYPE_DIRECT3D11:
    shaderPath = "$1/shaders/dx11/$2" % [basePath, filePath]
  else:
    discard
  
  let stream = sdl.rwFromFile(shaderPath, "r")
  if stream == nil:
    return BGFX_INVALID_HANDLE
  
  let size = size(stream)
  var ret = alloc(size + 1)
  if ret == nil:
    discard close(stream)
    return BGFX_INVALID_HANDLE
  
  var o = ret
  var read, readTotal = 0'i64
  while readTotal < size:
    read = read(stream, o, csize(1), csize(size - readTotal))

    if read == 0:
      break
    
    readTotal += read
    o = cast[pointer](cast[int64](o) + read)
  
  discard close(stream)
  
  if readTotal != size:
    return BGFX_INVALID_HANDLE

  zeroMem(o, 1)
  result = bgfx_create_shader(bgfx_copy(ret, uint32(size)))
  bgfx_set_shader_name(result, shaderName, int32.high)
  dealloc(ret)

proc init*(basePath: string) =
  for shader in shaders:
    let vsh = if shader.vertexPath.len > 0: loadShader(basePath, shader.vertexPath, shader.name) else: BGFX_INVALID_HANDLE
    let fsh = if shader.fragPath.len > 0: loadShader(basePath, shader.fragPath, shader.name) else: BGFX_INVALID_HANDLE
    let csh = if shader.computePath.len > 0: loadShader(basePath, shader.computePath, shader.name) else: BGFX_INVALID_HANDLE

    if csh == BGFX_INVALID_HANDLE:
      programHandles.add(shader.name, bgfx_create_program(vsh, fsh, true))
    else:
      programHandles.add(shader.name, bgfx_create_compute_program(csh, true))

proc destroy*() =
  for shaderName, programHandle in programHandles:
    bgfx_destroy_program(programHandle)