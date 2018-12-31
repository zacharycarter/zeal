import  engine_types, math

proc newImage*(name: string, path: string, size: IVec2): Image =
  result = new(Image)
  result.name = name
  result.path = path
  result.size = size
  result.handle = -1