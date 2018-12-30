import  tables,
        primitive,
        bgfxdotnim

proc newVertexDecl(vertexFormat: uint32): bgfx_vertex_decl_t =
  let halfSupport = (bgfx_get_caps().supported and BGFX_CAPS_VERTEX_ATTRIB_HALF.uint64) != 0
  let needsHalf = (vertexFormat and VERTEX_ATTRIBUTE_QTEXCOORD0) != 0 or (vertexFormat and VERTEX_ATTRIBUTE_QTEXCOORD1) != 0

  if needsHalf and not halfSupport:
    echo "WARNING: half vertex attribute not supported but used by texcoords"
  
  var normalizeIndices = false
  when defined(emscripten):
    normalizeIndices = true
  
  bgfx_vertex_decl_begin(addr result, bgfx_get_renderer_type())

  if (vertexFormat and VERTEX_ATTRIBUTE_POSITION) != 0:
    bgfx_vertex_decl_add(addr result, BGFX_ATTRIB_POSITION, 3, BGFX_ATTRIB_TYPE_FLOAT, false, false)
  if (vertexFormat and VERTEX_ATTRIBUTE_QPOSITION) != 0:
    bgfx_vertex_decl_add(addr result, BGFX_ATTRIB_POSITION, 3, BGFX_ATTRIB_TYPE_HALF, false, false)
  if (vertexFormat and VERTEX_ATTRIBUTE_NORMAL) != 0:
    bgfx_vertex_decl_add(addr result, BGFX_ATTRIB_NORMAL, 3, BGFX_ATTRIB_TYPE_FLOAT, false, false)
  if (vertexFormat and VERTEX_ATTRIBUTE_QNORMAL) != 0:
    bgfx_vertex_decl_add(addr result, BGFX_ATTRIB_NORMAL, 4, BGFX_ATTRIB_TYPE_UINT8, false, false)
  if (vertexFormat and VERTEX_ATTRIBUTE_COLOR) != 0:
    bgfx_vertex_decl_add(addr result, BGFX_ATTRIB_COLOR0, 4, BGFX_ATTRIB_TYPE_UINT8, true, false)
  if (vertexFormat and VERTEX_ATTRIBUTE_TANGENT) != 0:
    bgfx_vertex_decl_add(addr result, BGFX_ATTRIB_TANGENT, 4, BGFX_ATTRIB_TYPE_FLOAT, false, false)
  if (vertexFormat and VERTEX_ATTRIBUTE_QTANGENT) != 0:
    bgfx_vertex_decl_add(addr result, BGFX_ATTRIB_TANGENT, 4, BGFX_ATTRIB_TYPE_UINT8, false, false)
  if (vertexFormat and VERTEX_ATTRIBUTE_BITANGENT) != 0:
    bgfx_vertex_decl_add(addr result, BGFX_ATTRIB_TANGENT, 3, BGFX_ATTRIB_TYPE_FLOAT, false, false)
  if (vertexFormat and VERTEX_ATTRIBUTE_TEXCOORD0) != 0:
    bgfx_vertex_decl_add(addr result, BGFX_ATTRIB_TEXCOORD0, 2, BGFX_ATTRIB_TYPE_FLOAT, false, false)
  if (vertexFormat and VERTEX_ATTRIBUTE_QTEXCOORD0) != 0:
    bgfx_vertex_decl_add(addr result, BGFX_ATTRIB_TEXCOORD0, 2, BGFX_ATTRIB_TYPE_HALF, false, false)
  if (vertexFormat and VERTEX_ATTRIBUTE_TEXCOORD1) != 0:
    bgfx_vertex_decl_add(addr result, BGFX_ATTRIB_TEXCOORD1, 2, BGFX_ATTRIB_TYPE_FLOAT, false, false)
  if (vertexFormat and VERTEX_ATTRIBUTE_QTEXCOORD1) != 0:
    bgfx_vertex_decl_add(addr result, BGFX_ATTRIB_TEXCOORD1, 2, BGFX_ATTRIB_TYPE_HALF, false, false)
  if (vertexFormat and VERTEX_ATTRIBUTE_JOINTS) != 0:
    bgfx_vertex_decl_add(addr result, BGFX_ATTRIB_INDICES, 4, BGFX_ATTRIB_TYPE_UINT8, normalizeIndices, false)
  if (vertexFormat and VERTEX_ATTRIBUTE_WEIGHTS) != 0:
    bgfx_vertex_decl_add(addr result, BGFX_ATTRIB_WEIGHT, 4, BGFX_ATTRIB_TYPE_FLOAT, false, false)

  bgfx_vertex_decl_end(addr result)

proc vertexDecl*(vertexFormat: uint32): bgfx_vertex_decl_t =
  var decls {.global.} = initTable[uint32, bgfx_vertex_decl_t]()
  discard decls.hasKeyOrPut(vertexFormat, newVertexDecl(vertexFormat))
  result = decls[vertexFormat]