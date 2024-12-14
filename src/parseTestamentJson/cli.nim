
import std/cmdline
import std/tables
import std/sequtils
import std/macros

{.pragma: cliCall, closure.}

proc noop(s: string): string = s
type
  EventArg* = openArray[string]
  CliCallbackNullary* = proc (){.cliCall.}
  CliCallback* = proc (e: EventArg){.cliCall.}
  CliCallbackObj = tuple
    call: CliCallback
    help: string
  Cli* = ref object of RootObj
    map: Table[string, CliCallbackObj]
    keyMapper*: proc(key: string): string = noop
    addHelp* = true

type Nullary* = concept self
  self()

template toCliCallback(cb; key): CliCallback =
    proc (e: EventArg){.closure.} =
      if e.len != 0:
        quit key.repr & " accept no argument"
      cb()


type CliCb = CliCallbackNullary|CliCallback|Nullary
template cliCbObj(_: string; cb: CliCallback; help: string): CliCallbackObj = (cb, help)
template cliCbObj(key: string; cb: CliCb; help: string): CliCallbackObj{.dirty.} =
  bind cliCbObj, toCliCallback
  block:
   cliCbObj key,
    toCliCallback(cb, key),
    help

using mself: Cli
#proc subCmds*(mself; map: openArray[(string, CliCallbackObj)]) = mself.map = map.toTable

proc extractDocCommentsWithoutSharp(body: NimNode): string =
  for st in body:
    case st.kind
    of nnkCommentStmt:
      result.add st.`$`
    else: break

proc subCmdImpl(mself: NimNode; subcmd: NimNode, call: NimNode): NimNode =
  result = newStmtList()
  var docStr = $subcmd
  docStr.add ":\n"
  docStr.add extractDocCommentsWithoutSharp call.getImpl.body
  let doc = newLit docStr
  let init = bindSym"cliCbObj"
  result.add quote do:
    `mself`.map[`subcmd`] = `init`(`subcmd`, `call`, `doc`)

macro subCmd*(mself: Cli; subcmd: string, call: CliCb) =
  ## will use `call`'s docComment as `help` string
  subCmdImpl mself, subcmd, call

macro subCmds*(mself: Cli;
    subcmds: varargs[(string, typed)]) =
  ## will use `call`'s docComment as `help` string
  result = newStmtList()
  for kv in subcmds:
    let
      k = newLit $kv[0]
      v = kv[1]
    result.add mself.subCmdImpl(k, v)

template keysToStr(m): string = m.keys().toSeq().`$`[1..^1]

using self: Cli
method onUnknownSubCmd*(self; subcmd: string){.base, noReturn.} =
  ## called on unknown subcmd
  quit "one subcmd of " & self.map.keysToStr & " expected, but got " & subcmd.repr

method onNoArgv*(self){.base, noReturn.} =
  ## called when `argc == 1`
  quit "no argv is given"

func isHelp(arg: string): bool = arg in ["-h", "--help", "-help"]

proc run*(self: Cli; args = commandLineParams()) =
  ## main routine that parse args and run according callback
  if args.len == 0:
    self.onNoArgv()
  let subcmd = args[0]
  if self.addHelp:
    if subcmd.isHelp:
      echo "available subcmd: " & self.map.keysToStr
      quit QuitSuccess

  let cb = self.map.getOrDefault(self.keyMapper subcmd)
  if cb.call.isNil:
    self.onUnknownSubCmd subcmd

  if args.len == 2 and args[1].isHelp:
    echo cb.help
    quit QuitSuccess
  cb.call(args[1..^1])
