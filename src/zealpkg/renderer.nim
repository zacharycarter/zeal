import  engine_types, pipeline

type
  RenderPassKind* = enum
    rpkVoxelGI, rpkLightmap, rpkShadowmap, rpkProbes, 
    rpkClear, rpkDepth, rpkGeometry, rpkLights, rpkOpaque, 
    rpkBackground, rpkParticles, rpkAlpha, rpkUnshaded, 
    rpkEffects, rpkPostProcess, rpkFlip, rpkCount

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