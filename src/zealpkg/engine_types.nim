import  tables, strutils, 
        bgfxdotnim

proc currentSourceDir*(): string =
  result = currentSourcePath()
  result = result[0 ..< result.rfind("/")]

const ZEAL_DATA_DIR* = currentSourceDir() & "../data"

type
  PlatformData* = object
    nativeWindowHandle*: pointer
    nativeDisplayType*: pointer

  RenderFrame* = tuple
    frame: uint32
    time, deltaTime: float
    renderPass: int
    numDrawCalls, numVertices, numTriangles: int

  PipelineStep* = ref object of RootObj
    index*: int
    shaderBlock*: ShaderBlock

  PipelineKind* = enum
    pkPbr, pkCount

  Pipeline* = object
    steps*: seq[PipelineStep]

  ShaderKind* = enum
    skCompute, skFragment, skGeometry, skVertex, skCount
  
  ShaderDefine = object
    name*: string
    value*: string
  
  ShaderBlock* = object
    options*: seq[string]
    modes: seq[string]
    defines: seq[ShaderDefine]

  ProgramBlock = tuple
    optionShift: int
    modeShift: int
  
  ProgramBlockArray* = object
    shaderBlocks*: array[32, ProgramBlock]
    nextOption: int
  
  Version* = object
    version*: int
    update*: int
    program*: bgfx_program_handle_t

  Program* = ref object
    name*: string
    compute*: bool
    blocks*: ProgramBlockArray
    optionNames*: seq[string]
    modeNames*: seq[string]
    defines*: seq[ShaderDefine]
    update*: int
    sources*: array[skCount.ord, string]
    versions*: Table[int, Version]

  ShaderVersion* = object
    program*: Program
    options*: int
    modes*: array[4, int]

  GfxSystemState* = object
    initialized*: bool
    frame*: uint32
    startCounter*: int64
    deltaTime*, frameTime*, lastTime*: float

  GfxCtx* = object
    width*, height*: int
    pipeline*: Pipeline
    programs*: Table[string, Program]
    state*: GfxSystemState
    resourcePaths*: seq[string]

proc newPipelineStep*[T](): T =
  result = new(T)

proc resourcePath*(gfx: GfxCtx): string = 
  result = gfx.resourcePaths[0]

proc newProgram*(gfx: var GfxCtx, name: string): Program =
  if gfx.programs.contains(name):
    echo "program already exists"
    result = gfx.programs[name]
  
  else:
    result = new(Program)
    result.name = name
    result.versions = initTable[int, Version]()
    gfx.programs.add(name, result)