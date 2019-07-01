import sdl2, bgfxdotnim, bgfxdotnim / [platform], strutils, tables

const
  SDL_MAJOR_VERSION* = 2
  SDL_MINOR_VERSION* = 0
  SDL_PATCHLEVEL* = 5

type
  AssetStore[T] = Table[string, T]

  Program = ref object
    name: string

  Pipeline = seq[PipelineStep]
  
  PipelineStep = ref object of RootObj
    index: int

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

var
  pipeline: Pipeline = @[]
  programs: AssetStore[Program] = initTable[string, Program]()
  stepIndex = 1

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

proc new(program: typedesc[Program], name: string): Program =
  result = new(Program)
  result.name = name

proc createAsset[T](assetStore: var AssetStore[T], name: string): T =
  if assetStore.contains(name):
    echo "WARN: asset with name $1 already exists: previous asset deleted" % name
    assetStore.del(name)
  
  assetStore.add(name, new(T, name))
  result = assetStore[name]

proc registerStep(program: Program, pipelineStep: PipelineStep) =
  assert(pipelineStep.index < 32)

proc initPipelineStep(pipelineStep: PipelineStep) =
  pipelineStep.index = stepIndex 
  inc(stepIndex)

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
  result.program = programs.createAsset("filter/copy")
  result.program.registerStep(filterStep)

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

proc minimalPipeline*(): Pipeline =
  result = newPipeline()
  result.add(newMaterialStep())
  result.add(newFilterStep())


proc shutdown*() =
  bgfx_shutdown()