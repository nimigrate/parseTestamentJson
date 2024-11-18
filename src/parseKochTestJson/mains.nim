
import ./types
import ./extract
import ./typesFmt
import std/sets
import std/tables
export sets


template doWithNonSuccNode*(dir: string; doWith) =
  for rec in dir.parseDir:
    for d in rec.data:
      if d.status != reSuccess:
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

proc echoStatusDiffMap*() =
  let res = getStatusDiffMap()
  for key in res.keys():
    echo key
    echo "=============="
    for d in res[key]:
      echo markdownListSkipStatus d
    echo '\n'
