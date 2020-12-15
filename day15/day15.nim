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

func containsReverse(n: int, s: seq[int]): bool =
  for i in countdown(high(s), 0):
    if s[i] == n:
      return true
  return false

func F(starting: seq[int], turnLim: int): int =
  var turn = len(starting)
  var turnTable = initTable[int, int]()
  var prev = starting[^1]

  for i in 0 .. high(starting):
    turnTable[starting[i]] = i

  while turn != turnLim:
    var spokenNum = 0

    if prev in turnTable:
      let dist = (turn - 1) - turnTable[prev]
      if dist != 0:
        spokenNum = dist

    turnTable[prev] = turn - 1

    prev = spokenNum
    turn += 1
  return prev

func part1(starting: seq[int]): string =
  return $F(starting, 2020)

func part2(starting: seq[int]): string =
  return $F(starting, 30000000)

when isMainModule:
  var
    f: File
    line: string

  let inputPath = if paramCount() > 0: paramStr(1) else: "day15.txt"
  if open(f, inputPath):
    let line = f.readline()
    let numStrings = line.split(',')
    var nums = newSeq[int]()
    for s in numStrings:
      nums.add(parseInt(s))

    let res1 = part1(nums)
    let res2 = part2(nums)

    echo(%*{"output1": res1, "output2": res2})
  else:
    echo("Couldn't open input file " & inputPath & "!")

