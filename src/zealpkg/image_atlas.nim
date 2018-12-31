import  engine_types, math, image, rect_packer

proc newImageAtlas*[T](size: IVec2): T =
  result = new(T)
  result.size = size
  result.inverseSize = 1.0 / vec2(size)
  result.image = newImage("ImageAtlas", "", result.size)

proc newSpriteAtlas*(size: IVec2): SpriteAtlas =
  result = newImageAtlas[SpriteAtlas](size)
  result.rectPack = newPacker(result.size[0].int32, result.size[1].int32)