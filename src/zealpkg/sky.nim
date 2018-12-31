import  engine_types,
        bgfxdotnim

proc createUniforms(): SkyboxUniform =
  result.skyboxMatrix = bgfx_create_uniform("u_skybox_matrix", BGFX_UNIFORM_TYPE_MAT4, 1)
  result.skyboxParams = bgfx_create_uniform("u_skybox_params", BGFX_UNIFORM_TYPE_VEC4, 1)
  result.skyboxMap = bgfx_create_uniform("u_skybox_map", BGFX_UNIFORM_TYPE_INT1, 1)

proc newSkyStep*(gfx: var GfxCtx, filter: FilterStep): SkyStep =
  result = SkyStep(newPipelineStep[SkyStep]())
  result.filter = filter
  result.skyboxProgram = gfx.newProgram("skybox")