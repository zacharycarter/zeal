import bgfxdotnim, sdl2 as sdl, tables

var 
  viewPosUniform*: bgfx_uniform_handle_t
  sTexColor*: bgfx_uniform_handle_t

type
  ShaderResource = object
    programHandle: bgfx_program_handle_t
    name: string
    vertexPath: string
    fragPath: string

var 
  shaders: seq[ShaderResource] = @[
    ShaderResource(
      name: "basic",
      vertexPath: "vertex/basic_vs.bin",
      fragPath: "fragment/basic_fs.bin"
    ),
    ShaderResource(
      name: "terrain",
      vertexPath: "vertex/terrain_vs.bin",
      fragPath: "fragment/terrain_fs.bin"
    )
  ]
  programHandles*: Table[string, bgfx_program_handle_t]

proc loadShader(basePath: string, filePath: string): bgfx_shader_handle_t =
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
  dealloc(ret)

proc init*(basePath: string) =
  for shader in shaders:
    let vsh = loadShader(basePath, shader.vertexPath)
    let fsh = if shader.fragPath.len > 0: loadShader(basePath, shader.fragPath) else: BGFX_INVALID_HANDLE

    programHandles.add(shader.name, bgfx_create_program(vsh, fsh, true))
  
  sTexColor = bgfx_create_uniform("s_texColor", BGFX_UNIFORM_TYPE_SAMPLER, 11)
  var ambientColorU = bgfx_create_uniform("ambient_color", BGFX_UNIFORM_TYPE_VEC4, 1)
  var lightColorU = bgfx_create_uniform("light_color", BGFX_UNIFORM_TYPE_VEC4, 1)
  var lightPosU = bgfx_create_uniform("light_pos", BGFX_UNIFORM_TYPE_VEC4, 1)
  viewPosUniform = bgfx_create_uniform("view_pos", BGFX_UNIFORM_TYPE_VEC4, 1)
  
  var ambientLightColor = [1.0'f32, 1.0, 1.0, 0.0]
  var emitLightPos = [1664.0'f32, 1024.0, 384.0]

  bgfx_set_uniform(ambientColorU, addr ambientLightColor[0], 1)
  bgfx_set_uniform(lightColorU, addr ambientLightColor[0], 1)
  bgfx_set_uniform(lightPosU, addr emitLightPos[0], 1)

proc destroy*() =
  for shaderName, programHandle in programHandles:
    bgfx_destroy_program(programHandle)