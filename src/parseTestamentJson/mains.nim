
import ./types
import ./typesMeth
import ./extract
import ./typesFmt
import std/sets
import std/tables
export sets

const ExcludeStatus = {reSuccess, reJoined}

template doWithNonSuccNode*(dir: string; doWith) =
  for rec in dir.parseDir:
    for d in rec.data:
      if d.status not_in ExcludeStatus:
        doWith d

const dir = "../testresult"

proc getAllStatus*: HashSet[TResultEnum] =
  template doWith(d) = result.incl d.status
  dir.doWithNonSuccNode doWith
    

proc getStatusDiffMap*: Table[TResultEnum, seq[RunRecord]] =
  #result = initTable[TResultEnum, seq[RunRecord]]()
  template doWith(d) =
    if d.status not_in result:
      result[d.status] = @[]
    result[d.status].add d
  dir.doWithNonSuccNode doWith

proc writeStatusDiffMap*[T](stream: T) =
  let res = getStatusDiffMap()
  for (key, ls) in res.pairs():
    stream.writeLine key
    echo "=============="
    for d in ls:
      stream.writeLine "### " & d.filepath
      stream.writeLine $(markdownListSkipStatus d)
    stream.writeLine '\n'

proc echoStatusDiffMap* =
  ## echo status diff map
  stdout.writeStatusDiffMap

proc getAllTestName*: HashSet[string] =
  for ls in getStatusDiffMap().values():
    for d in ls:
      result.incl d.filepath

proc writeAllTestname*[T](stream: T) =
  for i in getAllTestName(): stream.writeLine i

proc echoAllTestname* =
  ## all tests' file name
  stdout.writeAllTestname
