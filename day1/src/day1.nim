import json
import os
import sequtils
import strutils

iterator cartesianProduct(nums: seq[int]): (int, int) =
  for x in nums:
    for y in nums:
      yield (x, y)

iterator tripleProduct(nums: seq[int]): (int, int, int) =
  for x in nums:
    for y in nums:
      for z in nums:
        yield (x, y, z)

func part1(nums: seq[int]): string =
  for p in cartesianProduct(nums):
    if p[0] + p[1] == 2020:
      let res1 = p[0] * p[1]
      return $res1

func part2(nums: seq[int]): string =
  for p in tripleProduct(nums):
    if p[0] + p[1] + p[2] == 2020:
      let res2 = p[0] * p[1] * p[2]
      return $res2

when isMainModule:
  var
    f: File
    line: string
    lines: seq[string]
    nums: seq[int]

  let inputPath = if paramCount() > 0: paramStr(1) else: "day1.txt"
  if open(f, inputPath):
    while f.readLine(line):
      lines.add(line)
    nums = lines.mapIt(parseInt(it))

    let res1 = part1(nums)
    let res2 = part2(nums)

    echo(%*{"output1": res1, "output2": res2})
  else:
    echo("Couldn't open input file " & inputPath & "!")

