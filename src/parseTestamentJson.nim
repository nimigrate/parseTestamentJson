
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



proc echoAllTestNameWrap(e: EventArg) =
  const expected = ["-m", "--markdown", "--md"]
  var md: bool
  case e.len
  of 0: md = false
  of 1: md = e[0] in expected
  else:
    quit "only one of " & $expected & " expected, but got " & $e
  echoAllTestname md

when isMainModule:
  var tcli = MyCli()
  tcli.subCmds(
    ("filenames", echoAllTestNameWrap),
    ("all", echoStatusDiffMap),
  )
  tcli.keyMapper = normalize
  tcli.run()
