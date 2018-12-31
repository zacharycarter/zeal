import  tables, strutils,
        math,
        bgfxdotnim

proc currentSourceDir*(): string =
  result = currentSourcePath()
  result = result[0 ..< result.rfind("/")]

const ZEAL_DATA_DIR* = currentSourceDir() & "../data"

type
  CArray*[T] = array[0..0, T]

  PlatformData* = object
    nativeWindowHandle*: pointer
    nativeDisplayType*: pointer

  RenderFrame* = tuple
    frame: uint32
    time, deltaTime: float
    renderPass: int
    numDrawCalls, numVertices, numTriangles: int

  FrameBuffer* = ref object of RootObj
    size*: Vec2
    screenView*: Mat4
    screenProj*: Mat4
    fbo*: bgfx_frame_buffer_handle_t

  RenderTarget* = ref object of FrameBuffer
    mrt*: bool

  Render* = object
    target*: RenderTarget
    isMRT*: bool

  RenderPassKind* = enum
    rpkVoxelGI, rpkLightmap, rpkShadowmap, rpkProbes, 
    rpkClear, rpkDepth, rpkGeometry, rpkLights, rpkOpaque, 
    rpkBackground, rpkParticles, rpkAlpha, rpkUnshaded, 
    rpkEffects, rpkPostProcess, rpkFlip, rpkCount

  RenderPass* = object
    name: string
    passKind: RenderPassKind
    steps: seq[PipelineStep]

  DrawElement* = object

  PipelineStep* = ref object of RootObj
    index*: int
    shaderStep*: ShaderStep
    drawStep*: bool

  DrawStep* = ref object of PipelineStep

  FilterUniform = object
    source0*: bgfx_uniform_handle_t
    source1*: bgfx_uniform_handle_t
    source2*: bgfx_uniform_handle_t
    source3*: bgfx_uniform_handle_t
    sourceDepth*: bgfx_uniform_handle_t
    
    source0Level*: bgfx_uniform_handle_t
    source1Level*: bgfx_uniform_handle_t
    source2Level*: bgfx_uniform_handle_t
    source3Level*: bgfx_uniform_handle_t
    sourceDepthLevel*: bgfx_uniform_handle_t

    sourceCrop*: bgfx_uniform_handle_t
    
    screenSizePixelSize*: bgfx_uniform_handle_t
    cameraParams*: bgfx_uniform_handle_t

  FilterStep* = ref object of PipelineStep
    quadProgram*: Program
    uniform*: FilterUniform

  CopyStep* = ref object of PipelineStep
    filter*: FilterStep
    program*: Program

  DepthParams = ref object
    depthBias: float
    depthNormalBias: float
    depthZFar: float
    padding: float

  DepthStep* = ref object of DrawStep
    currentParams: DepthParams
    depthParams: DepthParams
    depthMaterial: Material
    depthMaterialTwosided: Material

  EffectBlurUniform* = object
    blurParams*: bgfx_uniform_handle_t
    blurKernel03*: bgfx_uniform_handle_t
    blurKernel47*: bgfx_uniform_handle_t

  BlurStep* = ref object of PipelineStep
    filter*: FilterStep
    uniform*: EffectBlurUniform
    program*: Program

  GeometryStep* = ref object of DrawStep
    material: Material
    materialTwosided: Material

  SkyboxUniform* = object
    skyboxMatrix*: bgfx_uniform_handle_t
    skyboxParams*: bgfx_uniform_handle_t
    skyboxMap*: bgfx_uniform_handle_t

  SkyStep* = ref object of PipelineStep
    filter*: FilterStep
    skyboxProgram*: Program
    skybox: SkyboxUniform

  PipelineKind* = enum
    pkPbr, pkCount

  Pipeline* = object
    steps*: seq[PipelineStep]

  ShaderKind* = enum
    skCompute, skFragment, skGeometry, skVertex, skCount
  
  ShaderDefine = object
    name*: string
    value*: string
  
  ShaderStep* = object
    options*: seq[string]
    modes*: seq[string]
    defines*: seq[ShaderDefine]

  ProgramBlock = tuple
    optionShift: int
    modeShift: int
  
  ProgramStepArray* = object
    shaderSteps*: array[32, ProgramBlock]
    nextOption: int
  
  Version* = object
    version*: int
    update*: int
    program*: bgfx_program_handle_t

  Material* = ref object
    index: int
    name: string
    builtin: bool
    program: Program

  Program* = ref object
    name*: string
    compute*: bool
    steps*: ProgramStepArray
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

proc newDrawStep*[T](): DrawStep =
  result = newPipelineStep[T]()
  result.drawStep = true

proc submit*[T](ds: T, r: var Render, rp: var RenderPass) =
  discard

proc submit*[T](ds: T, r: var Render, e: var DrawElement, rp: var RenderPass) =
  ds.submit(r, rp)

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