import render, tile, vertex

proc initRenderDataFromTiles*(tiles: openArray[Tile], width, height: int, renderData: var RenderData) =
  let numVerts = vertsPerTile * (width * height)

  renderData.mesh.numVerts = numVerts
  
  var vBuff = newSeq[Vertex](numVerts)
  for r in 0 ..< height:
    for c in 0 ..< width:
      getTileVertices(tiles[r * width + c], addr vbuff[(r * width + c) * vertsPerTile], r, c)
  
  initVBuff(renderData, "terrain", vbuff)
  

