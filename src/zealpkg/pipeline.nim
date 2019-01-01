import  engine_types, math, program, 
        render_target, renderer,
        filter, blur, depth, sky, 
        radiance, shadow, light, 
        reflection, voxel_gi, lightmap, 
        particles, image_atlas, effects, 
        dof_blur, glow, tonemap,
        tables, typetraits,
        bgfxdotnim

const ZEAL_GFX_STATE_DEFAULT = 0'u64 or 
        BGFX_STATE_WRITE_RGB or 
        BGFX_STATE_WRITE_A or 
        BGFX_STATE_DEPTH_TEST_LEQUAL or 
        BGFX_STATE_WRITE_Z or
        BGFX_STATE_CULL_CW or
        BGFX_STATE_MSAA

const ZEAL_GFX_STATE_DEFAULT_ALPHA = 0'u64 or 
              BGFX_STATE_WRITE_RGB or 
              BGFX_STATE_WRITE_A or 
              BGFX_STATE_DEPTH_TEST_LESS or 
              BGFX_STATE_MSAA or
              BGFX_STATE_BLEND_ALPHA

type
  ForwardRenderer = ref object of Renderer

proc step(p: Pipeline, stepType: typedesc): stepType =
  for step in p.steps:
    if step is stepType:
      return stepType(step)

proc addStep[T](p: var Pipeline, s: T): T =
  p.steps.add(s)
  result = s

proc newGeometryStep(gfx: var GfxCtx): GeometryStep =
  result = newDrawStep[GeometryStep]()

proc newForwardRenderer(gfx: var GfxCtx): ForwardRenderer =
  result = newRenderer[ForwardRenderer](gfx, gfx.pipeline, sShaded)
  
  discard result.addPass(newGIProbesPass(gfx, gfx.pipeline.step(LightStep), gfx.pipeline.step(GIBakeStep)))
  discard result.addPass(newShadowmapPass(gfx, gfx.pipeline.step(ShadowStep)))


proc pbr*(gfx: var GfxCtx) =
  # filters
  var 
    filter = gfx.pipeline.addStep(newFilterStep(gfx))
    copy = gfx.pipeline.addStep(newCopyStep(gfx, filter))
    blur = gfx.pipeline.addStep(newBlurStep(gfx, filter))

  # pipeline
    depth = gfx.pipeline.addStep(newDepthStep(gfx))
    geometry = gfx.pipeline.addStep(newGeometryStep(gfx))
    sky = gfx.pipeline.addStep(newSkyStep(gfx, filter))
    radiance = gfx.pipeline.addStep(newRadianceStep(gfx, filter, copy))
    shadow = gfx.pipeline.addStep(newShadowStep(gfx, depth))
    light = gfx.pipeline.addStep(newLightStep(gfx, shadow))
    reflection = gfx.pipeline.addStep(newReflectionStep(gfx))
    giTrace = gfx.pipeline.addStep(newGITraceStep(gfx))
    giBake = gfx.pipeline.addStep(newGIBakeStep(gfx, light, giTrace))
    lightmap = gfx.pipeline.addStep(newLightmapStep(gfx, light, giBake))
    particles = gfx.pipeline.addStep(newParticlesStep(gfx))

  # mrt
    resolve = gfx.pipeline.addStep(newResolveStep(gfx, copy))

  # effects
    dofBlur = gfx.pipeline.addStep(newDOFBlurStep(gfx, filter))
    glow = gfx.pipeline.addStep(newGlowStep(gfx, filter, copy, blur))
    tonemap = gfx.pipeline.addStep(newTonemapStep(gfx, filter, copy))

  let 
    depthSteps = @[PipelineStep(depth)]
    geometrySteps: seq[PipelineStep] = @[]
    shadingSteps = @[
      PipelineStep(radiance), 
      PipelineStep(light), 
      PipelineStep(shadow), 
      PipelineStep(giTrace), 
      PipelineStep(reflection), 
      PipelineStep(lightmap),
    ]
    giSteps = @[PipelineStep(light), PipelineStep(shadow), PipelineStep(giBake)]
    lightmapSteps = @[PipelineStep(light), PipelineStep(shadow), PipelineStep(giTrace), PipelineStep(lightmap)]

  gfx.pipeline.passSteps = initTable[RenderPassKind, seq[PipelineStep]]()
  gfx.pipeline.passSteps[rpkUnshaded] = @[]
  gfx.pipeline.passSteps[rpkBackground] = @[PipelineStep(sky)]
  gfx.pipeline.passSteps[rpkEffects] = @[PipelineStep(resolve)]
  gfx.pipeline.passSteps[rpkPostProcess] = @[
    PipelineStep(dofBlur), 
    PipelineStep(glow), 
    PipelineStep(tonemap),
  ]

  gfx.pipeline.passSteps[rpkVoxelGI] = giSteps
  gfx.pipeline.passSteps[rpkLightmap] = lightmapSteps

  # forward
  gfx.pipeline.passSteps[rpkDepth] = depthSteps
  gfx.pipeline.passSteps[rpkOpaque] = shadingSteps
  gfx.pipeline.passSteps[rpkAlpha] = shadingSteps

  # deferred
  gfx.pipeline.passSteps[rpkGeometry] = geometrySteps
  gfx.pipeline.passSteps[rpkLights] = shadingSteps

  var unshadedProgram = gfx.newProgram("unshaded")
  unshadedProgram.registerSteps(depthSteps)
  
  var depthProgram = gfx.newProgram("depth")
  depthProgram.registerSteps(depthSteps)

  var pbrProgram = gfx.newProgram("pbr/pbr")
  pbrProgram.registerSteps(shadingSteps)
  
  var geometryProgram = gfx.newProgram("pbr/geometry")
  geometryProgram.registerSteps(geometrySteps)
  
  var lightsProgram = gfx.newProgram("pbr/lights")
  lightsProgram.registerSteps(shadingSteps)
  
  discard gfx.newProgram("fresnel")
  
  var giVoxelizeProgram = gfx.newProgram("gi/voxelize")
  giVoxelizeProgram.registerSteps(giSteps)
  
  var giVoxelLightProgram = gfx.newProgram("gi/direct_light")
  giVoxelLightProgram.compute = true
  giVoxelLightProgram.registerSteps(giSteps)

  var giVoxelBounceProgram = gfx.newProgram("gi/bounce_light")
  giVoxelBounceProgram.compute = true
  giVoxelBounceProgram.registerSteps(giSteps)

  var giVoxelOutputProgram = gfx.newProgram("gi/output_light")
  giVoxelOutputProgram.compute = true
  giVoxelOutputProgram.registerSteps(giSteps)
    
  var lightmapProgram = gfx.newProgram("pbr/lightmap")
  lightmapProgram.registerSteps(lightmapSteps)

  let forwardRenderer {.global.} = newForwardRenderer(gfx)