
import std/json
#from std/testament/specs import TResultEnum

type TResultEnum* = enum
  reNimcCrash,       # nim compiler seems to have crashed
  reMsgsDiffer,      # error messages differ
  reFilesDiffer,     # expected and given filenames differ
  reLinesDiffer,     # expected and given line numbers differ
  reOutputsDiffer,
  reExitcodesDiffer, # exit codes of program or of valgrind differ
  reTimeout,
  reInvalidPeg,
  reCodegenFailure,
  reCodeNotFound,
  reExeNotFound,
  reInstallFailed,    # package installation failed
  reBuildFailed,      # package building failed
  reDisabled,        # test is disabled
  reJoined,          # test is disabled because it was joined into the megatest
  reSuccess,          # test was successful
  reInvalidSpec,      # test had problems to parse the spec
type Backend*{.pure.} = enum
  c, cpp, objc, js

type
  RunRecord* = tuple
    node: JsonNode
    status: TResultEnum
    backend: Backend
    args: seq[string]
type
  FileRecord* = object
    name*: string
    data*: seq[RunRecord]

