import math, options, strutils, map, streams, strscans

type  
  MapParsingError = object of Exception

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
  finally:
    stream.close()

proc loadMapFromStream(basePath: string, stream: var FileStream): Option[Map] =
  var header: MapHeader

  try:
    stream = newFileStream(basePath)
  except IOError:
    return none[Map]()

  try:
    parseMapHeader(stream, header)
    result = initMap(header, basePath, stream)
  except MapParsingError:
    return none[Map]()

proc loadMap*(mapDir: string, mapName: string): Option[Map] =
  let basePath = "$1/$2" % [mapDir, mapName]
  
  var stream: FileStream

  result = loadMapFromStream(basePath, stream)
  return result