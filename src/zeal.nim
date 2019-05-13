import zealpkg / [app, gfx, pipeline]

proc update(app: App) =
  discard

when isMainModule:
  var zealApp = newApp()
  zealApp.gfx.initPipeline(pipelineMinimal)
  zealApp.run(update)