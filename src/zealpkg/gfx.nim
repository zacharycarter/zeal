import sdl2, bgfxdotnim, bgfxdotnim / [platform], deques, sequtils, strutils, tables

const
  SDL_MAJOR_VERSION* = 2
  SDL_MINOR_VERSION* = 0
  SDL_PATCHLEVEL* = 5

type
  AssetStore[T] = Table[string, T]

  SpriteAtlas = object

  Program = ref object
    name: string
    options: seq[string]
    modes: seq[string]
    defines: Deque[ShaderDefine]
    steps: Table[MaterialStepKind, bool]
    registeredSteps: seq[PipelineStep]
  
  ProgramStep = object
    enabled: bool
    optionShift: int
    modeShift: int

  ShaderDefine = object
    name: string
    value: string

  MaterialStepKind = enum
    mskBase,
    mskAlpha,
    mskSolid,
    mskPoint,
    mskLine,
    mskLit,
    mskPbr,
    mskPhong,
    mskFresnel,
    mskUser,
    mskCount

  ShadingKind = enum
    skWireframe,
    skSolid,
    skShaded,
    skVolume,
    skVoxels,
    skLightmap,
    skClear,
    skCount

  Pipeline = seq[PipelineStep]
  
  PipelineStep = ref object of RootObj
    index: int
    options: seq[string]
    modes: seq[string]
    defines: seq[ShaderDefine]
    drawStep: bool

  MaterialStep = ref object of PipelineStep
    u_state: bgfx_uniform_handle_t
    u_state_vertex: bgfx_uniform_handle_t
    s_materials: bgfx_uniform_handle_t
  
  FilterStep = ref object of PipelineStep
    s_source_0: bgfx_uniform_handle_t
    s_source_1: bgfx_uniform_handle_t
    s_source_2: bgfx_uniform_handle_t
    s_source_3: bgfx_uniform_handle_t
    s_source_depth: bgfx_uniform_handle_t

    u_filter_p0: bgfx_uniform_handle_t

    u_source_levels: bgfx_uniform_handle_t
    u_source_crop: bgfx_uniform_handle_t
  
  CopyStep = ref object of PipelineStep
    filterStep: FilterStep
    program: Program

  DepthStep = ref object of PipelineStep
  
  SkyStep = ref object of PipelineStep
    filterStep: FilterStep
    skyboxProgram: Program

  ParticlesStep = ref object of PipelineStep
    sprites: SpriteAtlas

  RenderContext = object

  RenderProc = (proc(renderCtx: RenderContext))


var
  programs: AssetStore[Program] = initTable[string, Program]()
  stepIndex = 1
  shaderSteps: array[32, ProgramStep]
  renderers: Table[ShadingKind, RenderProc] = initTable[ShadingKind, RenderProc]()

template sdlVersion*(x: untyped) =
  (x).major = SDL_MAJOR_VERSION
  (x).minor = SDL_MINOR_VERSION
  (x).patch = SDL_PATCHLEVEL

when defined(windows):
  type
    SysWMMsgWinObj* = object  ##  when defined(SDL_VIDEO_DRIVER_WINDOWS)
      window*: pointer

    SysWMInfoKindObj* = object ##  when defined(SDL_VIDEO_DRIVER_WINDOWS)
      win*: SysWMMsgWinObj 

proc linkSDL2BGFX(window: sdl2.WindowPtr) =
  var pd: ptr bgfx_platform_data_t = createShared(bgfx_platform_data_t) 
  var info: sdl2.WMinfo
  sdlVersion(info.version)
  assert sdl2.getWMInfo(window, info)
  echo  "INFO: SDL version - $1.$2.$3 - Subsystem: $4".format(info.version.major.int, info.version.minor.int, info.version.patch.int, 
  info.subsystem)
  
  case(info.subsystem):
    of SysWM_Windows:
      when defined(windows):
        let info = cast[ptr SysWMInfoKindObj](addr info.padding[0])
        pd.nwh = cast[pointer](info.win.window)
      pd.ndt = nil
    else:
      discard

  pd.backBuffer = nil
  pd.backBufferDS = nil
  pd.context = nil
  bgfx_set_platform_data(pd)
  freeShared(pd)

proc init*(window: sdl2.WindowPtr, width, height: int): bool =
  result = false

  linkSDL2BGFX(window)

  var bgfxInit: bgfx_init_t
  bgfx_init_ctor(addr bgfxInit)

  if not bgfx_init(addr bgfxInit):
    echo "ERROR: BGFX initialization failed"
    return result

  bgfx_set_debug(BGFX_DEBUG_TEXT)

  bgfx_reset(uint32 width, uint32 height, BGFX_RESET_NONE, BGFX_TEXTURE_FORMAT_COUNT)

  bgfx_set_view_rect(0, 0, 0, uint16 width, uint16 height)

  echo "INFO: BGFX initialized"

  result = true

proc newSpriteAtlas(): SpriteAtlas =
  result

proc new(program: typedesc[Program], name: string): Program =
  result = new(Program)
  result.name = name
  result.options = @[]
  result.modes = @[]
  result.defines = initDeque[ShaderDefine]()
  result.steps = initTable[MaterialStepKind, bool]()
  result.registeredSteps = @[]

proc create[T](assetStore: var AssetStore[T], name: string): T =
  if assetStore.contains(name):
    echo "WARN: asset with name $1 already exists: previous asset deleted" % name
    assetStore.del(name)
  
  assetStore.add(name, new(T, name))
  result = assetStore[name]

proc registerOptions(program: Program, stepIndex: int, options: seq[string]) =
  assert(stepIndex < 32)
  shaderSteps[stepIndex].enabled = true
  shaderSteps[stepIndex].optionShift = program.options.len()

  for i in 0 ..< options.len():
    program.options.add(options[i])

proc registerModes(program: Program, stepIndex: int, modes: seq[string]) =
  assert(stepIndex < 32)
  shaderSteps[stepIndex].enabled = true
  shaderSteps[stepIndex].modeShift = program.modes.len()

  for i in 0 ..< modes.len():
    program.modes.add(modes[i])

proc registerStep(program: Program, pipelineStep: PipelineStep) =
  assert(pipelineStep.index < 32)
  shaderSteps[pipelineStep.index].enabled = true
  program.registerOptions(pipelineStep.index, pipelineStep.options)
  program.registerModes(pipelineStep.index, pipelineStep.modes)
  if pipelineStep.defines.len() > 0:
    for define in pipelineStep.defines:
      program.defines.addFirst(define)

proc registerSteps[T](program: Program, pipelineSteps: seq[T]) =
  for pipelineStep in pipelineSteps:
    program.registerStep(pipelineStep)
    program.registeredSteps.add(pipelineStep)

proc initPipelineStep(pipelineStep: PipelineStep) =
  pipelineStep.index = stepIndex 
  inc(stepIndex)
  pipelineStep.options = @[]
  pipelineStep.modes = @[]
  pipelineStep.defines = @[]

proc newPipelineStep(options: seq[string] = @[], modes: seq[string] = @[]): PipelineStep =
  result = new(PipelineStep)
  initPipelineStep(result)
  result.options.insert(options)
  result.modes.insert(modes)

proc setStep(program: Program, stepKind: MaterialStepKind, enabled: bool = false) =
  var shaderSteps {.global.} = {
    mskBase: newPipelineStep(@["VERTEX_COLOR", "DOUBLE_SIDED", "FLAT_SHADED"]),
    mskAlpha: newPipelineStep(@["ALPHA_MAP", "ALPHA_TEST"]),
    mskSolid: newPipelineStep(@["COLOR_MAP"]),
    mskLine: newPipelineStep(@["DASH"]),
    mskPoint: newPipelineStep(),
    mskFresnel: newPipelineStep(),
    mskLit: newPipelineStep(@["NORMAL_MAP", "EMISSIVE", "AMBIENT_OCCLUSION", "LIGHTMAP", "DISPLACEMENT"]),
    mskPbr: newPipelineStep(@["ALBEDO_MAP", "ROUGHNESS_MAP", "METALLIC_MAP", "DEPTH_MAPPING", "DEEP_PARALLAX"], @["DIFFUSE_MODE", "SPECULAR_MODE"]),
    mskPhong: newPipelineStep(@["DIFFUSE_MAP", "SPECULAR_MAP", "SHININESS_MAP", "REFRACTION", "TOON"], @["ENV_BLEND"]),
    mskUser: newPipelineStep(),
  }.toTable()

  program.steps[stepKind] = true
  program.registerStep(shaderSteps[stepKind])

proc setSteps(program: Program, stepKinds: seq[MaterialStepKind]) =
  for stepKind in stepKinds:
    program.setStep(stepKind)

proc newMaterialStep(): MaterialStep =
  result = new(MaterialStep)
  initPipelineStep(result)

proc newFilterStep(): FilterStep =
  result = new(FilterStep)
  initPipelineStep(result)

proc newCopyStep(filterStep: FilterStep): CopyStep =
  result = new(CopyStep)
  initPipelineStep(result)
  result.filterStep = filterStep
  result.program = programs.create("filter/copy")
  result.program.registerStep(filterStep)

proc newDepthStep(): DepthStep =
  result = new(DepthStep)
  initPipelineStep(result)
  result.drawStep = true

proc newSkyStep(filterStep: FilterStep): SkyStep =
  result = new(SkyStep)
  initPipelineStep(result)
  result.filterStep = filterStep
  result.skyboxProgram = programs.create("skybox")
  result.skyboxProgram.registerStep(filterStep)

proc newParticlesStep(): ParticlesStep =
  result = new(ParticlesStep)
  initPipelineStep(result)
  result.sprites = newSpriteAtlas()

proc init(materialStep: MaterialStep) =
  materialStep.u_state = bgfx_create_uniform("u_state", BGFX_UNIFORM_TYPE_VEC4, 1)
  materialStep.u_state_vertex = bgfx_create_uniform("u_state_vertex", BGFX_UNIFORM_TYPE_VEC4, 1)
  materialStep.s_materials = bgfx_create_uniform("s_materials", BGFX_UNIFORM_TYPE_SAMPLER, 1)

proc init(filterStep: FilterStep) =
  filterStep.s_source_0 = bgfx_create_uniform("s_source_0", BGFX_UNIFORM_TYPE_SAMPLER, 1)
  filterStep.s_source_1 = bgfx_create_uniform("s_source_1", BGFX_UNIFORM_TYPE_SAMPLER, 1)
  filterStep.s_source_2 = bgfx_create_uniform("s_source_2", BGFX_UNIFORM_TYPE_SAMPLER, 1)
  filterStep.s_source_3 = bgfx_create_uniform("s_source_3", BGFX_UNIFORM_TYPE_SAMPLER, 1)
  filterStep.s_source_depth = bgfx_create_uniform("s_source_depth", BGFX_UNIFORM_TYPE_SAMPLER, 1)

  filterStep.u_filter_p0 = bgfx_create_uniform("u_filter_p0", BGFX_UNIFORM_TYPE_VEC4, 1)

  filterStep.u_source_levels = bgfx_create_uniform("u_source_levels", BGFX_UNIFORM_TYPE_VEC4, 1)
  filterStep.u_source_crop = bgfx_create_uniform("u_source_crop", BGFX_UNIFORM_TYPE_VEC4, 1)

proc newPipeline(): Pipeline =
  result = @[]

proc init(pipelineStep: PipelineStep) =
  discard

proc init*(pipeline: Pipeline) =
  for pipelineBlock in pipeline:
    pipelineBlock.init()

proc renderMinimal(renderCtx: RenderContext) =
  discard

proc minimalPipeline*(): Pipeline =
  result = newPipeline()
  result.add(newMaterialStep())
  
  let filterStep = newFilterStep()
  result.add(filterStep)
  result.add(newCopyStep(filterStep))

  let depthStep = newDepthStep()
  result.add(depthStep)
  result.add(newSkyStep(filterStep))
  result.add(newParticlesStep())

  let depthSteps = @[depthStep]

  let solid = programs.create("solid")
  solid.setSteps(@[mskAlpha, mskSolid])

  let depth = programs.create("depth")
  depth.registerSteps(depthSteps)
  depth.setSteps(@[mskAlpha])

  let distance = programs.create("distance")
  distance.registerSteps(depthSteps)
  distance.setSteps(@[mskAlpha])

  let pbr = programs.create("pbr/pbr")
  pbr.setSteps(@[mskAlpha, mskLit, mskPbr])

  let fresnel = programs.create("fresnel")
  fresnel.setSteps(@[mskAlpha, mskFresnel])

  renderers[skShaded] = renderMinimal
  renderers[skVolume] = renderMinimal

proc shutdown*() =
  bgfx_shutdown()