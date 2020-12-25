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

const SUBJECT_NUM = 7
const MODULUS = 20201227

func getLoopNum(pub: int): int =
  var l = 0
  var v = 1

  while v != pub:
    v = (v * SUBJECT_NUM) mod MODULUS
    l += 1

  return l

func getSecret(pub, l: int): int =
  var lcur = 0
  var v = 1

  for iter in 1..l:
    v = (v * pub) mod MODULUS

  return v

func part1(pub0, pub1: int): string =
  let l1 = getLoopNum(pub1)
  let secret = getSecret(pub0, l1)

  return $secret

func part2(pub0, pub1: int): string = ""

when isMainModule:
  var
    f: File

  let inputPath = if paramCount() > 0: paramStr(1) else: "day25.txt"
  if open(f, inputPath):
    let pub0 = parseInt(f.readline())
    let pub1 = parseInt(f.readline())

    let res1 = part1(pub0, pub1)
    let res2 = part2(pub0, pub1)
    echo(%*{"output1": res1, "output2": res2})
  else:
    echo("Couldn't open input file " & inputPath & "!")

