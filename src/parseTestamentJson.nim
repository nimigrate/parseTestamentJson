
import parseTestamentJson/mains
import parseTestamentJson/cli
import std/strutils

func normalize(s: string): string =
  ## as like Python's encoding name's normalize
  s.multiReplace(
    ("_", ""),
    ("-", ""),
  ).toLowerAscii()

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
