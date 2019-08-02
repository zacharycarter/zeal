import bgfxdotnim, vertex

type
  Mesh* = object
    numVerts*: int
    vDecl*: bgfx_vertex_decl_t
    vBuff*: seq[Vertex]
    vBuffHandle*: bgfx_dynamic_vertex_buffer_handle_t
    iBuffHandle*: bgfx_index_buffer_handle_t
