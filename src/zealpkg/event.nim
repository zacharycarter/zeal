import deques, sdl2 as sdl, tables

const globalId = not uint32(0)

type
  EventSource* = enum
    esEngine,
    esScript

  EventKind* {.size: sizeof(uint32).} = enum
    #
    # +-----------------+-----------------------------------------------+
    # | Range           | Use                                           |
    # +-----------------+-----------------------------------------------+
    # | 0x0-0xffff      | SDL events                                    |
    # +-----------------+-----------------------------------------------+
    # | 0x10000-0x1ffff | Engine-generated events                       |
    # +-----------------+-----------------------------------------------+
    # | 0x20000-0x2ffff | Script-generated events                       |
    # +-----------------+-----------------------------------------------+
    #
    # The very first event serviced during a tick is a single EVENT_UPDATE_START one.
    # The very last event serviced during a tick is a single EVENT_UPDATE_END one. 
    #
    ekUpdateStart = uint32(sdl.LastEvent) + 1,
    ekUpdateEnd,
    ekUpdateUI,
    ekRender3D,
    ekRenderUI,
    ekEngineLast = 0x1ffff,

  HandlerKind* = enum
    hkEngine
    hkScript
  
  HandlerProc* = proc (a1: pointer; a2: pointer)

  Handler* {.union.} = object
    asProc*: HandlerProc
    # asScriptCallable*: ScriptOpaque
  
  HandlerDesc* = object
    kind: HandlerKind
    handler: Handler
    userArg: pointer
    simMask: int32
  
  Event = object
    kind: EventKind
    arg: pointer
    source: EventSource
    receiverId: uint32

var 
  eventHandlers: Table[uint64, seq[HandlerDesc]]
  eventQueue: Deque[Event]

proc key(entId: uint32, eventKind: EventKind): uint64 =
  result = (uint64(entId) shl 32) or uint64(eventKind)

proc registerHandler(key: uint64, handlerDesc: HandlerDesc) =
  if eventHandlers.hasKey(key):
    eventHandlers[key].add(handlerDesc)
  else:
    eventHandlers.add(key, @[handlerDesc])

proc handleEvent(event: Event) =
  let key = key(event.receiverId, event.kind)

  if not eventHandlers.hasKey(key):
    return

  let handlers = eventHandlers[key]
  
  for eventHandler in handlers:
    if eventHandler.kind == hkEngine:
      eventHandler.handler.asProc(eventHandler.userArg, event.arg)

proc unregisterHandler(key: uint64, handlerDesc: HandlerDesc) =
  if eventHandlers.hasKey(key):
    let handlerIdx = eventHandlers[key].find(handlerDesc)
    if handlerIdx != -1:
      eventHandlers[key].del(handlerIdx)

proc globalUnregister*(eventKind: EventKind, handlerProc: HandlerProc) =
  unregisterHandler(
    key(globalId, eventKind),
    HandlerDesc(
      kind: hkEngine,
      handler: Handler(
        asProc: handlerProc
      )
    )
  )

proc globalRegister*(eventKind: EventKind, handlerProc: HandlerProc, userArg: pointer, simMask: int32) =
  registerHandler(
    key(globalId, eventKind), 
    HandlerDesc(
      kind: hkEngine,
      handler: Handler(
        asProc: handlerProc
      ),
      userArg: userArg,
      simMask: simMask
    )
  )

proc globalNotify*(eventKind: EventKind, eventArg: pointer, eventSource: EventSource) =
  eventQueue.addLast(
    Event(
      kind: eventKind,
      arg: eventArg,
      source: eventSource,
      receiverId: globalId
    )
  )

proc init*() =
  eventQueue = initDeque[Event]()

proc serviceQueue*() =
  while len(eventQueue) > 0:
    handleEvent(eventQueue.popFirst())

  handleEvent(Event(kind: ekUpdateEnd, arg: nil, source: esEngine, receiverId: globalId))