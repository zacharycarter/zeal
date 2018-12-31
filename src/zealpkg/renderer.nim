import  engine_types, pipeline

type
  RenderPassKind* = enum
    rpkCount

  RenderPass* = object
    name: string
    passKind: RenderPassKind
    steps: seq[PipelineStep]

  Renderer* = object
    steps: seq[PipelineStep]
    renderPasses: seq[RenderPass]

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