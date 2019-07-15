import camera, collision, fpmath, streams, strutils, terrain, bgfxdotnim, material, mesh, render, render_asset_load, tile, vertex

type
  MapHeader* = object
    version*: float
    numMaterials*: int
    numRows*: int
    numCols*: int

  Map* = object
    # ------------------------------------------------------------------------
    # Map dimensions in numbers of chunks.
    # ------------------------------------------------------------------------
    #
    width*, height*: int
    # ------------------------------------------------------------------------
    # World-space location of the top left corner of the map.
    # ------------------------------------------------------------------------
    #
    pos*: Vec3
    # ------------------------------------------------------------------------
    # Virtual resolution used to draw the minimap. Other parameters
    # assume that this is the screen resolution. The minimap is then scaled as
    # necessary for the current window resolution at the rendering stage.
    # ------------------------------------------------------------------------
    #
    minimapVres*: array[2, int]
    # ------------------------------------------------------------------------
    # Minimap center location, in virtual screen coordinates.
    # ------------------------------------------------------------------------
    #
    minimapCenterPos*: array[2, int]
    # ------------------------------------------------------------------------
    # Minimap side length, in virtual screen coordinates.
    # ------------------------------------------------------------------------
    #
    minimapSz*: int
    # ------------------------------------------------------------------------
    # Navigation private data for the map.
    # ------------------------------------------------------------------------
    #
    navPrivate*: pointer
    # ------------------------------------------------------------------------
    # The map chunks stored in row-major order. In total, there must be
    # (width * height) number of chunks.
    # ------------------------------------------------------------------------
    #
    chunks*: seq[Chunk]
  
  MapParsingError* = object of Exception

proc a2i(a: char): int =
  result = int(a) - int('0')

proc modelMatrixForChunk(map: Map, cp: ChunkPos, mtx: var array[16, float32]) =
  let
    xOffset = -(cp.c * tilesPerChunkWidth * xCoordsPerTile)
    zOffset = cp.r * tilesPerChunkHeight * zCoordsPerTile
    chunkPos = [map.pos[0] + float32(xOffset), map.pos[1], map.pos[2] + float32(zOffset)]
  
  # mtxTranslate(mtx, chunkPos[0], chunkPos[1], chunkPos[2])
  mtxProj(mtx, 60.0'f32, 960.0'f32 / 540.0'f32, 0.1'f32, 100.0'f32, rendererCaps.homogeneousDepth)
  

proc renderVisibleMap*(map: Map, cam: Camera, rp: RenderPass) =
  var frustum: Frustum
  makeFrustum(cam, frustum)

  # for r in 0 ..< map.height:
  #   for c in 0 ..< map.width:
  #     var chunkModel: Mat4
  #     let chunk = map.chunks[map.width * r + c]
  #     modelMatrixForChunk(map, ChunkPos(r: r, c: c), chunkModel)
  var chunkModel: Mat4
  draw(map.chunks[0].renderData, chunkModel)

proc parseTile(str: string, tile: var Tile) =
  if len(str) != 24:
    raise newException(MapParsingError, "failed parsing map tile")
  
  tile.kind         = TileKind(parseHexInt($str[0]))
  tile.baseHeight   = (if str[1] == '-': -1 else: 1) * (10 * a2i(str[2]) + a2i(str[3]))
  tile.rampHeight   = (10 * a2i(str[4]) + a2i(str[5]))
  tile.topMatIdx    = int16(100 * a2i(str[6]) + 10 * a2i(str[7 ]) + a2i(str[8 ]))
  tile.sidesMatIdx  = int16(100 * a2i(str[9]) + 10 * a2i(str[10]) + a2i(str[11]))
  tile.pathable     = bool(a2i(str[12]))
  tile.blendMode    = BlendMode(a2i(str[13]))
  tile.blendNormals = bool(a2i(str[14]))

proc readRow(stream: FileStream, tile: var Tile, tilesInRow: var int) =
  var line: string
  assert stream.readLine(line)
  let splits = line.splitWhitespace()
  for split in splits:
    parseTile(split, tile)
    inc(tilesInRow)

proc readChunk(stream: FileStream, chunk: var Chunk) =
  var tilesRead = 0
  while tilesRead < tilesPerChunkWidth * tilesPerChunkHeight:
    var tilesInRow= 0
    readRow(stream, chunk.tiles[tilesRead], tilesInRow)
    tilesRead += tilesInRow


proc readMaterial(stream: FileStream, texName: var string) =
  var line: string
 
  assert stream.readLine(line)
  let splits = line.splitWhitespace()
  if len(splits) != 3:
    raise newException(MapParsingError, "failed parsing map materials")
  
  texName = splits[2]


proc initMap*(header: MapHeader, basePath: string, stream: FileStream): Map =
  result.width = header.numCols
  result.height = header.numRows
  result.pos = [0.0'f32, 0.0, 0.0]

  result.minimapVres = [1920, 1080]
  result.minimapCenterPos = [192, 1080 - 192]
  result.minimapSz = 256

  var texnames = newSeq[string](header.numMaterials)
  
  for i in 0 ..< header.numMaterials:
    readMaterial(stream, texNames[i])

  initMapTextures(texnames)

  let numChunks = header.numRows * header.numCols
  result.chunks = newSeq[Chunk](numChunks)
  for i in 0 ..< numChunks:
    readChunk(stream, result.chunks[i])
    initRenderDataFromTiles(result.chunks[i].tiles, tilesPerChunkWidth, tilesPerChunkHeight, result.chunks[i].renderData)