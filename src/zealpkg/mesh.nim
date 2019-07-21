import bgfxdotnim

type
  Mesh* = object
    numVerts*: int
    vDecl*: bgfx_vertex_decl_t
    vBuffHandle*: bgfx_vertex_buffer_handle_t
    iBuffHandle*: bgfx_index_buffer_handle_t
