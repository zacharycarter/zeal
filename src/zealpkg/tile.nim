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

proc tileNWHeight(tile: Tile): int =
  let topNWRaised = tile.kind == tkRampSN or
                    tile.kind == tkRampEW or
                    tile.kind == tkCornerConvexSW or
                    tile.kind == tkCornerConvexSE or
                    tile.kind == tkCornerConcaveSE or
                    tile.kind == tkCornerConvexNE
  
  if topNWRaised:
    result = tile.baseHeight + tile.rampHeight
  else:
    result = tile.baseHeight

proc tileNEHeight(tile: Tile): int =
  let topNERaised = tile.kind == tkRampSN or
                    tile.kind == tkRampWE or
                    tile.kind == tkCornerConvexSW or
                    tile.kind == tkCornerConcaveSW or
                    tile.kind == tkCornerConvexSE or
                    tile.kind == tkCornerConvexNW
  
  if topNERaised:
    result = tile.baseHeight + tile.rampHeight
  else:
    result = tile.baseHeight

proc tileSWHeight(tile: Tile): int =
  let topSWRaised = tile.kind == tkRampNS or
                    tile.kind == tkRampEW or
                    tile.kind == tkCornerConvexSE or
                    tile.kind == tkCornerConvexNW or
                    tile.kind == tkCornerConcaveNE or
                    tile.kind == tkCornerConvexNE
  
  if topSWRaised:
    result = tile.baseHeight + tile.rampHeight
  else:
    result = tile.baseHeight

proc tileSEHeight(tile: Tile): int =
  let topSERaised = tile.kind == tkRampNS or
                    tile.kind == tkRampWE or
                    tile.kind == tkCornerConvexSW or
                    tile.kind == tkCornerConvexNE or
                    tile.kind == tkCornerConcaveNW or
                    tile.kind == tkCornerConvexNW
  
  if topSERaised:
    result = tile.baseHeight + tile.rampHeight
  else:
    result = tile.baseHeight

proc getTileVertices*(tile: Tile, vertices: var seq[Vertex], r, c: int) =
  # Bottom face is always the same (just shifted over based on row and column), and the 
  # front, back, left, right faces just connect the top and bottom faces. The only 
  # variations are in the top face, which has some corners raised based on tile type. 
  #
  let bot = Face(
    nw: Vertex(
      pos: newVec3(0.0 - float32((c+1) * xCoordsPerTile), (-1.0 * yCoordsPerTile), 0.0 + float32(r * zCoordsPerTile)),
      uv: newVec2(0.0, 1.0),
      normal: newVec3(0.0, -1.0, 0.0),
      materialIdx: tile.topMatIdx
    ),
    ne: Vertex(
      pos: newVec3(0.0 - float32(c * xCoordsPerTile), (-1.0 * yCoordsPerTile), 0.0 + float32(r * zCoordsPerTile)),
      uv: newVec2(1.0, 1.0),
      normal: newVec3(0.0, -1.0, 0.0),
      materialIdx: tile.topMatIdx
    ),
    se: Vertex(
      pos: newVec3(0.0 - float32(c * xCoordsPerTile), (-1.0 * yCoordsPerTile), 0.0 + float32((r+1) * zCoordsPerTile)),
      uv: newVec2(1.0, 0.0),
      normal: newVec3(0.0, -1.0, 0.0),
      materialIdx: tile.topMatIdx
    ),
    sw: Vertex(
      pos: newVec3(0.0 - float32((c+1) * xCoordsPerTile), (-1.0 * yCoordsPerTile), 0.0 + float32((r+1) * zCoordsPerTile)),
      uv: newVec2(0.0, 0.0),
      normal: newVec3(0.0, -1.0, 0.0),
      materialIdx: tile.topMatIdx
    )
  )

  # Normals for top face get set at the end
  let top = Face(
    nw: Vertex(
      pos: newVec3(0.0 - float32(c * xCoordsPerTile), float32(tileNWHeight(tile) * yCoordsPerTile), 0.0 + float32(r * zCoordsPerTile)),
      uv: newVec2(0.0, 1.0),
      materialIdx: tile.topMatIdx
    ),
    ne: Vertex(
      pos: newVec3(0.0 - float32((c+1) * xCoordsPerTile), float32(tileNEHeight(tile) * yCoordsPerTile), 0.0 + float32(r * zCoordsPerTile)),
      uv: newVec2(1.0, 1.0),
      materialIdx: tile.topMatIdx
    ),
    se: Vertex(
      pos: newVec3(0.0 - float32((c+1) * xCoordsPerTile), float32(tileSEHeight(tile) * yCoordsPerTile), 0.0 + float32((r+1) * zCoordsPerTile)),
      uv: newVec2(1.0, 0.0),
      materialIdx: tile.topMatIdx
    ),
    sw: Vertex(
      pos: newVec3(0.0f - float32(c * xCoordsPerTile), float32(tileSWHeight(tile) * yCoordsPerTile), 0.0f + float32((r+1) * zCoordsPerTile)),
      uv: newVec2(0.0, 0.0),
      materialIdx: tile.topMatIdx
    )
  )

  template vCoord(width, height: untyped): untyped =
    ((cast[float32](height)) / width)

  let sideAdjacentIndices = ((tile.sidesMatIdx and 0xf) shl 0) or 
                            ((tile.sidesMatIdx and 0xf) shl 4) or 
                            ((tile.sidesMatIdx and 0xf) shl 8) or 
                            ((tile.sidesMatIdx and 0xf) shl 12)

  let back = Face(
    nw: Vertex(
      pos: top.ne.pos,
      uv: newVec2(0.0, vCoord(xCoordsPerTile, top.ne.pos.y)),
      normal: newVec3(0.0, 0.0, -1.0),
      materialIdx: tile.sidesMatIdx
    ),
    ne: Vertex(
      pos: top.nw.pos,
      uv: newVec2(1.0, vCoord(xCoordsPerTile, top.nw.pos.y)),
      normal: newVec3(0.0, 0.0, -1.0),
      materialIdx: tile.sidesMatIdx
    ),
    se: Vertex(
      pos: bot.ne.pos,
      uv: newVec2(1.0, 0.0),
      normal: newVec3(0.0, 0.0, -1.0),
      materialIdx: tile.sidesMatIdx
    ),
    sw: Vertex(
      pos: bot.nw.pos,
      uv: newVec2(0.0, 0.0),
      normal: newVec3(0.0, 0.0, -1.0),
      materialIdx: tile.sidesMatIdx
    )
  )

  let front = Face(
    nw: Vertex(
      pos: top.sw.pos,
      uv: newVec2(0.0, vCoord(xCoordsPerTile, top.sw.pos.y)),
      normal: newVec3(0.0, 0.0, 1.0),
      materialIdx: tile.sidesMatIdx
    ),
    ne: Vertex(
      pos: top.se.pos,
      uv: newVec2(1.0, vCoord(xCoordsPerTile, top.se.pos.y)),
      normal: newVec3(0.0, 0.0, 1.0),
      materialIdx: tile.sidesMatIdx
    ),
    se: Vertex(
      pos: bot.sw.pos,
      uv: newVec2(1.0, 0.0),
      normal: newVec3(0.0, 0.0, 1.0),
      materialIdx: tile.sidesMatIdx
    ),
    sw: Vertex(
      pos: bot.se.pos,
      uv: newVec2(0.0, 0.0),
      normal: newVec3(0.0, 0.0, 1.0),
      materialIdx: tile.sidesMatIdx
    )
  )
