import bgfxdotnim, sdl2 as sdl, tables

type
  ShaderResource = object
    programHandle: bgfx_program_handle_t
    name: string
    vertexPath: string
    fragPath: string

var 
  shaders: seq[ShaderResource] = @[
    ShaderResource(
      name: "mesh.static.colored",
      vertexPath: "vertex/basic.bin",
      fragPath: "fragment/colored.bin"
    )
  ]
  programHandles: Table[string, bgfx_program_handle_t]

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
  programHandles = initTable[string, bgfx_program_handle_t]()
  for shader in shaders:
    let vsh = loadShader(basePath, shader.vertexPath)
    let fsh = if shader.fragPath.len > 0: loadShader(basePath, shader.fragPath) else: BGFX_INVALID_HANDLE

    programHandles.add(shader.name, bgfx_create_program(vsh, fsh, true))

  for shaderName, programHandle in programHandles:
    bgfx_destroy_program(programHandle)