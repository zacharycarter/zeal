import  math

type
  FrameBuffer* = object
    size*: int
    screenView*: Mat4
    screenProj*: Mat4

proc newFrameBuffer*(size: int): FrameBuffer =
  result.size = size
  result.screenView = mtxIdentity()