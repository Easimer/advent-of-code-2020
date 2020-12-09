import deques
import json
import os
import options
import sets
import sequtils
import strutils

func find_invalid_num(nums: seq[int]): int =
  for i in 25 .. high(nums):
    let S = nums[i]
    var has = false

    for i_p0 in (i - 25) .. (i - 1):
      for i_p1 in (i - 25) .. (i - 1):
        if i_p0 != i_p1:
          let sum = nums[i_p0] + nums[i_p1]
          if sum == S:
            has = true
    if not has:
      return S

func part1(nums: seq[int]): string =
  $find_invalid_num(nums)

func part2(nums: seq[int]): string =
  let INV = find_invalid_num(nums)

  for i_start in 0 .. high(nums) - 1:
    for i_end in (i_start + 1) .. high(nums):
      assert(i_end - i_start >= 1)
      let slice = nums[i_start .. i_end]
      let sum = foldl(slice, a + b)
      if sum == INV:
        let smallest = slice[minIndex(slice)]
        let largest = slice[maxIndex(slice)]
        return $(smallest + largest)

when isMainModule:
  var
    f: File
    line: string
    nums: seq[int]

  let inputPath = if paramCount() > 0: paramStr(1) else: "day9.txt"
  if open(f, inputPath):
    while f.readLine(line):
      nums.add(parseInt(line))

    let res1 = part1(nums)
    let res2 = part2(nums)

    echo(%*{"output1": res1, "output2": res2})
  else:
    echo("Couldn't open input file " & inputPath & "!")

