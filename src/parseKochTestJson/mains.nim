
import ./types
import ./extract
import std/sets

proc echoAllStatus* =  
  var s = initHashSet[TResultEnum]()
  for rec in "../testresult".parseDir:
    for node in rec.data:
      if node.status != reSuccess:
        s.incl node.status
  echo s


#template
