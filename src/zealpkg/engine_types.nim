import  tables, bgfxdotnim

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
    versions*: Table[int, Version]

  ShaderVersion* = object
    program*: Program
    options*: int
    modes*: array[4, int]