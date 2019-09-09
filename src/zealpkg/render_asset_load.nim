import render, tile, vertex

# proc initRenderDataFromTiles*(tiles: openArray[Tile], width, height: int, renderData: var RenderData) =
#   let numVerts = vertsPerTile * (width * height)

#   renderData.mesh.numVerts = numVerts
#   renderData.mesh.vBuff = newSeq[Vertex](numVerts)
#   for r in 0 ..< height:
#     for c in 0 ..< width:
#       var tile = tiles[r * width + c]
#       getTileVertices(tile, addr renderData.mesh.vBuff[(r * width + c) * vertsPerTile], r, c)
  
#   initVBuff(renderData, "terrain", renderData.mesh.vBuff)