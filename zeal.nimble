# Package

version       = "0.1.0"
author        = "Zachary Carter"
description   = "game engine"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["zeal"]


# Dependencies

requires "nim >= 0.19.0"
requires "bgfxdotnim >= 0.1.0"
requires "rect_packer >= 0.1.0"