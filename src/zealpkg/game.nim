import asset, camera, entity, map, render, collision, fpmath, tables

const 
  numCameras = 2
  camHeight = 175.0f
  camTiltUpDegrees = 25.0f
  camSpeed = 0.20f

type
  CameraMode = enum
    cmRTS,
    cmFPS

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
    map: Map
    activeCamIdx: int
    cameras: array[numCameras, Camera]
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

var gameState: GameState

proc activateCamera(camIdx: int, mode: CameraMode) =
  if not (camIdx >= 0 and camIdx < numCameras):
    return
  
  gameState.activeCamIdx = camIdx

  # TODO: Camera Controls
  # case mode
  # of cmRTS: cameraControlRTS(gamestate.cameras[camIdx])
  # of cmFPS: cameraControlFPS(gamestate.cameras[camIdx])


proc reset(camera: var Camera) =
  setPitchAndYaw(camera, -(90.0'f32 - camTiltUpDegrees), 90.0'f32 + 45.0'f32)
  setPosition(camera, [0.0'f32, camHeight, 0.0])

proc initCameras() =
  for i in 0 ..< numCameras:
    setSpeed(gameState.cameras[i], camSpeed)
    setSensitivity(gameState.cameras[i], 0.05'f32)
    reset(gameState.cameras[i])

proc reset() =
  activateCamera(0, cmRTS)

proc render*() =
  renderVisibleMap(gameState.map, gameState.cameras[gamestate.activeCamIdx], rpRegular)

proc init*() =
  discard

proc newGame*(mapDir: string, mapName: string) =
  echo "creating new game - loading map..."
  gameState.map = loadMap(mapDir, mapName)