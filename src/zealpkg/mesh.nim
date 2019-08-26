import bgfxdotnim, vertex

type
  Mesh* = object
    numVerts*: int
    vLayout*: bgfx_vertex_layout_t
    vBuff*: seq[Vertex]
    vBuffHandle*: bgfx_vertex_buffer_handle_t
    iBuffHandle*: bgfx_index_buffer_handle_t
