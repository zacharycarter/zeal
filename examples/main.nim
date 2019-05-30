import zeal, sdl2

proc appUpdate(window: sdl2.WindowPtr) =
  discard

if not zeal.init(960, 540):
  echo "Failed to initialize zeal"
  quit(QUIT_FAILURE)

zeal.run(appUpdate)
zeal.shutdown()