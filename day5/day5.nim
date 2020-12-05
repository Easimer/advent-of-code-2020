import json
import os
import strutils
import options

type
  Dir = enum dForward, dBackward, dLeft, dRight
  BoardingPass = seq[Dir]
  SearchArea = tuple[
    rowMin: int,
    rowMax: int,
    colMin: int,
    colMax: int
  ]


func parseLine(line: string): BoardingPass =
  assert(len(line) == 10)
  for ch in line:
    result.add(case ch
      of 'F': dForward
      of 'B': dBackward
      of 'L': dLeft
      of 'R': dRight
      else: quit(QuitFailure)
    )

  assert(len(result) == 10)

func `/`(a: SearchArea, d: Dir): SearchArea =
  if d in [dForward, dBackward]:
    let halfDist = (a.rowMax - a.rowMin) div 2
    case d:
      of dForward:
        return (rowMin: a.rowMin, rowMax: a.rowMax - halfDist, colMin: a.colMin, colMax: a.colMax)
      of dBackward:
        return (rowMin: a.rowMin + halfDist, rowMax: a.rowMax, colMin: a.colMin, colMax: a.colMax)
      else:
        assert(false)
  else:
    let halfDist = (a.colMax - a.colMin) div 2
    case d:
      of dLeft:
        return (rowMin: a.rowMin, rowMax: a.rowMax, colMin: a.colMin, colMax: a.colMax - halfDist)
      of dRight:
        return (rowMin: a.rowMin, rowMax: a.rowMax, colMin: a.colMin + halfDist, colMax: a.colMax)
      else:
        assert(false)

func toSeatId(p: BoardingPass): int =
  var area: SearchArea = (rowMin: 0, rowMax: 128, colMin: 0, colMax: 8)
  debugEcho($area)

  for d in p:
    area = area / d
    debugEcho($d & " " & $area)

  assert(area.rowMin == area.rowMax - 1 and area.colMin == area.colMax - 1)

  area.rowMin * 8 + area.colMin


func part1(passes: seq[BoardingPass]): string =
  var cnt = 0

  for p in passes:
    cnt = max(cnt, toSeatId(p))

  return $cnt

when isMainModule:
  var
    f: File
    line: string

  let inputPath = if paramCount() > 0: paramStr(1) else: "day5.txt"
  if open(f, inputPath):
    var passes = newSeq[BoardingPass]()
    while f.readLine(line):
      passes.add(parseLine(line))


    let res1 = part1(passes)
    let res2 = ""

    echo(%*{"output1": res1, "output2": res2})
  else:
    echo("Couldn't open input file " & inputPath & "!")

