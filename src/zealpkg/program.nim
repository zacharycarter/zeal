import  strutils, os, tables,
        engine_types, material, 
        bgfxdotnim

const 
  BGFX_INVALID_HANDLE = uint16.high
  SHADER_SUFFIXES = [
    "_cs.sc",
    "_fs.sc",
    "_gs.sc",
    "_vs.sc",
  ]

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
  let defines = definesIn
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
    


proc compile(p: Program, version: Version, compute: bool) =
  let config = p.shaderVersion(version)

  let suffix = "_v" & intToStr(version.version)
  let defs = p.programDefines(config)

  var compiled = true
  compiled = compiled and compileShader(p.name, suffix, skVertex, defs, p.sources[skVertex.ord])

proc updateVersions*(p: Program) =
  for _, version in p.versions:
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