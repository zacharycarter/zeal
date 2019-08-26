import bgfxdotnim, texture, ../../lib/bimgdotnim/bimg, fpmath, shader, tables, camera_new

const 
  BUFFER_SUBD = 0
  NUM_VEC_4 = 2

type
  ShadingKind = enum
    skTerrainNormal
    skTerrain
    skCount
  
  ProgramKind = enum
    pkSubdCsLod
    pkUpdateIndirect
    pkInitIndirect
    pkUpdateDraw
    
    pkCount

  SamplerKind = enum
    skDmapSampler
    skSmapSampler
    
    skSamplerCount

  TextureKind = enum
    tkDmap
    tkSmap
    tkCount
  
  UniformValue = object
    dmapFactor: float32
    lodFactor: float32
    cull: float32
    freeze: float32

    gpuSubd: float32
    padding0: float32
    padding1: float32
    padding2: float32
  
  UniformData {.union.} = object
    value: UniformValue
    params: array[NUM_VEC_4 * 4, float32]

  Uniforms = object
    data: UniformData
    handle: bgfx_uniform_handle_t
  
  DisplacementMap = object
    filePath: string
    scale: float32

var
  fovY = 60.0'f32
  primitivePixelLengthTarget = 7.0'f32

  sVerticesL0 = [
    0.0'f32, 0.0,
    1.0,     0.0,
    0.0,     1.0
  ]

  sIndicesL0 = [
    0'u32, 1, 2
  ]

  sVerticesL1 = [
    0.0'f32, 1.0,
    0.5,     0.5,
    0.0,     0.5,
    0.0,     0.0,
    0.5,     0.0,
    1.0,     0.0
  ]

  sIndicesL1 = [
    1'u32, 0, 2,
    1,     2, 3,
    1,     3, 4,
    1,     4, 5
  ]

  sVerticesL2 = [
    0.25'f32, 0.75,
    0.0,      1.0,
    0.0,      0.75,
    0.0,      0.5,
    0.25,     0.5,
    0.5,      0.5,

    0.25,     0.25,
    0.0,      0.25,
    0.0,      0.0,
    0.25,     0.0,
    0.5,      0.0,
    0.5,      0.25,
    0.75,     0.25,
    0.75,     0.0,
    1.0,      0.0
  ]

  sIndicesL2 = [
    0'u32, 1, 2,
    0,     2, 3,
    0,     3, 4,
    0,     4, 5,

    6,     5, 4,
    6,     4, 3,
    6,     3, 7,
    6,     7, 8,

    6,     8, 9,
    6,     9, 10,
    6,     10, 11,
    6,     11, 5,

    12,     5, 11,
    12,     11, 10,
    12,     10, 13,
    12,     13, 14
  ]

  sVerticesL3 = [
    0.25'f32*0.5, 0.75*0.5 + 0.5,
    0.0*0.5,      1.0*0.5 + 0.5,
    0.0*0.5,      0.75*0.5 + 0.5,
    0.0*0.5 ,     0.5*0.5 + 0.5,
    0.25*0.5,     0.5*0.5 + 0.5,
    0.5*0.5,      0.5*0.5 + 0.5,
    0.25*0.5,     0.25*0.5 + 0.5,
    0.0*0.5,      0.25*0.5 + 0.5,
    0.0*0.5,      0.0*0.5 + 0.5,
    0.25*0.5,     0.0*0.5 + 0.5,
    0.5*0.5,      0.0*0.5 + 0.5,
    0.5*0.5,      0.25*0.5 + 0.5,
    0.75*0.5,     0.25*0.5 + 0.5,
    0.75*0.5,     0.0*0.5 + 0.5,
    1.0*0.5,      0.0*0.5 + 0.5,

    0.375,        0.375,
    0.25,         0.375,
    0.25,         0.25,
    0.375,        0.25,
    0.5,          0.25,
    0.5,          0.375,

    0.125,        0.375,
    0.0,          0.375,
    0.0,          0.25,
    0.125,        0.25,

    0.125,        0.125,
    0.0,          0.125,
    0.0,          0.0,
    0.125,        0.0,
    0.25,         0.0,
    0.25,         0.125,

    0.375,        0.125,
    0.375,        0.0,
    0.5,          0.0,
    0.5,          0.125,

    0.625,        0.375,
    0.625,        0.25,
    0.75,         0.25,

    0.625,        0.125,
    0.625,        0.0,
    0.75,         0.0,
    0.75,         0.125,

    0.875,        0.125,
    0.875,        0.0,
    1.0,          0.0,
  ]

  sIndicesL3 = [
    0'u32, 1, 2,
    0,     2, 3,
    0,     3, 4,
    0,     4, 5,

    6,     5, 4,
    6,     4, 3,
    6,     3, 7,
    6,     7, 8,

    6,     8, 9,
    6,     9, 10,
    6,     10, 11,
    6,     11, 5,

    12,    5, 11,
    12,    11, 10,
    12,    10, 13,
    12,    13, 14,

    15,    14, 13,
    15,    13, 10,
    15,    10, 16,
    15,    16, 17,
    15,    17, 18,
    15,    18, 19,
    15,    19, 20,
    15,    20, 14,

    21,    10, 9,
    21,    9, 8,
    21,    8, 22,
    21,    22, 23,
    21,    23, 24,
    21,    24, 17,
    21,    17, 16,
    21,    16, 10,

    25,    17, 24,
    25,    24, 23,
    25,    23, 26,
    25,    26, 27,
    25,    27, 28,
    25,    28, 29,
    25,    29, 30,
    25,    30, 17,

    31,    19, 18,
    31,    18, 17,
    31,    17, 30,
    31,    30, 29,
    31,    29, 32,
    31,    32, 33,
    31,    33, 34,
    31,    34, 19,

    35,    14, 20,
    35,    20, 19,
    35,    19, 36,
    35,    36, 37,

    38,    37, 36,
    38,    36, 19,
    38,    19, 34,
    38,    34, 33,
    38,    33, 39,
    38,    39, 40,
    38,    40, 41,
    38,    41, 37,

    42,    37, 41,
    42,    41, 40,
    42,    40, 43,
    42,    43, 44,
  ]

var 
  dMap: ptr ImageContainer
  dispMap: DisplacementMap = DisplacementMap(filePath: "assets/map_textures/dmap.png", scale: 0.45'f32)
  textures: array[tkCount, bgfx_texture_handle_t]
  samplers: array[skSamplerCount, bgfx_uniform_handle_t]
  uniforms: Uniforms
  bufferSubd: array[2, bgfx_dynamic_index_buffer_handle_t]
  bufferCulledSubd: bgfx_dynamic_index_buffer_handle_t
  geometryLayout: bgfx_vertex_layout_t
  geometryVertices: bgfx_vertex_buffer_handle_t
  geometryIndices: bgfx_index_buffer_handle_t
  instancedGeometryLayout: bgfx_vertex_layout_t
  instancedGeometryVertices: bgfx_vertex_buffer_handle_t
  instancedGeometryIndices: bgfx_index_buffer_handle_t
  bufferCounter: bgfx_dynamic_index_buffer_handle_t
  dispatchIndirect: bgfx_indirect_buffer_handle_t
  pingPong = 0
  restart = true
  instancedMeshVertexCount: uint32
  instancedMeshPrimitiveCount: uint32
  viewMtx: Mat4
  projMtx: Mat4

proc loadSubdivisionMapTexture() =
  let
    w = int(dMap[].m_width)
    h = int(dMap[].m_height)
    texels = cast[ptr UncheckedArray[uint16]](dmap[].m_data)
    mipCnt = dMap[].m_numMips
    mem = bgfx_alloc(uint32(w * h * 2 * sizeof(float32)))

  var sMap = cast[ptr UncheckedArray[float32]](mem[].data)
  
  for j in 0 ..< h:
    for i in 0 ..< w:
      let
        i1 = max(0, i - 1)
        i2 = min(w - 1, i + 1)
        j1 = max(0, j - 1)
        j2 = min(h - 1, j + 1)
        pxL = texels[i1 + w * j]
        pxR = texels[i2 + w * j]
        pxB = texels[i + w * j1]
        pxT = texels[i + w * j2]
        zL = float32(pxL) / 65535.0
        zR = float32(pxR) / 65535.0
        zB = float32(pxB) / 65535.0
        zT = float32(pxT) / 65535.0
        slopeX = float32(w) * 0.5 * (zR - zL)
        slopeY = float32(h) * 0.5 * (zT - zB)
      
      smap[2 * (i + w * j)] = slopeX
      smap[1 + 2 * (i + w * j)] = slopeY
  
  textures[tkSmap] = bgfx_create_texture_2d(
    uint16(w), uint16(h), mipCnt > 1'u8, 1, BGFX_TEXTURE_FORMAT_RG32F, BGFX_TEXTURE_NONE, mem
  )

proc loadDisplacementMapTexture() =
  dMap = bimgLoad(dispMap.filePath, BGFX_TEXTURE_FORMAT_R16)
  
  textures[tkDmap] = bgfx_create_texture_2d(
    uint16(dMap[].m_width), 
    uint16(dMap[].m_height), 
    false, 
    1, 
    BGFX_TEXTURE_FORMAT_R16, 
    BGFX_TEXTURE_NONE, 
    bgfx_make_ref(dmap[].m_data, dmap[].m_size)
  )

proc initUniforms() =
  uniforms.handle = bgfx_create_uniform("u_params", BGFX_UNIFORM_TYPE_VEC4, NUM_VEC_4)
  
  uniforms.data.value.cull = 1
  uniforms.data.value.freeze = 0
  uniforms.data.value.gpuSubd = 3

proc createAtomicCounters() =
  bufferCounter = bgfx_create_dynamic_index_buffer(3, BGFX_BUFFER_INDEX32 or BGFX_BUFFER_COMPUTE_READ_WRITE)

proc loadInstancedGeometryBuffers() =
  var 
    vertices: ptr UncheckedArray[float32]
    indicies: ptr UncheckedArray[uint32]

  instancedMeshVertexCount = 45
  instancedMeshPrimitiveCount = 64
  vertices = cast[ptr UncheckedArray[float32]](addr s_verticesL3[0])
  indicies = cast[ptr UncheckedArray[uint32]](addr s_indicesL3[0])

  bgfx_vertex_layout_begin(addr instancedGeometryLayout, BGFX_RENDERER_TYPE_NOOP)
  bgfx_vertex_layout_add(addr instancedGeometryLayout, BGFX_ATTRIB_TEXCOORD0, 2, BGFX_ATTRIB_TYPE_FLOAT, false, false)
  bgfx_vertex_layout_end(addr instancedGeometryLayout)

  instancedGeometryVertices = bgfx_create_vertex_buffer(
    bgfx_make_ref(vertices, uint32(sizeof(float32)) * 2'u32 * instancedMeshVertexCount), 
    addr instancedGeometryLayout, 
    BGFX_BUFFER_NONE
  )
  instancedGeometryIndices = bgfx_create_index_buffer(
    bgfx_make_ref(indicies, uint32(sizeof(uint32)) * instancedMeshPrimitiveCount * 3), 
    BGFX_BUFFER_INDEX32
  )

proc loadGeometryBuffers() =
  var 
    vertices = [
      -1.0'f32, -1.0, 0.0, 1.0,
      1.0, -1.0, 0.0, 1.0,
      1.0, 1.0, 0.0, 1.0,
      -1.0, 1.0, 0.0, 1.0,
    ]
    indices = [0'u32, 1, 3, 2, 3, 1]
  
  bgfx_vertex_layout_begin(addr geometryLayout, BGFX_RENDERER_TYPE_NOOP)
  bgfx_vertex_layout_add(addr geometryLayout, BGFX_ATTRIB_POSITION, 4, BGFX_ATTRIB_TYPE_FLOAT, false, false)
  bgfx_vertex_layout_end(addr geometryLayout)

  geometryVertices = bgfx_create_vertex_buffer(
    bgfx_copy(cast[pointer](addr vertices[0]), uint32(sizeof(vertices))), 
    addr geometryLayout, 
    BGFX_BUFFER_COMPUTE_READ
  )

  geometryIndices = bgfx_create_index_buffer(
    bgfx_copy(cast[pointer](addr indices[0]), 
    uint32(sizeof(indices))), 
    BGFX_BUFFER_COMPUTE_READ or BGFX_BUFFER_INDEX32
  )

proc loadSubdivisionBuffers() =
  let bufferCapacity: uint32 = 1 shl 27

  bufferSubd[0] = bgfx_create_dynamic_index_buffer(
    bufferCapacity, 
    BGFX_BUFFER_COMPUTE_READ_WRITE or BGFX_BUFFER_INDEX32
  )
  bufferSubd[1] = bgfx_create_dynamic_index_buffer(
    bufferCapacity, 
    BGFX_BUFFER_COMPUTE_READ_WRITE or BGFX_BUFFER_INDEX32
  )
  bufferCulledSubd = bgfx_create_dynamic_index_buffer(
    bufferCapacity, 
    BGFX_BUFFER_COMPUTE_READ_WRITE or BGFX_BUFFER_INDEX32
  )

proc loadTextures() =
  loadDisplacementMapTexture()
  loadSubdivisionMapTexture()

proc loadBuffers() =
  loadSubdivisionBuffers()
  loadGeometryBuffers()
  loadInstancedGeometryBuffers()

proc loadPrograms() =
  samplers[skDmapSampler] = bgfx_create_uniform("u_DmapSampler", BGFX_UNIFORM_TYPE_SAMPLER, 1)
  samplers[skSmapSampler] = bgfx_create_uniform("u_SmapSampler", BGFX_UNIFORM_TYPE_SAMPLER, 1)

  initUniforms()

proc configureUniforms() =
  let lodFactor = 2.0'f32 * tan(degToRad(fovY) / 2.0'f32) / 1280 * float32(1 shl int(uniforms.data.value.gpuSubd)) * primitivePixelLengthTarget

  uniforms.data.value.lodFactor = lodFactor
  uniforms.data.value.dmapFactor = dispMap.scale

proc submitUniforms() =
  bgfx_set_uniform(uniforms.handle, cast[pointer](addr uniforms.data.params[0]), NUM_VEC_4)

proc updateNewTerrain*() =
  uniforms.data.value.cull = 1.0'f32
  uniforms.data.value.freeze = 0.0'f32
  uniforms.data.value.gpuSubd = 3.0'f32
  
  bgfx_touch(0)
  bgfx_touch(1)

  configureUniforms()

  getCameraViewMtx(viewMtx)

  var model: Mat4

  mtxRotateX(model, degToRad(90.0))

  mtxProj(projMtx, fovY, 1280.0'f32 / 720.0'f32, 0.0001'f32, 2000.0'f32, bgfx_get_caps()[].homogeneousDepth)

  bgfx_set_view_transform(0, addr viewMtx[0], addr projMtx[0])

  bgfx_set_view_rect(1, 0, 0, 1280'u16, 720'u16)
  bgfx_set_view_transform(1, addr viewMtx[0], addr projMtx[0])

  submitUniforms()

  if restart:
    pingPong = 1

    bgfx_destroy_vertex_buffer(instancedGeometryVertices)
    bgfx_destroy_index_buffer(instancedGeometryIndices)

    bgfx_destroy_dynamic_index_buffer(bufferSubd[0])
    bgfx_destroy_dynamic_index_buffer(bufferSubd[1])
    bgfx_destroy_dynamic_index_buffer(bufferCulledSubd)

    loadInstancedGeometryBuffers()
    loadSubdivisionBuffers()

    bgfx_set_compute_dynamic_index_buffer(1, bufferSubd[pingPong], BGFX_ACCESS_READWRITE)
    bgfx_set_compute_dynamic_index_buffer(2, bufferCulledSubd, BGFX_ACCESS_READWRITE)
    bgfx_set_compute_indirect_buffer(3, dispatchIndirect, BGFX_ACCESS_READWRITE)
    bgfx_set_compute_dynamic_index_buffer(4, bufferCounter, BGFX_ACCESS_READWRITE)
    bgfx_set_compute_dynamic_index_buffer(8, bufferSubd[1 - pingPong], BGFX_ACCESS_READWRITE)
    bgfx_dispatch(0, programHandles["terrainInitIndirect"], 1, 1, 1)

    restart = false
  
  else:
    bgfx_set_compute_indirect_buffer(3, dispatchIndirect, BGFX_ACCESS_READWRITE)
    bgfx_set_compute_dynamic_index_buffer(4, bufferCounter, BGFX_ACCESS_READWRITE)
    bgfx_dispatch(0, programHandles["terrainUpdateIndirect"], 1, 1, 1)
  
  bgfx_set_compute_dynamic_index_buffer(1, bufferSubd[pingPong], BGFX_ACCESS_READWRITE)
  bgfx_set_compute_dynamic_index_buffer(2, bufferCulledSubd, BGFX_ACCESS_READWRITE)
  bgfx_set_compute_dynamic_index_buffer(4, bufferCounter, BGFX_ACCESS_READWRITE)
  bgfx_set_compute_vertex_buffer(6, geometryVertices, BGFX_ACCESS_READ)
  bgfx_set_compute_index_buffer(7, geometryIndices, BGFX_ACCESS_READ)
  bgfx_set_compute_dynamic_index_buffer(8, bufferSubd[1 - pingPong], BGFX_ACCESS_READ)
  discard bgfx_set_transform(addr model[0], 1)

  bgfx_set_texture(0, samplers[skDmapSampler], textures[tkDmap], BGFX_SAMPLER_U_CLAMP or BGFX_SAMPLER_V_CLAMP)

  submitUniforms()

  bgfx_dispatch_indirect(0, programHandles["terrainLOD"], dispatchIndirect, 1, 1)

  bgfx_set_compute_indirect_buffer(3, dispatchIndirect, BGFX_ACCESS_READWRITE)
  bgfx_set_compute_dynamic_index_buffer(4, bufferCounter, BGFX_ACCESS_READWRITE)

  submitUniforms()

  bgfx_dispatch(1, programHandles["terrainUpdateDraw"], 1, 1, 1)

  bgfx_set_texture(0, samplers[skDmapSampler], textures[tkDmap], BGFX_SAMPLER_U_CLAMP or BGFX_SAMPLER_V_CLAMP)
  bgfx_set_texture(1, samplers[skSmapSampler], textures[tkSmap], BGFX_SAMPLER_MIN_ANISOTROPIC or BGFX_SAMPLER_MAG_ANISOTROPIC)

  discard bgfx_set_transform(addr model[0], 1)
  bgfx_set_vertex_buffer(0, instancedGeometryVertices, 0, uint32.high)
  bgfx_set_index_buffer(instancedGeometryIndices, 0, uint32.high)
  bgfx_set_compute_dynamic_index_buffer(2, bufferCulledSubd, BGFX_ACCESS_READ)
  bgfx_set_compute_vertex_buffer(3, geometryVertices, BGFX_ACCESS_READ)
  bgfx_set_compute_index_buffer(4, geometryIndices, BGFX_ACCESS_READ)
  bgfx_set_state(BGFX_STATE_WRITE_RGB or BGFX_STATE_WRITE_Z or BGFX_STATE_DEPTH_TEST_LESS, 0)
  
  submitUniforms()

  bgfx_submit_indirect(1, programHandles["terrainRender"], dispatchIndirect, 0, 1, 0, true)
  
  pingPong = 1 - pingPong

  discard bgfx_frame(false)

proc initNewTerrain*() =
  bgfx_set_view_clear(0, BGFX_CLEAR_COLOR or BGFX_CLEAR_DEPTH, 0x303030ff, 1.0'f32, 0)
  bgfx_set_view_clear(1, BGFX_CLEAR_COLOR or BGFX_CLEAR_DEPTH, 0x303030ff, 1.0'f32, 0)

  createCamera()
  setCameraPosition([0.0'f32, 0.5, 0.0])
  setCameraVerticalAngle(0)

  loadPrograms()
  loadBuffers()
  loadTextures()

  createAtomicCounters()

  dispatchIndirect = bgfx_create_indirect_buffer(2) 