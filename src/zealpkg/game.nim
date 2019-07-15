import asset, entity, map, collision, options, tables

type
  SimState* {.size: sizeof(int32).} = enum
    ssRunning = (1 shl 0),
    ssPausedFull = (1 shl 1),
    ssPausedUiRunning = (1 shl 2)
  
  GameState = object
    simState: SimState
    #-------------------------------------------------------------------------
    # The SDL tick during which we last changed simulation states.
    #-------------------------------------------------------------------------
    simStateChangeTick: uint32
    #-------------------------------------------------------------------------
    # The set of entities potentially visible by the active camera.
    #-------------------------------------------------------------------------
    active: Table[string, Entity]
    #-------------------------------------------------------------------------
    # The set of entities potentially visible by the active camera.
    #-------------------------------------------------------------------------
    visible: seq[Entity]
    #-------------------------------------------------------------------------
    # Cache of current-frame OBBs for visible entities.
    #-------------------------------------------------------------------------
    visibleObbs: seq[Obb]
    #-------------------------------------------------------------------------
    # Up-to-date set of all non-static entities. (Subset of 'active' set). 
    # Used for collision avoidance force computations.
    #-------------------------------------------------------------------------
    dynamic: Table[string, Entity]
    numFactions: int
    map: Map

var gameState: GameState

proc init*() =
  discard

proc newGame*(mapDir: string, mapName: string) =
  echo "creating new game - loading map..."
  gameState.map = loadMap(mapDir, mapName)