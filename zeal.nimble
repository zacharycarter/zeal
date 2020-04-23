# Package

version       = "0.1.0"
author        = "Zachary Carter"
description   = "game engine"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
installDirs   = @["src/zealpkg"]
bin           = @["zeal"]
binDir        = "."

# Dependencies

requires "nim >= 0.20.2"
requires "compiler >= 0.20.2"
requires "bgfxdotnim >= 0.1.0"
requires "sdl2 >= 2.0.0"
requires "https://github.com/zacharycarter/bimg.nim"
requires "nimLUA >= 0.3.7"
