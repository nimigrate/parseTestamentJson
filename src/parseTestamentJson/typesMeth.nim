
import ./types
import std/json
from std/strutils import removePrefix
const NodeNameKey* = "name"

func filepath*(self: RunRecord): string =
  result = self.node[NodeNameKey].getStr()
  result.removePrefix"tests/"
