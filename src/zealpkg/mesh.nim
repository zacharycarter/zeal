import bgfxdotnim

type
  Mesh* = object
    numVerts*: int
    handle*: bgfx_vertex_buffer_handle_t
