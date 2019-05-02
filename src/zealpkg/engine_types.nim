import  tables, strutils,
        math, geom,
        bgfxdotnim, rect_packer

proc currentSourceDir*(): string =
  result = currentSourcePath()
  when defined(windows):
    result = result[0 ..< result.rfind("\\")]
  else:
    result = result[0 ..< result.rfind("/")]

const
  ZEAL_DATA_DIR* = if defined(windows): currentSourceDir() & "..\\data" else: currentSourceDir() & "../data"
  MAX_LIGHTS* = 64
  MAX_SHADOWS* = 32
  MAX_FORWARD_LIGHTS* = 16
  MAX_DIRECT_LIGHTS* = 1
  MAX_REFLECTION_PROBES* = 16
  SPRITE_TEXTURE_SIZE* = 2048

type
  CArray*[T] = array[0..0, T]

  Color* = object
    r, g, b, a: float

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

  RenderPass* = ref object of RootObj
    name*: string
    renderPassKind*: RenderPassKind
    steps*: seq[PipelineStep]

  GIProbesPass* = ref object of RenderPass
    lightStep*: LightStep
    giBakeStep*: GIBakeStep
  
  ShadowmapPass* = ref object of RenderPass
    shadowStep*: ShadowStep

  Shading* = enum
    sWireframe, sUnshaded, sShaded, sVolume, sVoxels, sLightmap, sClear, sCount

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

  Radiance* = object
    energy: float
    ambient: float
    color: Color
    texture: Texture
    roughnessArray: bgfx_texture_handle_t
    preprocessed: bool

  RadianceUniform* = object
    radianceMap*: bgfx_uniform_handle_t

  PrefilterUniform* = object
    prefilterEnvmapParams*: bgfx_uniform_handle_t

  RadianceStep* = ref object of DrawStep
    radiance*: RadianceUniform
    prefilter*: PrefilterUniform
    filter*: FilterStep
    copy*: CopyStep
    prefilterProgram*: Program
    prefilterQueue*: seq[Radiance]
    prefiltered*: Table[uint16, uint16]

  DirectionalShadowUniform* = object
    csmAtlas*: bgfx_uniform_handle_t
    csmParams*: bgfx_uniform_handle_t

  ShadowUniform* = object
    shadowAtlas*: bgfx_uniform_handle_t
    shadowPixelSize*: bgfx_uniform_handle_t

  CSMFilterMode* = enum
    csmfmNoPCF, csmfmHardPCF, csmfmPCF5, csmfmPCF13

  CSMShadow* = object
    size*: int
    fbo*: bgfx_frame_buffer_handle_t
    depth*: bgfx_texture_handle_t
    filterMode*: CSMFilterMode

  ShadowCubemap* = object
    size: int
    fbos: array[6, bgfx_frame_buffer_handle_t]
    cubemap: bgfx_texture_handle_t

  ShadowAtlas* = object
    size: int
    depth: bgfx_texture_handle_t
    fbo: bgfx_frame_buffer_handle_t
    cubemaps: seq[ShadowCubemap]

  Frustum* = object
    fov: float
    aspect: float
    near: float
    far: float
    center: Vec3
    radius: float

  FrustumSlice* = object
    index: int
    frustum: Frustum

  LightBounds* = object
    min: Vec3
    max: Vec3

  Item* = object
    transform: Mat4
    model: Model
    skin: int

  Slice* = object
    viewportRect: Vec4
    textureRect: Vec4
    projection: Mat4
    transform: Mat4
    shadowMatrix: Mat4
    biasScale: float
    frustumSlice: FrustumSlice
    lightBounds: LightBounds
    items: seq[Item]

  LightShadow* = object
    frustumSlices: seq[FrustumSlice]
    slices: seq[Slice]

  ShadowStep* = ref object of DrawStep
    depthStep*: DepthStep
    depthParams*: DepthParams
    directLight*: Light
    directShadow*: DirectionalShadowUniform
    shadow*: ShadowUniform
    atlas*: ShadowAtlas
    shadows*: seq[LightShadow]
    csm*: CSMShadow
    pcfLevel*: CSMFilterMode

  LightUniform* = object
    lightPositionRange*: bgfx_uniform_handle_t
    lightEnergySpecular*: bgfx_uniform_handle_t
    lightDirectionAttenuation*: bgfx_uniform_handle_t
    lightShadow*: bgfx_uniform_handle_t
    lightShadowMatrix*: bgfx_uniform_handle_t
    lightSpotParams*: bgfx_uniform_handle_t
    csmMatrix*: bgfx_uniform_handle_t
    csmSplits*: bgfx_uniform_handle_t

  ShotUniform* = object
    lightIndices*: bgfx_uniform_handle_t
    lightCounts*: bgfx_uniform_handle_t
    lightArray*: LightUniform

  SceneUniform* = object
    radianceColorEnergy*: bgfx_uniform_handle_t
    ambientParams*: bgfx_uniform_handle_t

  FogUniform* = object
    fogParams0*: bgfx_uniform_handle_t
    fogParams1*: bgfx_uniform_handle_t
    fogParams2*: bgfx_uniform_handle_t
    fogParams3*: bgfx_uniform_handle_t
  
  LightArray*[numLights: static int, numDirect: static int] = object
    positionRange: array[numLights, Vec4]
    energySpecular: array[numLights, Vec4]
    directionAttenuation: array[numLights, Vec4]
    shadowColorEnabled: array[numLights, Vec4]
    shadowMatrix: array[numLights, Mat4]
    spotParams: array[numLights, Vec4]

    lightIndices: array[numLights, Vec4]
    lightCounts: Vec4

    csmMatrix: array[4, array[numDirect, Mat4]]
    csmSplits: array[numDirect, Vec4]

  LightStep* = ref object of DrawStep
    shadowStep*: ShadowStep
    directLightIndex*: int
    directLights*: seq[Light]
    shot*: ShotUniform
    scene*: SceneUniform
    fog*: FogUniform
    lightsData: LightArray[MAX_LIGHTS, MAX_DIRECT_LIGHTS]
    lightCount*: int

  ReflectionUniform* = object
    extentsIntensity: bgfx_uniform_handle_t
    ambient: bgfx_uniform_handle_t
    atlasRect: bgfx_uniform_handle_t
    matrix: bgfx_uniform_handle_t

    indices: bgfx_uniform_handle_t
    count: bgfx_uniform_handle_t

    atlas: bgfx_uniform_handle_t

  ReflectionCubemap* = object
    size*: int
    fbo*: array[6, bgfx_frame_buffer_handle_t]
    cubemap*: bgfx_texture_handle_t
    depth*: bgfx_texture_handle_t

  Scene* = ref object

  Node3* = object
    scene*: Scene
    index*: int
    transform*: Mat4
    visible*: bool
    lastUpdated*: int

  ReflectionProbe* = object
    node*: Node3
    visible*: bool
    intensity*: float
    extents*: Vec3
    shadows*: bool
    atlas*: ReflectionAtlas
    atlasIndex*: int
    dirty*: bool

  Slot* = object
    index*: int
    probe*: ReflectionProbe
    rect*: Vec4
    lastUpdate: int

  ReflectionAtlas* = object
    size*: int
    subdiv*: int
    colorTex*: bgfx_texture_handle_t

  ReflectionStep* = ref object of DrawStep
    uniform*: ReflectionUniform
    cubemaps*: seq[ReflectionCubemap]
    atlas*: ReflectionAtlas
    reflectionMultiplier*: float

  GIProbeUniform* = object
    transform*: bgfx_uniform_handle_t
    bounds*: bgfx_uniform_handle_t
    params*: bgfx_uniform_handle_t
    invExtents*: bgfx_uniform_handle_t
    cellSize*: bgfx_uniform_handle_t
    
    giProbe*: bgfx_uniform_handle_t

  GITraceStep* = ref object of DrawStep
    giProbe*: GIProbeUniform

  VoxelGIUniform* = object
    voxelsAlbedo*: bgfx_uniform_handle_t
    voxelsNormals*: bgfx_uniform_handle_t
    voxelsLight*: bgfx_uniform_handle_t

    voxelsLightRGBA*: bgfx_uniform_handle_t

    world*: bgfx_uniform_handle_t
    normal*: bgfx_uniform_handle_t

    params0*: bgfx_uniform_handle_t
    params1*: bgfx_uniform_handle_t

  GIProbeMode* = enum
    gipmVoxelize, gipmLoadVoxels
  
  GIProbe* = ref object
    node*: Node3
    raster*: bgfx_texture_handle_t
    voxelsColor*: bgfx_texture_handle_t
    voxelsNormals*: bgfx_texture_handle_t
    voxelsLight*: bgfx_texture_handle_t
    fbo*: bgfx_frame_buffer_handle_t

    voxelsLightRGBA*: bgfx_texture_handle_t
    enabled*: bool
    transform*: Mat4
    subdiv*: int
    extents*: Vec3
    mode*: GIProbeMode
    dirty*: bool

    dynamicRange*: int
    diffuse*: float
    specular*: float
    bounces*: int
    propagation*: float

    bias*: float
    normalBias*: float

  GIBakeStep* = ref object of DrawStep
    lightStep*: LightStep
    giTraceStep*: GITraceStep
    voxelGI*: VoxelGIUniform
    directLight*: Program
    bounceLight*: Program
    outputLight*: Program
    voxelize*: Program
    bakeProbe*: GIProbe
    directLightCompute*: bool

  LightmapVoxelGIUniform* = object
    lightmap*: bgfx_uniform_handle_t

  LightmapItem* = object
    size*: int
    lightmap*: bgfx_texture_handle_t
    uvScaleOffset*: Vec4

  Image* = ref object of RootObj
    name*: string
    path*: string

    size*: IVec2
    coord*: IVec2

    handle*: int
    atlas*: ImageAtlas

    tile*: bool
    stretch*: bool
    filtering*: bool

  ImageAtlas* = ref object of RootObj
    size*: IVec2
    inverseSize*: Vec2

    image*: Image
    images*: seq[Image]

    rectPack*: RectPacker

  TextureAtlas* = ref object of ImageAtlas
    textures*: seq[Image]

  Lightmap* = object
    size: int
    density: float
    dirty: bool

    atlas: TextureAtlas
    texture: bgfx_texture_handle_t

    items: seq[LightmapItem]

  LightmapAtlas* = ref object
    size*: int
    density*: float
    dirty*: bool
    savePath*: string

    captureTransform*: Mat4
    captureExtents*: Vec3

    layers*: seq[Lightmap]

  BakeEntry* = object
    scene*: Scene
    atlas*: LightmapAtlas

  LightmapStep* = ref object of DrawStep
    lightStep*: LightStep
    giBakeStep*: GIBakeStep
    lightmapUniform*: LightmapVoxelGIUniform
    lightmapProgram*: Program
    bakeQueue*: seq[BakeEntry]

  Sprite* = ref object of Image
    frames*: IVec2
    numFrames*: int
    frameSize*: IVec2
    frameUVs*: seq[Vec4]

  SpriteAtlas* = ref object of ImageAtlas
    sprites*: seq[Sprite]

  ParticlesStep* = ref object of PipelineStep
    sprites*: SpriteAtlas
    texture*: bgfx_texture_handle_t

    color*: bgfx_uniform_handle_t

  ResolveStep* = ref object of PipelineStep
    copyStep*: CopyStep

  DOFBlurUniform* = object
    dofNearParams*: bgfx_uniform_handle_t
    dofFarParams*: bgfx_uniform_handle_t
    dofParams*: bgfx_uniform_handle_t

  DOFBlurStep* = ref object of PipelineStep
    filterStep*: FilterStep
    uniform*: DOFBlurUniform
    program*: Program

  GlowUniform* = object
    glowParams0*: bgfx_uniform_handle_t
    glowParams1*: bgfx_uniform_handle_t
    glowParams14*: bgfx_uniform_handle_t
    glowParams58*: bgfx_uniform_handle_t

  GlowStep* = ref object of PipelineStep
    filterStep*: FilterStep
    copyStep*: CopyStep
    blurStep*: BlurStep

    uniform*: GlowUniform

    bleedProgram*: Program
    mergeProgram*: Program

  TonemapUniform* = object
    bcs*: bgfx_uniform_handle_t
    exposureParams*: bgfx_uniform_handle_t

  TonemapStep* = ref object of PipelineStep
    filterStep*: FilterStep
    copyStep*: CopyStep

    uniform*: TonemapUniform
    program*: Program

  PipelineKind* = enum
    pkPbr, pkCount

  Pipeline* = object
    steps*: seq[PipelineStep]
    passSteps*: Table[RenderPassKind, seq[PipelineStep]]

  Renderer* = ref object of RootObj
    steps*: seq[PipelineStep]
    renderPasses*: seq[RenderPass]
    shading*: Shading
    pipeline*: Pipeline

  ShaderKind* = enum
    skCompute, skFragment, skGeometry, skVertex, skCount
  
  ShaderDefine* = object
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

  Model* = ref object

  Texture* = ref object

  Light* = ref object

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

proc newDrawStep*[T](): T =
  result = newPipelineStep[T]()
  result.drawStep = true

proc beginFrame*[T](s: T, frame: RenderFrame) =
  discard frame

proc beginPass*(s: PipelineStep, r: var Render) =
  discard r

proc beginRender*(s: PipelineStep, r: var Render) =
  discard r

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

proc newRenderer*[T](gfx: var GfxCtx, p: var Pipeline, s: Shading): T =
  result = new(T)
  result.pipeline = p
  result.shading = s

proc addPass*[T](r: var T, rp: RenderPass): RenderPass =
  result = rp
  r.renderPasses.add(result)

proc newColor*(r= 1.0, g = 1.0, b = 1.0, a = 1.0): Color = 
  result = Color(r: r, g: g, b: b, a: a)

const
  BLACK* = newColor(0.0, 0.0, 0.0, 0.0)