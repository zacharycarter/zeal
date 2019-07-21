import fpmath, render, vertex

template `+`*[T](p: ptr T, off: int): ptr T =
  cast[ptr type(p[])](cast[ByteAddress](p) +% off * sizeof(p[]))

template `+=`*[T](p: ptr T, off: int) =
  p = p + off

const
  tilesPerChunkWidth*  = 32
  tilesPerChunkHeight* = 32
  xCoordsPerTile* = 8
  yCoordsPerTile* = 4
  zCoordsPerTile* = 8
  maxHeightLevel* = 9

# Each top face is made up of 8 triangles, in the following configuration:
#   +------+------+
#   |\     |     |
#   |  \   |     |
#   |    \ |     |
#   +------+------+
#   |     | \    |
#   |     |   \  |
#   |     |     \|
#   +------+------+
# Each face can be thought of as being made of of 4 "major" triangles,
# each of which has its' own adjacency info as a flat attribute. The 4 major
# triangles are the minimal configuration that is necessary for the blending
# system to work.
#   +------+------+
#   |\           |
#   |  \   2     |
#   |    \       |
#   +  1  >+<  3  +
#   |       \    |
#   |     0   \  |
#   |           \|
#   +------+------+
# The "major" trinagles can be futher subdivided. The triangles they are divided 
# into must inherit the flat adjacency attributes and interpolate their positions, 
# uv coorinates, and normals. In our case, we futher subdivide each of the major
# triangles into 2 triangles. This is to give an extra vertex on the midpoint 
# of each edge. When smoothing the normals, this extra point having its' own 
# normal is essential. Care must be taken to ensure the appropriate winding order
# for each triangle for backface culling!

type
  VertTris* = object
    se0*: Vertex               ##  Tri 0
    s0*: Vertex
    center0*: Vertex           ##  Tri 1
    center1*: Vertex
    s1*: Vertex
    sw0*: Vertex               ##  Tri 2
    sw1*: Vertex
    w0*: Vertex
    center2*: Vertex           ##  Tri 3
    center3*: Vertex
    w1*: Vertex
    nw0*: Vertex               ##  Tri 4
    nw1*: Vertex
    n0*: Vertex
    center4*: Vertex           ##  Tri 5
    center5*: Vertex
    n1*: Vertex
    ne0*: Vertex               ##  Tri 6
    ne1*: Vertex
    e0*: Vertex
    center6*: Vertex           ##  Tri 7
    center7*: Vertex
    e1*: Vertex
    se1*: Vertex

  TopFaceVbuff* {.union.} = object
    verts*: array[vertsPerTopFace, Vertex]
    tris*: array[vertsPerTopFace div 3, Tri]
    vertTris*: VertTris

  TileKind* {.size: sizeof(int32).} = enum
    # TILEKIND_FLAT:
    #                     +----------+
    #                    /          /|
    #                -  +----------+ +
    # base_height . |  |          |/
    #                -  +----------+
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
  
  Tile* = object
    pathable*: bool
    kind*: TileKind
    baseHeight*: int
    # ------------------------------------------------------------------------
    # Only valid when 'type' is a ramp or corner tile.
    # ------------------------------------------------------------------------
    rampHeight*: int
    # ------------------------------------------------------------------------
    # Render-specific tile attributes. Only used for populating private render
    # data.
    # ------------------------------------------------------------------------
    topMatIdx*: int16
    sidesMatIdx*: int16
    blendMode*: BlendMode
    blendNormals*: bool

  Chunk* = object
    # ------------------------------------------------------------------------
    # Initialized and used by the rendering subsystem. Holds the mesh data 
    # and everything the rendering subsystem needs to render this PFChunk.
    # ------------------------------------------------------------------------
    renderData*: RenderData
    # ------------------------------------------------------------------------
    # Worldspace position of the top left corner. 
    # ------------------------------------------------------------------------
    position*: Vec3
    # ------------------------------------------------------------------------
    # Each tiles' attributes, stored in row-major order.
    # ------------------------------------------------------------------------
    tiles*: array[tilesPerChunkHeight * tilesPerChunkWidth, Tile]
  
  ChunkPos* = object
    r*, c*: int

  Face = object
    nw, ne, se, sw: Vertex
  
  Tri = object
    verts: array[3, Vertex]

template mag*(x, y: untyped): untyped =
  sqrt(pow(float32(x), 2) + pow(float32(y), 2))

proc isRampTile(tk: TileKind): bool =
  result = (tk == tkRampSN) or 
           (tk == tkRampNS) or
           (tk == tkRampEW) or
           (tk == tkRampWE)

proc isCornerConvexTile(tk: TileKind): bool =
  result = (tk == tkCornerConvexSW) or 
           (tk == tkCornerConvexSE) or
           (tk == tkCornerConvexNW) or
           (tk == tkCornerConvexNE)

proc tileNWHeight(tile: Tile): int =
  let topNWRaised = (tile.kind == tkRampSN) or
                    (tile.kind == tkRampEW) or
                    (tile.kind == tkCornerConvexSW) or
                    (tile.kind == tkCornerConvexSE) or
                    (tile.kind == tkCornerConcaveSE) or
                    (tile.kind == tkCornerConvexNE)
  
  if topNWRaised:
    result = tile.baseHeight + tile.rampHeight
  else:
    result = tile.baseHeight

proc tileNEHeight(tile: Tile): int =
  let topNERaised = (tile.kind == tkRampSN) or
                    (tile.kind == tkRampWE) or
                    (tile.kind == tkCornerConvexSW) or
                    (tile.kind == tkCornerConcaveSW) or
                    (tile.kind == tkCornerConvexSE) or
                    (tile.kind == tkCornerConvexNW)
  
  if topNERaised:
    result = tile.baseHeight + tile.rampHeight
  else:
    result = tile.baseHeight

proc tileSWHeight(tile: Tile): int =
  let topSWRaised = (tile.kind == tkRampNS) or
                    (tile.kind == tkRampEW) or
                    (tile.kind == tkCornerConvexSE) or
                    (tile.kind == tkCornerConvexNW) or
                    (tile.kind == tkCornerConcaveNE) or
                    (tile.kind == tkCornerConvexNE)
  
  if topSWRaised:
    result = tile.baseHeight + tile.rampHeight
  else:
    result = tile.baseHeight

proc tileSEHeight(tile: Tile): int =
  let topSERaised = (tile.kind == tkRampNS) or
                    (tile.kind == tkRampWE) or
                    (tile.kind == tkCornerConvexSW) or
                    (tile.kind == tkCornerConvexNE) or
                    (tile.kind == tkCornerConcaveNW) or
                    (tile.kind == tkCornerConvexNW)
  
  if topSERaised:
    result = tile.baseHeight + tile.rampHeight
  else:
    result = tile.baseHeight

proc tileTopNormals(tile: Tile, topTriNormals: var array[2, Vec3], triTopLeftAligned: var bool) =
  case tile.kind
  of tkFlat:
    topTriNormals[0] = [0.0'f32, 1.0, 0.0]
    topTriNormals[1] = [0.0'f32, 1.0, 0.0]

    triTopLeftAligned = true
  of tkRampSN:
    let normalAngle = PI/2.0 - arctan2(float32(tile.rampHeight * yCoordsPerTile), float32(zCoordsPerTile))

    topTriNormals[0] = [0.0'f32, sin(normalAngle), cos(normalAngle)]
    topTriNormals[1] = [0.0'f32, sin(normalAngle), cos(normalAngle)]

    triTopLeftAligned = true
  of tkRampNS:
    let normalAngle = PI/2.0 - arctan2(float32(tile.rampHeight * yCoordsPerTile), float32(zCoordsPerTile))

    topTriNormals[0] = [0.0'f32, sin(normalAngle), -cos(normalAngle)]
    topTriNormals[1] = [0.0'f32, sin(normalAngle), -cos(normalAngle)]

    triTopLeftAligned = true
  of tkRampEW:
    let normalAngle = PI/2.0 - arctan2(float32(tile.rampHeight * yCoordsPerTile), float32(xCoordsPerTile))

    topTriNormals[0] = [float32(-cos(normalAngle)), sin(normalAngle), 0.0]
    topTriNormals[1] = [float32(-cos(normalAngle)), sin(normalAngle), 0.0]

    triTopLeftAligned = true
  of tkRampWE:
    let normalAngle = PI/2.0 - arctan2(float32(tile.rampHeight * yCoordsPerTile), float32(xCoordsPerTile))

    topTriNormals[0] = [float32(cos(normalAngle)), sin(normalAngle), 0.0]
    topTriNormals[1] = [float32(cos(normalAngle)), sin(normalAngle), 0.0]

    triTopLeftAligned = true
  of tkCornerConcaveSW:
    let normalAngle = PI/2.0 - arctan2(float32(tile.rampHeight * yCoordsPerTile), float32(mag(xCoordsPerTile, zCoordsPerTile) / 2.0))

    topTriNormals[0] = [0.0'f32, 1.0, 0.0]
    topTriNormals[1] = [float32(cos(normalAngle) * cos(PI/4.0)), sin(normalAngle), cos(normalAngle) * sin(PI/4.0)]

    triTopLeftAligned = false
  of tkCornerConvexSW:
    let normalAngle = PI/2.0 - arctan2(float32(tile.rampHeight * yCoordsPerTile), float32(mag(xCoordsPerTile, zCoordsPerTile) / 2.0))

    topTriNormals[0] = [float32(cos(normalAngle) * cos(PI/4.0)), sin(normalAngle), cos(normalAngle) * sin(PI/4.0)]
    topTriNormals[1] = [0.0'f32, 1.0, 0.0]

    triTopLeftAligned = false
  of tkCornerConcaveSE:
    let normalAngle = PI/2.0 - arctan2(float32(tile.rampHeight * yCoordsPerTile), float32(mag(xCoordsPerTile, zCoordsPerTile) / 2.0))

    topTriNormals[0] = [0.0'f32, 1.0, 0.0]
    topTriNormals[1] = [float32(-cos(normalAngle) * cos(PI/4.0)), sin(normalAngle), cos(normalAngle) * sin(PI/4.0)]

    triTopLeftAligned = true
  of tkCornerConvexSE:
    let normalAngle = PI/2.0 - arctan2(float32(tile.rampHeight * yCoordsPerTile), float32(mag(xCoordsPerTile, zCoordsPerTile) / 2.0))
    
    topTriNormals[0] = [float32(-cos(normalAngle) * cos(PI/4.0)), sin(normalAngle), cos(normalAngle) * sin(PI/4.0)]
    topTriNormals[1] = [0.0'f32, 1.0, 0.0]

    triTopLeftAligned = true
  of tkCornerConcaveNW:
    let normalAngle = PI/2.0 - arctan2(float32(tile.rampHeight * yCoordsPerTile), float32(mag(xCoordsPerTile, zCoordsPerTile) / 2.0))
    
    topTriNormals[0] = [float32(cos(normalAngle) * cos(PI/4.0)), sin(normalAngle), -cos(normalAngle) * sin(PI/4.0)]
    topTriNormals[1] = [0.0'f32, 1.0, 0.0]

    triTopLeftAligned = true
  of tkCornerConvexNW:
    let normalAngle = PI/2.0 - arctan2(float32(tile.rampHeight * yCoordsPerTile), float32(mag(xCoordsPerTile, zCoordsPerTile) / 2.0))
    
    topTriNormals[0] = [0.0'f32, 1.0, 0.0]
    topTriNormals[1] = [float32(cos(normalAngle) * cos(PI/4.0)), sin(normalAngle), -cos(normalAngle) * sin(PI/4.0)]

    triTopLeftAligned = true
  of tkCornerConcaveNE:
    let normalAngle = PI/2.0 - arctan2(float32(tile.rampHeight * yCoordsPerTile), float32(mag(xCoordsPerTile, zCoordsPerTile) / 2.0))
    
    topTriNormals[0] = [float32(-cos(normalAngle) * cos(PI/4.0)), sin(normalAngle), -cos(normalAngle) * sin(PI/4.0)]
    topTriNormals[1] = [0.0'f32, 1.0, 0.0]

    triTopLeftAligned = false
  of tkCornerConvexNE:
    let normalAngle = PI/2.0 - arctan2(float32(tile.rampHeight * yCoordsPerTile), float32(mag(xCoordsPerTile, zCoordsPerTile) / 2.0))
    
    topTriNormals[0] = [0.0'f32, 1.0, 0.0]
    topTriNormals[1] = [float32(-cos(normalAngle) * cos(PI/4.0)), sin(normalAngle), -cos(normalAngle) * sin(PI/4.0)]

    triTopLeftAligned = false
  
  vec3Norm(topTriNormals[0], topTriNormals[0])
  vec3Norm(topTriNormals[1], topTriNormals[1])

proc getTileVertices*(tile: Tile, outVert: ptr Vertex, r, c: int) =
  # Bottom face is always the same (just shifted over based on row and column), and the 
  # front, back, left, right faces just connect the top and bottom faces. The only 
  # variations are in the top face, which has some corners raised based on tile type.
  let bot = Face(
    nw: Vertex(
      pos: [0.0'f32 - float32((c+1) * xCoordsPerTile), (-1.0 * yCoordsPerTile), 0.0 + float32(r * zCoordsPerTile)],
      uv: [0.0'f32, 1.0],
      # normal: [0.0'f32, -1.0, 0.0],
      # materialIdx: tile.topMatIdx
    ),
    ne: Vertex(
      pos: [0.0'f32 - float32(c * xCoordsPerTile), (-1.0 * yCoordsPerTile), 0.0 + float32(r * zCoordsPerTile)],
      uv: [1.0'f32, 1.0],
      # normal: [0.0'f32, -1.0, 0.0],
      # materialIdx: tile.topMatIdx
    ),
    se: Vertex(
      pos: [0.0'f32 - float32(c * xCoordsPerTile), (-1.0 * yCoordsPerTile), 0.0 + float32((r+1) * zCoordsPerTile)],
      uv: [1.0'f32, 0.0],
      # normal: [0.0'f32, -1.0, 0.0],
      # materialIdx: tile.topMatIdx
    ),
    sw: Vertex(
      pos: [0.0'f32- float32((c+1) * xCoordsPerTile), (-1.0 * yCoordsPerTile), 0.0 + float32((r+1) * zCoordsPerTile)],
      uv: [0.0'f32, 0.0'f32]
      # normal: [0.0'f32, -1.0, 0.0],
      # materialIdx: tile.topMatIdx
    )
  )

  # Normals for top face get set at the end
  let top = Face(
    nw: Vertex(
      pos: [0.0'f32 - float32(c * xCoordsPerTile), float32(tileNWHeight(tile) * yCoordsPerTile), 0.0 + float32(r * zCoordsPerTile)],
      uv: [0.0'f32, 1.0],
      # materialIdx: tile.topMatIdx
    ),
    ne: Vertex(
      pos: [0.0'f32 - float32((c+1) * xCoordsPerTile), float32(tileNEHeight(tile) * yCoordsPerTile), 0.0 + float32(r * zCoordsPerTile)],
      uv: [1.0'f32, 1.0],
      # materialIdx: tile.topMatIdx
    ),
    se: Vertex(
      pos: [0.0'f32 - float32((c+1) * xCoordsPerTile), float32(tileSEHeight(tile) * yCoordsPerTile), 0.0 + float32((r+1) * zCoordsPerTile)],
      uv: [1.0'f32, 0.0],
      # materialIdx: tile.topMatIdx
    ),
    sw: Vertex(
      pos: [0.0'f32 - float32(c * xCoordsPerTile), float32(tileSWHeight(tile) * yCoordsPerTile), 0.0f + float32((r+1) * zCoordsPerTile)],
      uv: [0.0'f32, 0.0],
      # materialIdx: tile.topMatIdx
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
      uv: [0.0'f32, vCoord(xCoordsPerTile, top.ne.pos[1])],
      # normal: [0.0'f32, 0.0, -1.0],
      # materialIdx: tile.sidesMatIdx
    ),
    ne: Vertex(
      pos: top.nw.pos,
      uv: [1.0'f32, vCoord(xCoordsPerTile, top.nw.pos[1])],
      # normal: [0.0'f32, 0.0, -1.0],
      # materialIdx: tile.sidesMatIdx
    ),
    se: Vertex(
      pos: bot.ne.pos,
      uv: [1.0'f32, 0.0],
      # normal: [0.0'f32, 0.0, -1.0],
      # materialIdx: tile.sidesMatIdx
    ),
    sw: Vertex(
      pos: bot.nw.pos,
      uv: [0.0'f32, 0.0],
      # normal: [0.0'f32, 0.0, -1.0],
      # materialIdx: tile.sidesMatIdx
    )
  )

  let front = Face(
    nw: Vertex(
      pos: top.sw.pos,
      uv: [0.0'f32, vCoord(xCoordsPerTile, top.sw.pos[1])],
      # normal: [0.0'f32, 0.0, 1.0],
      # materialIdx: tile.sidesMatIdx
    ),
    ne: Vertex(
      pos: top.se.pos,
      uv: [1.0'f32, vCoord(xCoordsPerTile, top.se.pos[1])],
      # normal: [0.0'f32, 0.0, 1.0],
      # materialIdx: tile.sidesMatIdx
    ),
    se: Vertex(
      pos: bot.sw.pos,
      uv: [1.0'f32, 0.0],
      # normal: [0.0'f32, 0.0, 1.0],
      # materialIdx: tile.sidesMatIdx
    ),
    sw: Vertex(
      pos: bot.se.pos,
      uv: [0.0'f32, 0.0],
      # normal: [0.0'f32, 0.0, 1.0],
      # materialIdx: tile.sidesMatIdx
    )
  )
  
  let left = Face(
    nw: Vertex(
      pos: top.nw.pos,
      uv: [0.0'f32, vCoord(xCoordsPerTile, top.nw.pos[1])],
      # normal: [1.0'f32, 0.0, 0.0],
      # materialIdx: tile.sidesMatIdx
    ),
    ne: Vertex(
      pos: top.sw.pos,
      uv: [1.0'f32, vCoord(xCoordsPerTile, top.sw.pos[1])],
      # normal: [1.0'f32, 0.0, 0.0],
      # materialIdx: tile.sidesMatIdx
    ),
    se: Vertex(
      pos: bot.se.pos,
      uv: [1.0'f32, 0.0],
      # normal: [1.0'f32, 0.0, 0.0],
      # materialIdx: tile.sidesMatIdx
    ),
    sw: Vertex(
      pos: bot.ne.pos,
      uv: [0.0'f32, 0.0],
      # normal: [1.0'f32, 0.0, 0.0],
      # materialIdx: tile.sidesMatIdx
    )
  )

  let right = Face(
    nw: Vertex(
      pos: top.se.pos,
      uv: [0.0'f32, vCoord(xCoordsPerTile, top.se.pos[1])],
      # normal: [-1.0'f32, 0.0, 0.0],
      # materialIdx: tile.sidesMatIdx
    ),
    ne: Vertex(
      pos: top.ne.pos,
      uv: [1.0'f32, vCoord(xCoordsPerTile, top.ne.pos[1])],
      # normal: [-1.0'f32, 0.0, 0.0],
      # materialIdx: tile.sidesMatIdx
    ),
    se: Vertex(
      pos: bot.nw.pos,
      uv: [1.0'f32, 0.0],
      # normal: [-1.0'f32, 0.0, 0.0],
      # materialIdx: tile.sidesMatIdx
    ),
    sw: Vertex(
      pos: bot.sw.pos,
      uv: [0.0'f32, 0.0],
      # normal: [-1.0'f32, 0.0, 0.0],
      # materialIdx: tile.sidesMatIdx
    )
  )

  let faces = [bot, front, back, left, right]
  for i in 0 ..< len(faces):
    var curr = faces[i]
    # First triangle
    copymem(outVert + (i * vertsPerSideFace) + 0, addr curr.nw, sizeof(Vertex))
    copymem(outVert + (i * vertsPerSideFace) + 1, addr curr.ne, sizeof(Vertex))
    copymem(outVert + (i * vertsPerSideFace) + 2, addr curr.sw, sizeof(Vertex))

    # Second triangle
    copymem(outVert + (i * vertsPerSideFace) + 3, addr curr.se, sizeof(Vertex))
    copymem(outVert + (i * vertsPerSideFace) + 4, addr curr.sw, sizeof(Vertex))
    copymem(outVert + (i * vertsPerSideFace) + 5, addr curr.ne, sizeof(Vertex))

  # Lastly, the top face. Unlike the other five faces, it can have different 
  # normals for its' two triangles, and the triangles can be arranged differently 
  # at corner tiles.
  
  var 
    topTriNormals: array[2, Vec3]
    topTriLeftAligned: bool
  
  tileTopNormals(tile, topTriNormals, topTriLeftAligned)

  # CONFIG 1 (left-aligned)   CONFIG 2
  # (nw)      (ne)            (nw)      (ne)
  # +---------+               +---------+
  # |Tri1   / |               | \   Tri1|
  # |     /   |               |   \     |
  # |   /     |               |     \   |
  # | /   Tri0|               |Tri0   \ |
  # +---------+               +---------+
  # (sw)      (se)            (sw)      (se)

  let 
    centerHeight = if isRampTile(tile.kind): float32(tile.baseHeight + tile.rampHeight) / 2.0 
                   else: (if isCornerConvexTile(tile.kind): float32(tile.baseHeight + tile.rampHeight) else: float32(tile.baseHeight))
  
    centerVertPos = [
      float32(top.nw.pos[0] - xCoordsPerTile / 2.0),
      centerHeight * yCoordsPerTile,
      top.nw.pos[1] + zCoordsPerTile / 2.0
    ]

    tri0SideMat = abs(topTriNormals[0][1]) < 1.0 and tile.rampHeight > 1
    tri1SideMat = abs(topTriNormals[1][1]) < 1.0 and tile.rampHeight > 1

    tri0Idx = if tri0SideMat: tile.sidesMatIdx else: tile.topMatIdx
    tri1Idx = if tri1SideMat: tile.sidesMatIdx else: tile.topMatIdx

    centerVertTri0 = Vertex(
      pos: centerVertPos,
      uv: [0.5'f32, 0.5],
      # normal: topTriNormals[0],
      # materialIdx: tri0Idx
    )

    centerVertTri1 = Vertex(
      pos: centerVertPos,
      uv: [0.5'f32, 0.5],
      # normal: topTriNormals[1],
      # materialIdx: tri1Idx
    )

    northVert = Vertex(
      pos: [
        float32((top.ne.pos[0] + top.nw.pos[0])/2.0),
        (top.ne.pos[1] + top.nw.pos[1])/2.0,
        (top.ne.pos[2] + top.nw.pos[2])/2.0
      ],
      uv: [0.5'f32, 1.0],
      # normal: topTriNormals[1],
      # materialIdx: tri1Idx
    )

    southVert = Vertex(
      pos: [
        float32((top.se.pos[0] + top.sw.pos[0])/2.0),
        (top.se.pos[1] + top.sw.pos[1])/2.0,
        (top.se.pos[2] + top.sw.pos[2])/2.0
      ],
      uv: [0.5'f32, 0.0],
      # normal: topTriNormals[0],
      # materialIdx: tri0Idx
    )

    westVert = Vertex(
      pos: [
        float32((top.sw.pos[0] + top.nw.pos[0])/2.0),
        (top.sw.pos[1] + top.nw.pos[1])/2.0,
        (top.sw.pos[2] + top.nw.pos[2])/2.0
      ],
      uv: [0.0'f32, 0.5],
      # normal: if topTriLeftAligned: topTriNormals[1] else: topTriNormals[0],
      # materialIdx: if topTriLeftAligned: tri1Idx else: tri0Idx
    )

    eastVert = Vertex(
      pos: [
        float32((top.se.pos[0] + top.ne.pos[0])/2.0),
        (top.se.pos[1] + top.ne.pos[1])/2.0,
        (top.se.pos[2] + top.ne.pos[2])/2.0
      ],
      uv: [1.0'f32, 0.5],
      # normal: if topTriLeftAligned: topTriNormals[0] else: topTriNormals[1],
      # materialIdx: if topTriLeftAligned: tri0Idx else: tri1Idx
    )

  assert(sizeof(TopFaceVbuff) == vertsPerTopFace * sizeof(Vertex))
  # var tfvb = cast[ptr TopFaceVbuff](outVert + 5 * vertsPerSideFace)
  # tfvb.vertTris.se0 = top.se
  # tfvb.vertTris.s0 = southVert
  # tfvb.vertTris.center0 = centerVertTri0
  # tfvb.vertTris.center1 = centerVertTri0
  # tfvb.vertTris.s1 = southVert
  # tfvb.vertTris.sw0 = top.sw
  # tfvb.vertTris.sw1 = top.sw
  # tfvb.vertTris.w0 = westVert
  # tfvb.vertTris.center2 = if topTriLeftAligned: centerVertTri1 else: centerVertTri0
  # tfvb.vertTris.center3 = if topTriLeftAligned: centerVertTri1 else: centerVertTri0
  # tfvb.vertTris.w1 = westVert
  # tfvb.vertTris.nw0 = top.nw
  # tfvb.vertTris.nw1 = top.nw
  # tfvb.vertTris.n0 = northVert
  # tfvb.vertTris.center4 = centerVertTri1
  # tfvb.vertTris.center5 = centerVertTri1
  # tfvb.vertTris.n1 = northVert
  # tfvb.vertTris.ne0 = top.ne
  # tfvb.vertTris.ne1 = top.ne
  # tfvb.vertTris.e0 = eastVert
  # tfvb.vertTris.center6 = if topTriLeftAligned: centerVertTri0 else: centerVertTri1
  # tfvb.vertTris.center7 = if topTriLeftAligned: centerVertTri0 else: centerVertTri1
  # tfvb.vertTris.e1 = eastVert
  # tfvb.vertTris.se1 = top.se
  
  # tfvb.vertTris.center0.pos[2] -= 0.005
  # tfvb.vertTris.center1.pos[2] -= 0.005
  # tfvb.vertTris.center2.pos[0] -= 0.005
  # tfvb.vertTris.center3.pos[0] -= 0.005
  # tfvb.vertTris.center4.pos[2] += 0.005
  # tfvb.vertTris.center5.pos[2] += 0.005
  # tfvb.vertTris.center6.pos[2] += 0.005
  # tfvb.vertTris.center7.pos[2] += 0.005

  # if topTriLeftAligned:
  #   tfvb.vertTris.se0.material_idx = tri0Idx
  #   tfvb.vertTris.sw0.material_idx = tri0Idx
  #   tfvb.vertTris.sw1.material_idx = tri1Idx
  #   tfvb.vertTris.nw0.material_idx = tri1Idx
  #   tfvb.vertTris.nw1.material_idx = tri1Idx
  #   tfvb.vertTris.ne0.material_idx = tri1Idx
  #   tfvb.vertTris.ne1.material_idx = tri0Idx
  #   tfvb.vertTris.se1.material_idx = tri0Idx

  #   tfvb.vertTris.se0.normal = topTriNormals[0]
  #   tfvb.vertTris.sw0.normal = topTriNormals[0]
  #   tfvb.vertTris.sw1.normal = topTriNormals[1]
  #   tfvb.vertTris.nw0.normal = topTriNormals[1]
  #   tfvb.vertTris.nw1.normal = topTriNormals[1]
  #   tfvb.vertTris.ne0.normal = topTriNormals[1]
  #   tfvb.vertTris.ne1.normal = topTriNormals[0]
  #   tfvb.vertTris.se1.normal = topTriNormals[0]
  # else:
  #   tfvb.vertTris.se0.material_idx = tri0Idx
  #   tfvb.vertTris.sw0.material_idx = tri0Idx
  #   tfvb.vertTris.sw1.material_idx = tri0Idx
  #   tfvb.vertTris.nw0.material_idx = tri0Idx
  #   tfvb.vertTris.nw1.material_idx = tri1Idx
  #   tfvb.vertTris.ne0.material_idx = tri1Idx
  #   tfvb.vertTris.ne1.material_idx = tri1Idx
  #   tfvb.vertTris.se1.material_idx = tri1Idx

  #   tfvb.vertTris.se0.normal = topTriNormals[0]
  #   tfvb.vertTris.sw0.normal = topTriNormals[0]
  #   tfvb.vertTris.sw1.normal = topTriNormals[0]
  #   tfvb.vertTris.nw0.normal = topTriNormals[0]
  #   tfvb.vertTris.nw1.normal = topTriNormals[1]
  #   tfvb.vertTris.ne0.normal = topTriNormals[1]
  #   tfvb.vertTris.ne1.normal = topTriNormals[1]
  #   tfvb.vertTris.se1.normal = topTriNormals[1]

  # var currProvoking: ptr Vertex = outVert
  # while currProvoking < outVert + (5 * vertsPerSideFace):
  #   currProvoking.blendMode = bmNoBlend
  #   currProvoking += 3

  # currProvoking = outVert + (5 * vertsPerSideFace)
  # while currProvoking < outVert + vertsPerTile:
  #   currProvoking.blendMode = tile.blendMode
  #   currProvoking += 3