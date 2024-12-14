
import parseTestamentJson/mains
import parseTestamentJson/cli
from std/strutils import normalize

type MyCli = ref object of Cli

using self: MyCli
method onNoArgv(self) =
  echoStatusDiffMap()
  quit 0


when isMainModule:
  var tcli = MyCli()
  tcli.subCmds(
    ("listnames", echoAllTestName),
    ("markdown", echoStatusDiffMap),
  )
  tcli.keyMapper = normalize
  tcli.run()
