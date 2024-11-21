
import std/streams

from std/strutils import isSpaceAscii
import ./truncate

proc truncate(f: File, length=f.getFilePos()) = ftruncate(f.getFileHandle(), length)

proc openMayAfterFixJson*(fstr: var FileStream, path: string): bool =
  ## append maybe missing ']'
  var f = open(path, fmReadWriteExisting)
  fstr = newFileStream f

  # lstrip()
  while fstr.peekChar().isSpaceAscii():
    discard f.readChar()
  let start = fstr.peekChar()
  if start == '\0':  # eof
    fstr.close()
    return
  let arrStarted = start == '['

  # rstrip
  f.setFilePos(0, fspEnd)
  f.setFilePos(-1, fspCur)

  while fstr.peekChar().isSpaceAscii():
    f.setFilePos(-1, fspCur)
  
  let arrEnded = f.readChar() == ']'

  if arrStarted and not arrEnded:
    f.truncate()
    f.write ']'
    f.flushFile()

  f.setFilePos(0, fspSet)
  result = true
