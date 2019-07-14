import fpmath, render, vertex

const
  tilesPerChunkWidth*  = 32
  tilesPerChunkHeight* = 32
  xCoordsPerTile = 8
  yCoordsPerTile = 4
  zCoordsPerTile = 8

type
  TileKind* {.size: sizeof(int32).} = enum
    # TILEKIND_FLAT:
    #                     +----------+
    #                    /          /|
    #                -  +----------+ +
    # base_height -> |  |          |/
    #                -  +----------+
    #
    tkFlat            = 0x0
    # By convention, the second letter (ex. 'N' in 'SN') is the raised end
    tkRampSN          = 0x1
    tkRampNS          = 0x2
    tkRampEW          = 0x3
    tkRampWE          = 0x4
    # For corners, the direction in the name is that of the central lowered corner
    tkCornerConcaveSW = 0x5
    tkCornerConvexSW  = 0x6
    tkCornerConcaveSE = 0x7
    tkCornerConvexSE  = 0x8
    tkCornerConcaveNW = 0x9
    tkCornerConvexNW  = 0xa
    tkCornerConcaveNE = 0xb
    tkCornerConvexNE  = 0xc
  
  BlendMode* = enum
    bmNoBlend,
    bmBlur
  
  Tile* = object
    pathable*: bool
    kind*: TileKind
    baseHeight*: int
    # ------------------------------------------------------------------------
    # Only valid when 'type' is a ramp or corner tile.
    # ------------------------------------------------------------------------
    #
    rampHeight*: int
    # ------------------------------------------------------------------------
    # Render-specific tile attributes. Only used for populating private render
    # data.
    # ------------------------------------------------------------------------
    #
    topMatIdx*: int
    sidesMatIdx*: int
    blendMode*: BlendMode
    blendNormals*: bool

  Chunk* = object
    # ------------------------------------------------------------------------
    # Initialized and used by the rendering subsystem. Holds the mesh data 
    # and everything the rendering subsystem needs to render this PFChunk.
    # ------------------------------------------------------------------------
    #
    renderData*: RenderData
    # ------------------------------------------------------------------------
    # Worldspace position of the top left corner. 
    # ------------------------------------------------------------------------
    #
    position*: Vec3
    # ------------------------------------------------------------------------
    # Each tiles' attributes, stored in row-major order.
    # ------------------------------------------------------------------------
    #
    tiles*: array[tilesPerChunkHeight * tilesPerChunkWidth, Tile]

type
  Face* = object
    nw, ne, se, sw: Vertex

proc getTileVertices*(tile: Tile, vertices: var seq[Vertex], r, c: int) =
  # Bottom face is always the same (just shifted over based on row and column), and the 
  # front, back, left, right faces just connect the top and bottom faces. The only 
  # variations are in the top face, which has some corners raised based on tile type. 
  #
  let faceBot = Face(
    nw: Vertex(
      pos: newVec3(0.0 - float32((c+1) * xCoordsPerTile), (-1.0 * yCoordsPerTile), 0.0 + float32(r * zCoordsPerTile)),
      uv: newVec2(0.0, 1.0),
      normal: newVec3(0.0, -1.0, 0.0),
      materialIdx: tile.topMatIdx
    )
  )
