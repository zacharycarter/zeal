import sdl2 as sdl

type
  EventType* {.size: sizeof(uint32).} = enum
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
    etUpdateStart = uint32(sdl.LastEvent) + 1,
    etUpdateEnd,
    etUpdateUI,
    etRender3D,
    etRenderUI,
    etEngineLast = 0x1ffff,


    