import asset, map, options

type
  SimState* {.size: sizeof(int32).} = enum
    ssRunning = (1 shl 0),
    ssPausedFull = (1 shl 1),
    ssPausedUiRunning = (1 shl 2)
  
  GameState = object
    simState: SimState
    simStateChangeTick: uint32
    map: Map

var gameState: GameState

proc newGame*(mapDir: string, mapName: string) =
  try:
    gameState.map = get(loadMap(mapDir, mapName))
  except UnpackError:
    discard