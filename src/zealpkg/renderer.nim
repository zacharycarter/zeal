import  engine_types, tables

proc newRenderPass*[T](gfx: var GfxCtx, name: string, rpk: RenderPassKind): T =
  result = new(T)
  result.name = name
  result.renderPassKind = rpk
  result.steps = gfx.pipeline.passSteps[rpk]

proc submitRenderPass(rp: RenderPass, render: var Render) =
  discard

proc stepsBeginPass(rp: RenderPass, render: var Render) =
  for step in rp.steps:
    step.beginPass(render)

proc render*(r: Renderer, render: var Render) =
  for step in r.steps:
    step.beginRender(render)
  
  render.isMRT = (render.target != nil) and render.target.mrt

  for pass in r.renderPasses:
    pass.stepsBeginPass(render)
    pass.submitRenderPass(render)