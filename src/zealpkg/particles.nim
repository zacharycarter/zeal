import  engine_types, math, image_atlas

proc newParticlesStep*(gfx: var GfxCtx): ParticlesStep =
  result = newPipelineStep[ParticlesStep]()
  result.sprites = newSpriteAtlas(iVec2(SPRITE_TEXTURE_SIZE))