
from std/strutils import repeat, indent
import std/json
from std/os import quoteShellCommand
import std/sets

import ./types


type MarkdownList* = object
  nSpace*: int
  prefix*{.requiresInit.}: string
  lines: seq[string]

func markdownList*(prefix = "- "): MarkdownList =
  result.prefix = prefix

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

func addItem*(self: var MarkdownList; line: string){.inline.} =
  self.lines.add line

func addKeyVal*(self: var MarkdownList; key, value: string) = self.addItem key & ": " & value

func extendItems*(self: var MarkdownList; ls: sink MarkdownList) =
  #self.addItem `$`(ls, ls.nSpace, false)
  self.lines.add ls.lines

func asCode(s: var string; lang=""; default="*None*") =
  if s.len == 0:
    s = default
    return
  s = indent('\n' & "```"& lang & '\n' & s & "```", IndentSpaceN)

func toInlineCode(s: string): string = '`' & s & '`'

func markdownList(node: JsonNode, asCodeKeys = initHashSet[string]()): MarkdownList =
  ## only for RunRecord.node
  result = markdownList()
  for key in node.keys():
    var val = node[key].getStr()
    if key in asCodeKeys: val.asCode()
    result.addKeyVal key, val

func markdownListSkipStatus*(self: RunRecord): MarkdownList =
  result = markdownList()
  result.extendItems(markdownList(self.node, toHashSet ["expected", "given"]))
  result.addKeyVal "backend", $self.backend
  # no status
  result.addKeyVal "argv", self.args.quoteShellCommand.toInlineCode
 