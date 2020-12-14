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
      address: string
      value: string

func parseMask(s: string): InputLine =
  result = InputLine(kind: kMask)
  let ms = s.split(" = ")[1]
  result.mask = ms

func parseWrite(s: string): InputLine =
  result = InputLine(kind: kWrite)
  var value: int
  var address: int
  if not scanf(s, "mem[$i] = $i", address, value):
    quit(1)
  result.address = toBin(address, 36)
  result.value = toBin(value, 36)

func applyMask(value: string, mask: string): string =
  result = "                                    "
  for i in 0 .. 35:
    if mask[i] == 'X':
      result[i] = value[i]
    else:
      result[i] = mask[i]

proc broadcastWrite(mem: var Table[int, string], address: string, value: string, i: int) =
  if i != 36:
    if address[i] == 'X':
      var copy0 = address
      copy0[i] = '0'
      broadcastWrite(mem, copy0, value, i + 1)
      copy0[i] = '1'
      broadcastWrite(mem, copy0, value, i + 1)
    else:
      broadcastWrite(mem, address, value, i + 1)
  else:
    mem[parseBinInt(address)] = value

proc broadcastWrite(mem: var Table[int, string], address: string, value: string, mask: string) =
  var copy0 = address
  for i in 0 .. high(address):
    if mask[i] != '0':
      copy0[i] = mask[i]

  broadcastWrite(mem, copy0, value, 0)


func part1(input: seq[InputLine]): string =
  var memory = initTable[int, string]()
  var mask = ""

  for i in input:
    case i.kind:
      of kMask:
        mask = i.mask
      of kWrite:
        memory[parseBinInt(i.address)] = applyMask(i.value, mask)

  var sum = 0
  for k,v in memory:
    sum += parseBinInt(v)

  return $sum

func part2(input: seq[InputLine]): string =
  var memory = initTable[int, string]()
  var mask = ""

  for i in input:
    case i.kind:
      of kMask:
        mask = i.mask
      of kWrite:
        broadcastWrite(memory, i.address, i.value, mask)

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
    let res2 = part2(input)

    echo(%*{"output1": res1, "output2": res2})
  else:
    echo("Couldn't open input file " & inputPath & "!")

