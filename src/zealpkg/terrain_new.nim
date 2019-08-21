import bgfxdotnim, texture, stb_image/read as stbi

const 
  BUFFER_SUBD = 0
  NUM_VEC_4: uint16 = 2

type
  ShadingKind = enum
    skTerrainNormal
    skTerrain
    skCount
  
  ProgramKind = enum
    pkSubdCsLod
    pkUpdateIndirect
    pkIndirect
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
    params: bgfx_uniform_handle_t
  
  DisplacementMap = object
    filePath: string
    scale: float32
    img: Image

var
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
  dMap: DisplacementMap
  samplers: array[skSamplerCount, bgfx_uniform_handle_t]
  uParams: bgfx_uniform_handle_t
  uniforms: Uniforms
  bufferSubd: array[2, bgfx_dynamic_index_buffer_handle_t]
  bufferCulledSubd: bgfx_dynamic_index_buffer_handle_t
  geometryDecl: bgfx_vertex_decl_t
  geometryVertices: bgfx_vertex_buffer_handle_t
  geometryIndices: bgfx_index_buffer_handle_t
  instancedGeometryDecl: bgfx_vertex_decl_t
  instancedGeometryVertices: bgfx_vertex_buffer_handle_t
  instancedGeometryIndices: bgfx_index_buffer_handle_t
  bufferCounter: bgfx_dynamic_index_buffer_handle_t
  dispatchIndirect: bgfx_indirect_buffer_handle_t

proc loadSubdivisionMapTexture() =
  let
    w = dMap.img.width
    h = dMap.img.height
  
  



proc loadDisplacementMapTexture() =
  dMap.img.data = stbi.load("assets/map_textures/dmap.png", dMap.img.width, dMap.img.height, dMap.img.numChannels, stbi.Default)

  let
    mem = bgfx_copy(
      cast[pointer](addr dMap.img.data[0]), 
      uint32(len(dMap.img.data) * sizeof(uint8) * 2)
    )
    dMapTexHandle = bgfx_create_texture_2d(uint16(dMap.img.width), uint16(dMap.img.height), false, 1, BGFX_TEXTURE_FORMAT_R16, BGFX_TEXTURE_NONE, mem)

proc init(u: var Uniforms) =
  u.params = bgfx_create_uniform("u_params", BGFX_UNIFORM_TYPE_VEC4, NUM_VEC_4)
  
  u.data.value.cull = 1
  u.data.value.freeze = 0
  u.data.value.gpuSubd = 3

proc createAtomicCounters() =
  bufferCounter = bgfx_create_dynamic_index_buffer(3, BGFX_BUFFER_INDEX32 or BGFX_BUFFER_COMPUTE_READ_WRITE)

proc loadInstancedGeometryBuffers() =
  bgfx_vertex_decl_begin(addr instancedGeometryDecl, bgfx_get_renderer_type())
  bgfx_vertex_decl_add(addr instancedGeometryDecl, BGFX_ATTRIB_TEXCOORD0, 2, BGFX_ATTRIB_TYPE_FLOAT, false, false)
  bgfx_vertex_decl_end(addr instancedGeometryDecl)

  instancedGeometryVertices = bgfx_create_vertex_buffer(bgfx_copy(cast[pointer](addr sVerticesL3[0]), uint32(sizeof(uint32) * 45 * 3)), addr instancedGeometryDecl, BGFX_BUFFER_NONE)
  instancedGeometryIndices = bgfx_create_index_buffer(bgfx_copy(cast[pointer](addr sIndicesL3[0]), uint32(sizeof(uint32) * 64 * 3)), BGFX_BUFFER_INDEX32)

proc loadGeometryBuffers() =
  var 
    vertices = [
      -1.0'f32, -1.0, 0.0, 1.0,
      1.0, -1.0, 0.0, 1.0,
      1.0, 1.0, 0.0, 1.0,
      -1.0, 1.0, 0.0, 1.0,
    ]
    indices = [0, 1, 3, 2, 3, 1]
  
  bgfx_vertex_decl_begin(addr geometryDecl, bgfx_get_renderer_type())
  bgfx_vertex_decl_add(addr geometryDecl, BGFX_ATTRIB_POSITION, 4, BGFX_ATTRIB_TYPE_FLOAT, false, false)
  bgfx_vertex_decl_end(addr geometryDecl)

  geometryVertices = bgfx_create_vertex_buffer(bgfx_copy(cast[pointer](addr vertices[0]), uint32(sizeof(vertices))), addr geometryDecl, BGFX_BUFFER_COMPUTE_READ)
  geometryIndices = bgfx_create_index_buffer(bgfx_copy(cast[pointer](addr indices[0]), uint32(sizeof(indices))), BGFX_BUFFER_COMPUTE_READ or BGFX_BUFFER_INDEX32)

proc loadSubdivisionBuffers() =
  let bufferCapacity: uint32 = 1 shl 27

  bufferSubd[0] = bgfx_create_dynamic_index_buffer(bufferCapacity, BGFX_BUFFER_COMPUTE_READ or BGFX_BUFFER_INDEX32)
  bufferSubd[1] = bgfx_create_dynamic_index_buffer(bufferCapacity, BGFX_BUFFER_COMPUTE_READ or BGFX_BUFFER_INDEX32)
  bufferCulledSubd = bgfx_create_dynamic_index_buffer(bufferCapacity, BGFX_BUFFER_COMPUTE_READ or BGFX_BUFFER_INDEX32)

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

  uniforms.init()

proc initNewTerrain*() =
  bgfx_set_view_clear(1, BGFX_CLEAR_COLOR or BGFX_CLEAR_DEPTH, 0x303030ff, 1.0'f32, 0)

  loadPrograms()
  loadBuffers()
  loadTextures()

  createAtomicCounters()

  dispatchIndirect = bgfx_create_indirect_buffer(2) 