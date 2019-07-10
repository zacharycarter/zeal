import math, streams, options

const 
  tilesPerChunkWidth = 32
  tilesPerChunkHeight = 32

type
  TileType = enum
    # TILETYPE_FLAT:
    #                     +----------+
    #                    /          /|
    #                -  +----------+ +
    # base_height -> |  |          |/
    #                -  +----------+
    #
    ttFlat
  
  BlendMode = enum
    bmNoBlend,
    bmBlur
  
  Tile = object
    pathable: bool
    tileType: TileType
    baseHeight: int
    # ------------------------------------------------------------------------
    # Only valid when 'type' is a ramp or corner tile.
    # ------------------------------------------------------------------------
    #
    rampHeight: int
    # ------------------------------------------------------------------------
    # Render-specific tile attributes. Only used for populating private render
    # data.
    # ------------------------------------------------------------------------
    #
    topMatIdx: int
    sidesMatIdx: int
    blendMode: BlendMode
    blendNormals: bool

  Chunk = object
    # ------------------------------------------------------------------------
    # Initialized and used by the rendering subsystem. Holds the mesh data 
    # and everything the rendering subsystem needs to render this PFChunk.
    # ------------------------------------------------------------------------
    #
    renderData: pointer
    # ------------------------------------------------------------------------
    # Worldspace position of the top left corner. 
    # ------------------------------------------------------------------------
    #
    position: Vec3
    # ------------------------------------------------------------------------
    # Each tiles' attributes, stored in row-major order.
    # ------------------------------------------------------------------------
    #
    tiles: array[tilesPerChunkHeight * tilesPerChunkWidth, Tile]

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
    minimapVres: Vec2i
    # ------------------------------------------------------------------------
    # Minimap center location, in virtual screen coordinates.
    # ------------------------------------------------------------------------
    #
    minimapCenterPos: Vec2i
    # ------------------------------------------------------------------------
    # Minimap side length, in virtual screen coordinates.
    # ------------------------------------------------------------------------
    #
    minimapSz: int
    # ------------------------------------------------------------------------
    # Navigation private data for the map.
    # ------------------------------------------------------------------------
    #
    navPrivate: pointer
    # ------------------------------------------------------------------------
    # The map chunks stored in row-major order. In total, there must be
    # (width * height) number of chunks.
    # ------------------------------------------------------------------------
    #
    chunks: seq[Chunk]

proc initMap*(header: MapHeader, basePath: string, stream: FileStream): Option[Map] =
  var map: Map

  map.width = header.numCols
  map.height = header.numRows
  map.pos = newVec3(0.0, 0.0, 0.0)

  map.minimapVres = newVec2i(1920, 1080)
  map.minimapCenterPos = newVec2i(192, 1080 - 192)
  map.minimapSz = 256

  result = some(map)