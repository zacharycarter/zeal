
import renderer

type
  GfxSystem* = object
    renderer: Renderer

  PipelineDecl = (proc(gfx: var GfxSystem, pipeline: var Renderer, deferred: bool))

proc initPipeline*(gfx: var GfxSystem, decl: PipelineDecl) =
  decl(gfx, gfx.renderer, false)

proc newGfxCtx*(): GfxSystem =
  result