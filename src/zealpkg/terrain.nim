import bgfxdotnim, render_texture, texture

var
  mapTextures*: TextureArray

proc initMapTextures*(texFilenames: seq[string]) =
  mapTextures.handle = createTextureArrayMap(texFilenames)

proc destroy*() =
  bgfx_destroy_texture(mapTextures.handle)