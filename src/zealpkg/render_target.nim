import  engine_types, math,
        bgfxdotnim

proc fboDestQuad(size: Vec2, rect: var Vec4, relative = false): Vec4 =
  result = rect
  if relative and bgfx_get_caps().originBottomLeft:
    result[1] = size[1] - rect[1] - rect[3]

proc fboSourceQuad(size: Vec2, rect: var Vec4, relative = false): Vec4 =
  result = vec4([rect[0], rect[1]] / size, [rect[2], rect[3]] / size)
  if relative and bgfx_get_caps().originBottomLeft:
    result[1] = 1.0 - result[1] - result[3]


proc destQuad*(fb: FrameBuffer, rect: var Vec4, originFBO = false): Vec4 =
  result = fboDestQuad(fb.size, rect, originFBO)

proc sourceQuad*(fb: FrameBuffer, rect: var Vec4, originFBO = false): Vec4 =
  result = fboSourceQuad(fb.size, rect, originFBO)

proc newFrameBuffer*(size: Vec2): FrameBuffer =
  result.size = size
  result.screenView = mtxIdentity()