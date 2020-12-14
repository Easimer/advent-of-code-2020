import aocutils
import deques
import json
import os
import options
import sets
import sequtils
import strutils
import lists
import heapqueue
import tables
import strscans

type
  InputKind = enum
    kMask, kWrite

  InputLine = object
    case kind: InputKind
    of kMask:
      mask: string
    of kWrite:
      address: int
      value: string

func parseMask(s: string): InputLine =
  result = InputLine(kind: kMask)
  let ms = s.split(" = ")[1]
  result.mask = ms

func parseWrite(s: string): InputLine =
  result = InputLine(kind: kWrite)
  var value: int
  if not scanf(s, "mem[$i] = $i", result.address, value):
    quit(1)
  result.value = toBin(value, 36)

func applyMask(value: string, mask: string): string =
  result = "                                    "
  for i in 0 .. 35:
    if mask[i] == 'X':
      result[i] = value[i]
    else:
      result[i] = mask[i]

func part1(input: seq[InputLine]): string =
  var memory = initTable[int, string]()
  var mask = ""

  for i in input:
    case i.kind:
      of kMask:
        mask = i.mask
      of kWrite:
        memory[i.address] = applyMask(i.value, mask)

  var sum = 0
  for k,v in memory:
    sum += parseBinInt(v)

  return $sum

when isMainModule:
  var
    f: File
    line: string
    input: seq[InputLine]

  let inputPath = if paramCount() > 0: paramStr(1) else: "day14.txt"
  if open(f, inputPath):
    for line in f.lines():
      input.add:
        if line.startsWith("mas"):
          parseMask(line)
        else:
          parseWrite(line)

    let res1 = part1(input)
    #let res2 = part2(notes)
    let res2 = ""

    echo(%*{"output1": res1, "output2": res2})
  else:
    echo("Couldn't open input file " & inputPath & "!")

