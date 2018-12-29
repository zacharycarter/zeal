import  engine_types, material,
        tables,
        bgfxdotnim

const BGFX_INVALID_HANDLE = uint16.high

proc newShaderVersion(program: Program): ShaderVersion =
  result = ShaderVersion(
    program: program
  )

proc shaderVersion(p: Program, version: Version): ShaderVersion =
  result = newShaderVersion(p)
  result.options = version.version

proc compile(p: Program, version: Version, compute: bool) =
  let config = p.shaderVersion(version)

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