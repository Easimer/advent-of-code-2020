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
  Cup = ref CupObj
  CupObj = object
    label: int

    next: Cup

proc printCups(c: Cup, n: int = 9) =
  var i = 0
  var pcur = c
  while i < n:
    stdout.write($pcur.label & " ")
    pcur = pcur.next
    i += 1
  stdout.write("\n")

proc readCups(f: var File): tuple[cups: Cup, length: int] =
  var first: Cup
  var prev, cur: Cup
  var cnt = 0

  let line = f.readline()

  new(first)
  cur = first

  for ch in line:
    cur.label = parseInt($ch)
    prev = cur
    new(cur)
    prev.next = cur
    cnt += 1
  prev.next = first

  return (first, cnt)

func labelInTriCups(tricups: Cup, label: int): bool =
  tricups.label == label or
    tricups.next.label == label or
      tricups.next.next.label == label

type
  Lookup = seq[Cup]

func move(current: var Cup, lookup: Lookup, maxLabel: int) =
  let tricups = current.next
  current.next = tricups.next.next.next

  var dstLabel = current.label - 1
  while labelInTriCups(tricups, dstLabel) or dstLabel == 0:
    dstLabel -= 1
    if dstLabel <= 0: dstLabel = maxLabel

  let dst = lookup[dstLabel]
  #var dst = current
  #while dst.label != dstLabel:
    #dst = dst.next

  let dstNext = dst.next
  dst.next = tricups
  tricups.next.next.next = dstNext

func makeLookup(cups: Cup, maxLabel: int): Lookup =
  result = newSeq[Cup](maxLabel + 1)
  var cur = cups
  let firstLabel = cur.label
  result[firstLabel] = cur
  cur = cur.next
  while cur.label != firstLabel:
    result[cur.label] = cur
    cur = cur.next

proc part1(cups: Cup): string =
  let maxLabel = 9
  var cups0 = deepCopy(cups)
  let lookup = makeLookup(cups0, maxLabel)
  for i in 0..99:
    move(cups0, lookup, maxLabel)
    cups0 = cups0.next

  var start = cups0
  while start.label != 1:
    start = start.next
  start = start.next

  for i in 0..7:
    result.add($start.label)
    start = start.next

proc part2(cups: Cup): string =
  let maxLabel = 1000000
  var cups1 = deepCopy(cups)

  var last = cups1.next
  while last.next.label != cups1.label:
    last = last.next
  for i in 10..maxLabel:
    var n: Cup
    new(n)
    n.label = i
    n.next = cups1
    last.next = n
    last = n

  let lookup = makeLookup(cups1, maxLabel)

  for i in 0..9999999:
    move(cups1, lookup, maxLabel)
    cups1 = cups1.next

  var start = lookup[1].next

  return $(start.label * start.next.label)


when isMainModule:
  var
    f: File

  let inputPath = if paramCount() > 0: paramStr(1) else: "day23.txt"
  if open(f, inputPath):
    let (cups, cupsCount) = readCups(f)

    let res1 = part1(cups)
    let res2 = part2(cups)

    echo(%*{"output1": res1, "output2": res2})
  else:
    echo("Couldn't open input file " & inputPath & "!")

