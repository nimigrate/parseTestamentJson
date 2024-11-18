
import std/json
import std/streams
import std/options
from std/strutils import removeSuffix, split, parseEnum
from std/os import walkDir, `/`, PathComponent

import ./types
from ./log import warning
import ./jsonFileFix

const DupFields = [
    "branch", "commit", "machine",
    ]

func popEnumKey[E: enum](node: JsonNode, key: string): E =
  result = parseEnum[E](node[key].getStr())
  node.delete key

iterator filterNonSuccess*(arrNode: JsonNode): RunRecord =
  for node in arrNode:
    if "reSuccess" == node["result"].getStr():
      continue

    let target = node["target"].getStr()
    for field in DupFields:
      node.delete field

    var argvJoined = node["name"].getStr
    var argv = argvJoined.split ' '
    node["name"] = newJString argv[0]
    argv.delete 0
    var res: RunRecord

    res.status = node.popEnumKey[:TResultEnum]("result")
    res.backend = node.popEnumKey[:Backend]("target")

    res.node = node
    res.args = argv
    yield res

template wrap(exp) =
  for i in filterNonSuccess exp:
    yield i

iterator filterNonSuccess*(s: Stream, filename = ""): RunRecord = wrap s.parseJson(filename)
iterator filterNonSuccess*(buffer: string): RunRecord = wrap parseJson buffer

using dir: string
proc parseFile*(dir; filename: string): Option[FileRecord] =
  ## returns none iff file is empty
  let path = dir/filename
  var fstr: FileStream
  if not fstr.openMayAfterFixJson path:
    return
  assert not fstr.isNil
  defer: fstr.close
  var res: FileRecord
  res.name = filename
  res.name.removeSuffix".json"
  for i in fstr.filterNonSuccess filename:
    res.data.add i
  result = some res


iterator parseDir*(dir): FileRecord =
  ## skip record with no data
  for entry in dir.walkDir(relative=true, checkDir=true):
    assert entry.kind == pcFile
    let option = dir.parseFile entry.path
    if option.isNone:
      warning "empty file " & dir/entry.path
      continue
    let res = option.unsafeGet()
    if res.data.len != 0:
      yield res

