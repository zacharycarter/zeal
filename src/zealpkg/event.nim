import sdl2 as sdl

type
  EventType* {.size: sizeof(uint32).} = enum
    etUpdateStart = uint32(sdl.LastEvent) + 1,
    etUpdateEnd,
    etUpdateUI,
    etRender3D,
    etRenderUI,
    etEngineLast = 0x1ffff,


    