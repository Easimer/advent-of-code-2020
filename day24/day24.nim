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

iterator neighborDeltas(): Coord =
  yield (1, -1, 0)
  yield (-1, 1, 0)
  yield (1, 0, -1)
  yield (0, 1, -1)
  yield (0, -1, 1)
  yield (-1, 0, 1)

func bounds(s: HexGridState): tuple[min: Coord, max: Coord] =
  result.min = (9999, 9999, 9999)
  result.max = (-9999, -9999, -9999)
  for c in s:
    result.min[0] = min(result.min[0], c[0])
    result.max[0] = max(result.max[0], c[0])
    result.min[1] = min(result.min[1], c[1])
    result.max[1] = max(result.max[1], c[1])
    result.min[2] = min(result.min[2], c[2])
    result.max[2] = max(result.max[2], c[2])

func grow(bmin, bmax: Coord): tuple[min: Coord, max: Coord] =
  result.min = (bmin[0] - 1, bmin[1] - 1, bmin[2] - 1)
  result.max = (bmax[0] + 1, bmax[1] + 1, bmax[2] + 1)

func countBlackNeighbors(s: HexGridState, c: Coord): int =
  for delta in neighborDeltas():
    let nc = c + delta
    if nc in s:
      result += 1

func mutate(current: HexGridState): HexGridState =
  let (bmin0, bmax0) = bounds(current)
  let (bmin, bmax) = grow(bmin0, bmax0)

  result = current

  for z in bmin.z .. bmax.z:
    for y in bmin.y .. bmax.y:
      for x in bmin.x .. bmax.x:
        let coord = (x, y, z)
        let neighbors = countBlackNeighbors(current, coord)
        if coord in current:
          # flipped -> black
          if neighbors == 0 or neighbors > 2:
            result.excl(coord)
        else:
          # not flipped -> white
          if neighbors == 2:
            result.incl(coord)

func makeHexGrid(paths: seq[seq[Direction]]): HexGridState =
  for path in paths:
    let coord = foldl(path, a + translateToDelta(b), (0, 0, 0))
    if coord in result:
      result.excl(coord)
    else:
      result.incl(coord)

func part1(paths: seq[seq[Direction]]): string =
  return $len(makeHexGrid(paths))

func part2(paths: seq[seq[Direction]]): string =
  let initial = makeHexGrid(paths)

  var buffers: array[2, HexGridState] = [initial, initial]
  var cur = 0

  for day in 1..100:
    let other = if cur == 0: 1 else: 0
    buffers[other] = mutate(buffers[cur])
    cur = other

  return $len(buffers[cur])

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

    let res1 = part1(paths)
    let res2 = part2(paths)
    echo(%*{"output1": res1, "output2": res2})
  else:
    echo("Couldn't open input file " & inputPath & "!")

