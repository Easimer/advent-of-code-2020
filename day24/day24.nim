import algorithm
import deques
import json
import os
import options
import sets
import sequtils
import strutils
import strscans
import lists
import heapqueue
import tables
import sugar
import hashes

type
  Direction = enum
    dEast, dSouthEast, dSouthWest,
    dWest, dNorthWest, dNorthEast

  Coord = tuple[x, y, z: int]

  HexGridState = HashSet[Coord]

proc readPath(f: var File): Option[seq[Direction]] =
  if f.endOfFile(): return

  var ret: seq[Direction]

  let line = f.readline()

  var cur = 0
  while cur != len(line):
    case line[cur]:
      of 'e':
        ret.add(dEast)
        cur += 1
      of 'w':
        ret.add(dWest)
        cur += 1
      of 'n':
        case line[cur + 1]:
          of 'e':
            ret.add(dNorthEast)
          of 'w':
            ret.add(dNorthWest)
          else: assert(false)
        cur += 2
      of 's':
        case line[cur + 1]:
          of 'e':
            ret.add(dSouthEast)
          of 'w':
            ret.add(dSouthWest)
          else: assert(false)
        cur += 2
      else: assert(false)

  return some(ret)

func translateToDelta(d: Direction): Coord =
  case d:
    of dEast: (1, -1, 0)
    of dWest: (-1, 1, 0)
    of dNorthEast: (1, 0, -1)
    of dNorthWest: (0, 1, -1)
    of dSouthEast: (0, -1, 1)
    of dSouthWest: (-1, 0, 1)

func `+`(l: Coord, r: Coord): Coord =
  (l.x + r.x, l.y + r.y, l.z + r.z)

func part1(paths: seq[seq[Direction]]): string =
  var state: HexGridState
  for path in paths:
    let coord = foldl(path, a + translateToDelta(b), (0, 0, 0))
    debugEcho(coord)
    if coord in state:
      state.excl(coord)
    else:
      state.incl(coord)

  return $len(state)

when isMainModule:
  var
    f: File
    paths: seq[seq[Direction]]

  let inputPath = if paramCount() > 0: paramStr(1) else: "day24.txt"
  if open(f, inputPath):
    var line = readPath(f)
    while line.isSome():
      paths.add(line.get())
      line = readPath(f)

    echo(paths)
    let res1 = part1(paths)
    let res2 = ""
    echo(%*{"output1": res1, "output2": res2})
  else:
    echo("Couldn't open input file " & inputPath & "!")

