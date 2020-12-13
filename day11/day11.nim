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
  Cell = enum
    Floor
    Empty
    Occupied

  State = object
    cells: seq[Cell]
    width: int
    height: int

  Position = tuple[x: int, y: int]

  NeighborCounter = proc (s: State, pos: Position): int

func contains(s: State, pos: Position): bool =
  let x = pos.x
  let y = pos.y
  not(x < 0 or x >= s.width or y < 0 or y >= s.height)

func `[]`(s: State, pos: Position): Cell =
  if pos in s:
    s.cells[pos.y * s.width + pos.x]
  else:
    Floor

func `[]=`(s: var State, pos: Position, c: Cell) =
  let x = pos.x
  let y = pos.y
  if pos in s:
    s.cells[y * s.width + x] = c

func `+`(lhs: Position, rhs: Position): Position =
  (lhs.x + rhs.x, lhs.y + rhs.y)

iterator positions(s: State): Position =
  for y in 0 .. s.height - 1:
    for x in 0 .. s.width - 1:
      yield (x, y)

func countOccupiedNeighbors(s: State, pos: Position): int =
  result = 0
  for y in (pos.y - 1) .. (pos.y + 1):
    for x in (pos.x - 1) .. (pos.x + 1):
      if x != pos.x or y != pos.y:
        if s[(x, y)] == Occupied:
          result += 1

func countOccupiedRaycast(s: State, pos: Position): int =
  result = 0
  for dy in -1 .. 1:
    for dx in -1 .. 1:
      if not(dx == 0 and dy == 0):
        var cur = pos + (dx, dy)
        while cur in s:
          let curCell = s[cur]
          case curCell:
            of Empty:
              break
            of Occupied:
              result += 1
              break
            else:
              discard
          cur = cur + (dx, dy)

# Returns whether the state changed
func step(current: State, next: var State, neighborCounter: NeighborCounter, occupiedLimit: int): bool =
  assert(current.width == next.width)
  assert(current.height == next.height)
  assert(len(current.cells) == len(next.cells))
  assert(len(current.cells) == current.width * current.height)

  result = false

  for pos in positions(current):
    let occupiedNeighbors = current.neighborCounter(pos)
    var nextState = current[pos]
    case current[pos]:
      of Empty:
        if occupiedNeighbors == 0:
          nextState = Occupied
          result = true
      of Occupied:
        if occupiedNeighbors >= occupiedLimit:
          nextState = Empty
          result = true
      else: discard
    next[pos] = nextState

func countOccupiedWhenUnchanged(s: State, neighborCounter: NeighborCounter, occupiedLimit: int): string =
  var buf0 = s
  var buf1 = s

  while true:
    if not step(buf0, buf1, neighborCounter, occupiedLimit):
      break
    if not step(buf1, buf0, neighborCounter, occupiedLimit):
      break

  var cnt = 0
  for c in buf0.cells:
    if c == Occupied: cnt += 1
  return $cnt

func part1(s: State): string =
  countOccupiedWhenUnchanged(s, countOccupiedNeighbors, 4)

func part2(s: State): string =
  countOccupiedWhenUnchanged(s, countOccupiedRaycast, 5)

when isMainModule:
  var
    f: File
    line: string
    initialState: State

  let inputPath = if paramCount() > 0: paramStr(1) else: "day11.txt"
  if open(f, inputPath):
    initialState.height = 0
    for line in f.lines():
      initialState.width = len(line)
      initialState.height += 1
      for ch in line:
        case ch:
          of '.':
            initialState.cells.add(Floor)
          of 'L':
            initialState.cells.add(Empty)
          of '#':
            initialState.cells.add(Occupied)
          else:
            assert(false)

    let res1 = part1(initialState)
    let res2 = part2(initialState)

    echo(%*{"output1": res1, "output2": res2})
  else:
    echo("Couldn't open input file " & inputPath & "!")

