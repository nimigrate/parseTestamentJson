
import ./types
import std/json
from std/strutils import removePrefix, replace
const NodeNameKey* = "name"

import std/os
const FilePathSep* = '/'

func filepath*(self: RunRecord): string =
  result = self.node[NodeNameKey].getStr()
  when PathSep != FilePathSep:
    result = result.replace(PathSep, FilePathSep)
  result.removePrefix"tests/"
