# Package

version       = "0.1.0"
author        = "litlighilit"
description   = "Parser for nim's koch test result"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["parseKochTestJson"]


# Dependencies

requires "nim >= 2.0.0"
