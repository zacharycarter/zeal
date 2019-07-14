import fpmath, streams, strutils, terrain, bgfxdotnim, material, mesh, render, render_asset_load, tile, vertex

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
    minimapVres*: Vec2i
    # ------------------------------------------------------------------------
    # Minimap center location, in virtual screen coordinates.
    # ------------------------------------------------------------------------
    #
    minimapCenterPos*: Vec2i
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
  result.pos = newVec3(0.0, 0.0, 0.0)

  result.minimapVres = newVec2i(1920, 1080)
  result.minimapCenterPos = newVec2i(192, 1080 - 192)
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