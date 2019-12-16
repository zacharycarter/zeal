import camera, collision, fpmath, streams, strutils, bgfxdotnim, material, mesh,
    render, render_asset_load, render_texture, tile, vertex

template `+`*[T](p: ptr T, off: int): ptr T =
  cast[ptr type(p[])](cast[ByteAddress](p) +% off * sizeof(p[]))

template `+=`*[T](p: ptr T, off: int) =
  p = p + off

proc a2i(a: char): int =
  result = int(a) - int('0')

proc modelMatrixForChunk(map: Map, cp: ChunkPos, mtx: var array[16, float32]) =
  if map == nil:
    return

  let
    xOffset = -(cp.c * tilesPerChunkWidth * xCoordsPerTile)
    zOffset = cp.r * tilesPerChunkHeight * zCoordsPerTile
    chunkPos = [map.pos[0] + float32(xOffset), map.pos[1], map.pos[2] +
        float32(zOffset)]

  mtxTranslate(mtx, chunkPos[0], chunkPos[1], chunkPos[2])

proc aabbForChunk(map: Map, chunkPos: ChunkPos, outChunkAabb: var AABB) =
  if map == nil:
    return

  let
    chunkXDim = tilesPerChunkWidth * xCoordsPerTile
    chunkZDim = tilesPerChunkHeight * zCoordsPerTile
    chunkMaxHeight = maxHeightLevel * yCoordsPerTile
    xOffset = -(chunkPos.c * chunkXDim)
    zOffset = (chunkPos.r * chunkZDim)

  outChunkAabb.xMax = map.pos[0] + float32(xOffset)
  outChunkAabb.xMin = outChunkAabb.xMax - float32(chunkXDim)

  outChunkAabb.zMin = map.pos[2] + float32(zOffset)
  outChunkAabb.zMax = outChunkAabb.zMin + float32(chunkZDim)

  outChunkAabb.yMin = 0.0'f32
  outChunkAabb.yMax = float32(chunkMaxHeight)

  assert(outChunkAabb.xMax >= outChunkAabb.xMin)
  assert(outChunkAabb.yMax >= outChunkAabb.yMin)
  assert(outChunkAabb.zMax >= outChunkAabb.zMin)

proc renderVisibleMap*(map: Map, cam: var Camera, rp: RenderPass) =
  if map == nil:
    return

  var frustum: Frustum
  makeFrustum(cam, frustum)

  for r in 0 ..< map.height:
    for c in 0 ..< map.width:
      var chunkAabb: AABB
      aabbForChunk(map, ChunkPos(r: r, c: c), chunkAabb)

      # if not frustumAABBIntersectionExact(frustum, chunkAabb):
      #   continue

      var chunkModel: Mat4
      let chunk = map.chunks[r * map.width + c]
      modelMatrixForChunk(map, ChunkPos(r: r, c: c), chunkModel)
      draw(map.renderData, chunk.renderData, chunkModel, cam.pos)
  render(cam.pos)

proc centerAtOrigin*(map: Map) =
  if map == nil:
    return

  let
    width = map.width * tilesPerChunkWidth * xCoordsPerTile
    height = map.height * tilesPerChunkHeight * zCoordsPerTile

  map.pos = [(float32(width) / 2.0'f32), 0.0, -(float32(height) / 2.0)]

proc patchAdjacencyInfo(map: Map) =
  for r in 0 ..< map.height:
    for c in 0 ..< map.width:
      for tileR in 0 ..< tilesPerChunkHeight:
        for tileC in 0 ..< tilesPerChunkHeight:
          let
            desc = TileDesc(chunkR: r, chunkC: c, tileR: tileR, tileC: tileC)
            tile = map.chunks[r * map.width + c].tiles[tileR *
                tilesPerChunkWidth + tileC]

          patchTileVertsBlend(map.chunks[r * map.width + c].renderData, map, desc)
          if tile.blendNormals:
            patchTileVertsSmooth(map.chunks[r * map.width + c].renderData, map, desc)


proc parseTile(str: string, tile: ptr Tile) =
  if len(str) != 24:
    raise newException(MapParsingError, "failed parsing map tile")

  tile[].kind = TileKind(parseHexInt($str[0]))
  tile[].baseHeight = (if str[1] == '-': -1 else: 1) * (10 * a2i(str[2]) + a2i(str[3]))
  tile[].rampHeight = (10 * a2i(str[4]) + a2i(str[5]))
  tile[].topMatIdx = int32((100 * a2i(str[6]) + 10 * a2i(str[7]) + a2i(str[8])))
  tile[].sidesMatIdx = int32((100 * a2i(str[9]) + 10 * a2i(str[10]) + a2i(str[11])))
  tile[].pathable = bool(a2i(str[12]))
  tile[].blendMode = BlendMode(a2i(str[13]))
  tile[].blendNormals = bool(a2i(str[14]))

proc readRow(stream: FileStream, tile: ptr Tile, tilesInRow: var int) =
  var line: string
  assert stream.readLine(line)

  tilesInRow = 0
  let splits = line.splitWhitespace()
  for split in splits:
    parseTile(split, tile + tilesInRow)
    inc(tilesInRow)

proc readChunk(stream: FileStream, chunk: ptr Chunk) =
  var tilesRead = 0
  while tilesRead < tilesPerChunkWidth * tilesPerChunkHeight:
    var tilesInRow = 0
    readRow(stream, addr(chunk[].tiles[0]) + tilesRead, tilesInRow)
    tilesRead += tilesInRow


proc readMaterial(stream: FileStream, texName: var string) =
  var line: string

  assert stream.readLine(line)
  let splits = line.splitWhitespace()
  if len(splits) != 3:
    raise newException(MapParsingError, "failed parsing map materials")

  texName = splits[2]


proc initMap*(header: MapHeader, basePath: string, stream: FileStream): Map =
  var m = new Map
  m.width = header.numCols
  m.height = header.numRows
  m.pos = [0.0'f32, 0.0, 0.0]

  m.minimapVres = [1280, 720]
  m.minimapCenterPos = [1280, 720 - 192]
  m.minimapSz = 256

  var texnames = newSeq[string](header.numMaterials)

  for i in 0 ..< header.numMaterials:
    readMaterial(stream, texNames[i])

  m.renderData.textures.handle = createTextureArrayMap(texnames)

  m.renderData.sTexColor = bgfx_create_uniform("s_texColor",
      BGFX_UNIFORM_TYPE_SAMPLER, 11)

  let numChunks = header.numRows * header.numCols
  m.chunks.setLen(numChunks)
  for i in 0 ..< numChunks:
    readChunk(stream, addr(m.chunks[0]) + i)

    initRenderDataFromTiles(m.chunks[i].tiles, tilesPerChunkWidth,
        tilesPerChunkHeight, m.chunks[i].renderData)

  patchAdjacencyInfo(m)

  for i in 0 ..< numChunks:
    fillVBuff(m.chunks[i].renderData, m.chunks[i].renderData.mesh.vBuff)

  return m

proc destroy*(map: Map) =
  if map == nil:
    return

  for chunk in map.chunks:
    bgfx_destroy_vertex_buffer(chunk.renderData.mesh.vBuffHandle)

  bgfx_destroy_uniform(map.renderData.sTexColor)

  bgfx_destroy_texture(map.renderData.textures.handle)
