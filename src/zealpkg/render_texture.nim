import bgfxdotnim, texture

const TILE_TEX_RES = 128

proc createTextureArrayMap*(texnames: seq[string]): bgfx_texture_handle_t =
  var textureArrayData: seq[uint8] = @[]

  for texname in texnames:
    var image: Image 
    
    if not loadDds("assets/map_textures/" & texname, image):
      return

    var resizedImageData = newSeq[uint8](TILE_TEX_RES * TILE_TEX_RES)
    let res = stbir_resize_uint8(
      addr image.data[0], cint(image.width), cint(image.height), 0, 
      addr resizedImageData[0], TILE_TEX_RES, TILE_TEX_RES, 0, 1
    )
    
    assert(res == 1)
    textureArrayData.add(resizedImageData)
  
  var mem = bgfx_make_ref(
    cast[pointer](addr textureArrayData[0]), 
    uint32(len(textureArrayData) * sizeof(uint8))
  )
  result = bgfx_create_texture_2d(
    uint16(TILE_TEX_RES), 
    uint16(TILE_TEX_RES), 
    false,
    uint16(len(texnames)), 
    BGFX_TEXTURE_FORMAT_BC7, 
    BGFX_TEXTURE_NONE or BGFX_SAMPLER_NONE, 
    mem
  )