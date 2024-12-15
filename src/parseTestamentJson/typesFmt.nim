
from std/strutils import repeat, indent, splitLines
import std/json
from std/os import quoteShellCommand
import std/sets

import ./types
import ./typesMeth


type MarkdownList* = object
  nSpace*: int
  prefix*: string = "- "
  lines: seq[string]

func markdownList*(prefix = "- "): MarkdownList =
  result = MarkdownList(prefix: prefix)

const IndentSpaceN = 2

using self: MarkdownList
func `$`*(self; nSpace=self.nSpace; appendNewLine=true): string =
  let spaces = ' '.repeat nSpace
  for line in self.lines:
    result.add spaces
    result.add self.prefix
    result.add line
    result.add '\n'
  if appendNewLine: result.add '\n'

iterator items*(self): string =
  for i in self.lines.items(): yield i

using self: var MarkdownList
func addItem*(self; line: string){.inline.} =
  self.lines.add line

func addKeyVal*(self; key, value: string) = self.addItem key & ": " & value

func extendItems*(self; ls: sink MarkdownList) =
  #self.addItem `$`(ls, ls.nSpace, false)
  self.lines.add ls.lines

func addSubItem*(self; head: string, ls: sink MarkdownList) =
  var item = head
  item.add '\n'
  let spaces = ' '.repeat (self.nSpace + IndentSpaceN)
  for i in ls:
    item.add spaces
    item.add ls.prefix
    var ident = ""
    for line in i.splitLines:
      item.add ident
      item.add line
      ident = spaces
    item.add '\n'
  self.addItem item

func asCode(s: var string; lang=""; default="*None*") =
  if s.len == 0:
    s = default
    return
  s = '\n' & "```" & lang & '\n' & s
  if s[^1] not_in {'\n', '\r'}: s.add '\n'
  s = indent(s & "```", IndentSpaceN)

func toInlineCode(s: string): string = '`' & s & '`'

func markdownList(node: JsonNode, asCodeKeys = initHashSet[string]()): MarkdownList =
  ## only for RunRecord.node
  result = markdownList()
  for key in node.keys():
    if key == NodeNameKey: continue
    var val = node[key].getStr()
    if key in asCodeKeys: val.asCode()
    result.addKeyVal key, val

func markdownListSkipStatus*(self: RunRecord): MarkdownList =
  result = markdownList()
  result.addKeyVal "backend", $self.backend
  # no status
  result.addKeyVal "argv", self.args.quoteShellCommand.toInlineCode
  result.extendItems(markdownList(self.node, toHashSet ["expected", "given"]))
 