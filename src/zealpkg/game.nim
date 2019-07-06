type
  SimState* {.size: sizeof(int32).} = enum
    ssRunning = (1 shl 0),
    ssPausedFull = (1 shl 1),
    ssPausedUiRunning = (1 shl 2)
  
  GameState = object
    simState: SimState
    simStateChangeTick: uint32
    map: Map

proc newGame(mapDir: string, mapName: string) =
