import bgfxdotnim, asset, camera, camera_controls, entity, tile, map, render, collision, fpmath, tables, simulation, shader, terrain_new

const 
  numCameras = 2
  camHeight = 175.0f
  camTiltUpDegrees = 25.0f
  camSpeed = 0.20f

type
  CameraMode = enum
    cmRTS,
    cmFPS
  
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

  case mode
  of cmRTS: rtsControls(gamestate.cameras[camIdx])
  of cmFPS: discard # fpsControls(gamestate.cameras[camIdx])


proc reset(camera: var Camera) =
  # setPitchAndYaw(camera, -(90.0'f32 - camTiltUpDegrees), 90.0'f32 + 45.0'f32)
  # setPosition(camera, [0.0'f32, camHeight, 0.0])
  setPosition(camera, [0.0'f32, 0.5, 0.0])

proc initCameras() =
  for i in 0 ..< numCameras:
    setSpeed(gameState.cameras[i], camSpeed)
    setSensitivity(gameState.cameras[i], 0.05'f32)
    reset(gameState.cameras[i])

proc reset() =
  gameState.map.destroy()

  for i in 0 ..< numCameras:
    reset(gameState.cameras[i])

  activateCamera(0, cmRTS)

proc render*() =
  renderVisibleMap(gameState.map, gameState.cameras[gamestate.activeCamIdx], rpRegular)
  discard bgfx_frame(false)

proc initMap() =
  centerAtOrigin(gameState.map)

proc init*() =
  initCameras()
  initNewTerrain()
  reset()

proc update*() =
  updateNewTerrain()

proc newGame*(mapDir: string, mapName: string) =
  reset()

  echo "creating new game - loading map..."
  # gameState.map = loadMap(mapDir, mapName)

  # initMap()

proc shutdown*() =
  reset()