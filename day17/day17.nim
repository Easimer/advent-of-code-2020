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

type
  Position3 = tuple[x: int, y: int, z: int]
  Position4 = tuple[x: int, y: int, z: int, w: int]
  PocketDim[PosT] = HashSet[PosT]
 
func `+`(lhs: Position3, rhs: Position3): Position3 =
  (lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)

func `+`(lhs: Position4, rhs: Position4): Position4 =
  (lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z, lhs.w + rhs.w)

func countActiveNeighbors(pd: PocketDim[Position3], pos: Position3): int =
  result = 0
  for dz in -1 .. 1:
    for dy in -1 .. 1:
      for dx in -1 .. 1:
        if not (dx == 0 and dy == 0 and dz == 0):
          let np = pos + (x: dx, y: dy, z: dz)
          if np in pd:
            result += 1

func countActiveNeighbors(pd: PocketDim[Position4], pos: Position4): int =
  result = 0
  for dw in -1 .. 1:
    for dz in -1 .. 1:
      for dy in -1 .. 1:
        for dx in -1 .. 1:
          if not (dx == 0 and dy == 0 and dz == 0 and dw == 0):
            let np = pos + (x: dx, y: dy, z: dz, w: dw)
            if np in pd:
              result += 1

iterator positions(s: PocketDim[Position3], extMin: Position3, extMax: Position3): Position3 =
  for z in (extMin.z - 1) .. (extMax.z + 1):
    for y in (extMin.y - 1) .. (extMax.y + 1):
      for x in (extMin.x - 1) .. (extMax.x + 1):
        let p = (x: x, y: y, z: z)
        yield p

iterator positions(s: PocketDim[Position4], extMin: Position4, extMax: Position4): Position4 =
  for w in (extMin.w - 1) .. (extMax.w + 1):
    for z in (extMin.z - 1) .. (extMax.z + 1):
      for y in (extMin.y - 1) .. (extMax.y + 1):
        for x in (extMin.x - 1) .. (extMax.x + 1):
          let p = (x: x, y: y, z: z, w: w)
          yield p

func initToMax(p: var Position3) =
  p = (99999, 99999, 99999)

func initToMin(p: var Position3) =
  p = (-99999, -99999, -99999)

func initToMax(p: var Position4) =
  p = (99999, 99999, 99999, 99999)

func initToMin(p: var Position4) =
  p = (-99999, -99999, -99999, -99999)

func min(lhs: Position3, rhs: Position3): Position3 =
  result.x = min(lhs.x, rhs.x)
  result.y = min(lhs.y, rhs.y)
  result.z = min(lhs.z, rhs.z)

func min(lhs: Position4, rhs: Position4): Position4 =
  result.x = min(lhs.x, rhs.x)
  result.y = min(lhs.y, rhs.y)
  result.z = min(lhs.z, rhs.z)
  result.w = min(lhs.w, rhs.w)

func max(lhs: Position3, rhs: Position3): Position3 =
  result.x = max(lhs.x, rhs.x)
  result.y = max(lhs.y, rhs.y)
  result.z = max(lhs.z, rhs.z)

func max(lhs: Position4, rhs: Position4): Position4 =
  result.x = max(lhs.x, rhs.x)
  result.y = max(lhs.y, rhs.y)
  result.z = max(lhs.z, rhs.z)
  result.w = max(lhs.w, rhs.w)

func step[T](current: PocketDim[T], next: var PocketDim[T]) =
  next.clear()

  var minPos: T
  var maxPos: T

  initToMax(minPos)
  initToMin(maxPos)

  for pos in current:
    minPos = min(pos, minPos)
    maxPos = max(pos, maxPos)

  for pos in positions(current, minPos, maxPos):
    let activeNeighbors = countActiveNeighbors(current, pos)
    if pos in current:
      # active
      if activeNeighbors in 2..3:
        next.incl(pos)
    else:
      # inactive
      if activeNeighbors == 3:
        next.incl(pos)

func exec[T](s: PocketDim[T]): int =
  var buffers: array[2, PocketDim[T]]
  buffers[0] = s
  var currentIdx = 0
  var nextIdx = 1
  for i in 0..5:
    step(buffers[currentIdx], buffers[nextIdx])
    swap(currentIdx, nextIdx)
  return len(buffers[currentIdx])

func part1(s: PocketDim[Position3]): string =
  return $exec(s)

func part2(s: PocketDim[Position4]): string =
  return $exec(s)

func part2(s: PocketDim[Position3]): string =
  var pd4: PocketDim[Position4]
  for pos in s:
    pd4.incl((x: pos.x, y: pos.y, z: pos.z, w: 0))

  part2(pd4)

when isMainModule:
  var
    f: File
    line: string
    initialState: PocketDim[Position3]

  let inputPath = if paramCount() > 0: paramStr(1) else: "day17.txt"
  if open(f, inputPath):
    var y = 0
    for line in f.lines():
      var x = 0
      for ch in line:
        case ch:
          of '.':
            discard
          of '#':
            initialState.incl((x: x, y: y, z: 0))
          else:
            assert(false)
        x += 1
      y += 1

    let res1 = part1(initialState)
    let res2 = part2(initialState)

    echo(%*{"output1": res1, "output2": res2})
  else:
    echo("Couldn't open input file " & inputPath & "!")

