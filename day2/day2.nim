import aocutils
import json
import os
import strutils

type
  Policy = tuple
    nMin: int
    nMax: int
    ch: char

  PolicyPasswordPair = tuple[policy: Policy, password: string]

func part1(arr: openArray[PolicyPasswordPair]): string =
  var ret = 0
  for p in arr:
    let ch = p.policy.ch
    let cnt = count(p.password, (proc (c: char): bool = c == ch))
    if p.policy.nMin <= cnt and cnt <= p.policy.nMax:
      ret += 1

  return $ret

func part2(arr: openArray[PolicyPasswordPair]): string =
  var ret = 0
  for p in arr:
    let ch = p.policy.ch
    let idx0 = p.policy.nMin
    let idx1 = p.policy.nMax
    let b0 = p.password[idx0 - 1] == ch
    let b1 = p.password[idx1 - 1] == ch
    if b0 xor b1:
      ret += 1

  return $ret

func parseLine(line: string): PolicyPasswordPair =
  let a = split(line, ':')
  let password = strip(a[1])
  let b = split(a[0],)
  let r = b[0]
  let ch = b[1][0]
  let rr = split(r, '-')
  let nMin = parseInt(rr[0])
  let nMax = parseInt(rr[1])

  ((nMin, nMax, ch), password)

when isMainModule:
  var
    f: File
    line: string
    pairs: seq[PolicyPasswordPair]

  let inputPath = if paramCount() > 0: paramStr(1) else: "day2.txt"
  if open(f, inputPath):
    while f.readLine(line):
      pairs.add(parseLine(line))

    let res1 = part1(pairs)
    let res2 = part2(pairs)

    echo(%*{"output1": res1, "output2": res2})
  else:
    echo("Couldn't open input file " & inputPath & "!")

