import aocutils
import json
import os
import strutils

type
  Terrain = seq[seq[bool]]

func parseLine(line: string): seq[bool] =
  for ch in line:
    result.add(ch == '#')

func isTreePresent(terrain: Terrain, x: int, y: int): bool =
  let width = len(terrain[0])
  let height = len(terrain)

  if y >= height:
    return false

  let xm = x mod width

  return terrain[y][xm]

func treesEncountered(terrain: Terrain, strideX: int, strideY: int): int =
  var cnt = 0
  let h = len(terrain)
  var x = 0
  var y = 0

  while y < h:
    if isTreePresent(terrain, x, y):
      cnt += 1
    x += strideX
    y += strideY

  return cnt

func part1(terrain: Terrain): string =
  return $treesEncountered(terrain, 3, 1)

func part2(terrain: Terrain): string =
  var ret = 1
  let slopes = [(1, 1), (3, 1), (5, 1), (7, 1), (1, 2)]

  for slope in slopes:
    ret *= treesEncountered(terrain, slope[0], slope[1])

  return $ret


when isMainModule:
  var
    f: File
    line: string
    terrain: Terrain

  let inputPath = if paramCount() > 0: paramStr(1) else: "day3.txt"
  if open(f, inputPath):
    while f.readLine(line):
      terrain.add(parseLine(line))

    let res1 = part1(terrain)
    let res2 = part2(terrain)

    echo(%*{"output1": res1, "output2": res2})
  else:
    echo("Couldn't open input file " & inputPath & "!")

