import math, options, strutils, tile, map, streams, strscans

proc parseMapHeader(stream: FileStream, mapHeader: var MapHeader) =
  var line: string

  try:
    assert stream.readLine(line)
    assert scanf(line, "version $f", mapHeader.version)
    assert stream.readLine(line)
    assert scanf(line, "num_materials $i", mapHeader.numMaterials)
    assert stream.readLine(line)
    assert scanf(line, "num_rows $i", mapHeader.numRows)
    assert stream.readLine(line)
    assert scanf(line, "num_cols $i", mapHeader.numCols)
  except:
    raise newException(MapParsingError, "failed parsing map header")

proc loadMapFromStream(basePath: string): Map =
  var
    header: MapHeader
    stream: FileStream

  stream = openFileStream(basePath)

  try:
    parseMapHeader(stream, header)
    result = initMap(header, basePath, stream)
  except:
    raise
  finally:
    stream.close()

proc loadMap*(mapDir: string, mapName: string): Map =
  let basePath = "$1/$2" % [mapDir, mapName]
  result = loadMapFromStream(basePath)
  return result
