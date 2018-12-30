
{.deadCodeElim: on.}
when defined(windows):
  const
    shadercdll* = "libbgfx-shared-lib(Debug|Release).dll"
elif defined(macosx):
  const
    shadercdll* = "libbrtshaderc(Debug|Release).dylib"
else:
  const
    shadercdll* = "libbgfx-shared-lib(Debug|Release).so"

import  strutils, os, tables,
        engine_types, material, 
        bgfxdotnim

type
  CArray{.unchecked.} = array[0..0, cuchar]

const 
  BGFX_INVALID_HANDLE = uint16.high
  SHADER_SUFFIXES = [
    "_cs.sc",
    "_fs.sc",
    "_gs.sc",
    "_vs.sc",
  ]

proc bgfx_compile_shader*(argc: cint, argv: ptr cstring): ptr bgfx_memory_t {.importc: "bgfx_compile_shader", dynlib: shadercdll.}

proc newShaderVersion(program: Program): ShaderVersion =
  result = ShaderVersion(
    program: program
  )

proc shaderVersion(p: Program, version: Version): ShaderVersion =
  result = newShaderVersion(p)
  result.options = version.version

proc programDefines(p: Program, version: ShaderVersion): string =
  for option in 0 ..< 32:
    if (version.options and (1 shl option)) > 0:
      result &= p.optionNames[option] & ";"

  for mode in 0 ..< len(p.modeNames):
    result &= p.modeNames[mode] & "=" & intToStr(version.modes[mode]) & ";"

  for define in p.defines:
    result &= define.name & "=" & define.value & ";"

proc shaderSuffix(shaderKind: ShaderKind): string =
  result = SHADER_SUFFIXES[shaderKind.ord]

proc shaderPath(name: string, shaderKind: ShaderKind): string =
  let suffix = shaderSuffix(shaderKind)
  result = "" & "shaders/" & name & suffix

proc compileShader(name: string, suffix: string, shaderKind: ShaderKind, definesIn: string, source: string): bool =
  var defines = definesIn
  let isOpenGL = bgfx_get_renderer_type() == BGFX_RENDERER_TYPE_OPENGLES or
                  bgfx_get_renderer_type() == BGFX_RENDERER_TYPE_OPENGL

  let sourcePath = shaderPath(name, shaderKind)

  if len(source) > 0:
    writeFile(sourcePath, source)

  var outputSuffixes {.global.} = ["_cs", "_fs", "_gs", "_vs"]

  let outputSuffix = outputSuffixes[shaderKind.ord]
  let outputPath = "" & "shaders/compiled" & name & suffix & outputSuffix

  try:
    createDir(outputPath)
  except OSError:
    echo "failed creating output dir for compiled shader"
    return false
  
  let incl = "" & "shaders/"
  let varyingPath = "" & "shaders/varying.def.sc"

  type Target = enum
    GLSL, ESSL, HLSL, Metal
  
  when defined(macosx):
    let target = if isOpenGL: GLSL else: Metal
    
  if target == ESSL or target == Metal:
    defines &= "NO_TEXEL_FETCH;"
  
  var args: seq[cstring] = @[]

  var types = ["compute", "fragment", "geometry", "vertex"]

  args.add([cstring"-f", sourcePath])
  args.add([cstring"-o", outputPath])
  args.add([cstring"-i", incl])
  args.add(cstring"--depends")
  args.add([cstring"--varyingdef", varyingPath])
  args.add([cstring"--define", defines])
  args.add([cstring"--type", types[shaderKind.ord]])

  when not defined(emscripten):
    args.add(cstring"-O3")
  
  if target == GLSL:
    args.add([cstring"--platform", "linux"])
    args.add([cstring"--profile", "430"])
  elif target == ESSL:
    args.add([cstring"--platform", "android"])
  elif target == HLSL:
    let profiles = ["cs_5_0", "ps_5_0", "gs_5_0", "vs_5_0"]
    args.add([cstring"--platform", "windows"])
    args.add([cstring"--profile", profiles[shaderKind.ord]])
  elif target == Metal:
    args.add([cstring"--platform", "osx"])
    args.add([cstring"--profile", "metal"])
  
  let compiledShader = bgfx_compile_shader(len(args).cint, addr args[0])

  if compiledShader == nil:
    return false
  
  result = true

proc loadMem(filePath: string): ptr bgfx_memory_t =
  var f: File
  try:
    f = open(filePath)
  except IOError:
    echo "failed loading file at - " & filePath & " - error: " & getCurrentExceptionMsg()
    return nil
  
  let size = getFileSize(filePath)
  result = bgfx_copy(cast[pointer](addr f), size.uint32 + 1)
  var resultData = cast[ptr CArray](result.data)
  resultData[result.size - 1] = '\0'

  f.close()

proc loadShader(path: string): bgfx_shader_handle_t =
  result = bgfx_shader_handle_t(idx: BGFX_INVALID_HANDLE)
  if fileExists(path):
    result = bgfx_create_shader(loadMem(path))

proc loadProgram(shaderPath: string): bgfx_program_handle_t =
  let vsPath = shaderPath & "_vs"
  let gsPath = shaderPath & "_gs"
  let fsPath = shaderPath & "_fs"

  let vertexShader = loadShader(vsPath)
  # let geometryShader = loadShader(gsPath)
  let fragmentShader = loadShader(fsPath)

  let program = bgfx_create_program(vertexShader, fragmentShader, true)

proc compile(p: Program, version: var Version, compute: bool) =
  let config = p.shaderVersion(version)

  let suffix = "_v" & intToStr(version.version)
  let defs = p.programDefines(config)

  var compiled = true
  compiled = compiled and compileShader(p.name, suffix, skVertex, defs, p.sources[skVertex.ord])
  compiled = compiled and compileShader(p.name, suffix, skFragment, defs, p.sources[skFragment.ord])

  if fileExists(shaderPath(p.name, skGeometry)):
    compiled = compiled and compileShader(p.name, suffix, skGeometry, defs, p.sources[skGeometry.ord])

  let fullName = p.name & suffix

  if not compiled:
    version.update = p.update
    return
  
  let compiledPath = "" & "/shaders/compiled/" & fullName
  version.program = loadProgram(compiledPath)
  version.update = p.update

proc updateVersions*(p: Program) =
  for _, version in p.versions.mpairs:
    if version.update < p.update:
      p.compile(version, p.compute)

proc registerOptions(p: var Program, b: int, options: openArray[string]) =
  p.blocks.shaderBlocks[b].optionShift = len(p.optionNames)

  for option in options:
    p.optionNames.add(option)

proc newVersion(): Version =
  result.program.idx = BGFX_INVALID_HANDLE

proc newProgram(name: string, compute: bool = false): Program =
  result.name = name
  result.compute = compute
  result.update = 1

  let pbr = newPbrPipelineStep()

  result.registerOptions(0, ["SKELETON", "INSTANCING", "BILLBOARD", "QNORMALS", "MRT", "DEFERRED", "CLUSTERED"])
  result.registerOptions(pbr.index, pbr.shaderBlock.options)