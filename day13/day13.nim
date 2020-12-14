import aocutils
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
  Notes = object
    earliestDep: int
    buses: seq[Option[int]]

func max(s: seq[Option[int]]): int =
  result = 0
  for mn in s:
    if mn.isSome():
      let n = mn.get()
      if n > result :
        result = n

func part1(input: Notes): string =
  let M = max(input.buses)
  for i in input.earliestDep .. input.earliestDep + M + 1:
    for bus in input.buses:
      if isSome(bus) and (i mod bus.get()) == 0:
        let waitingTime = i - input.earliestDep
        return $(bus.get() * waitingTime)
  assert(false)

func offAndMod(buses: seq[Option[int]]): seq[tuple[i: int, m: int]] =
  for i in 0 .. high(buses):
    if buses[i].isSome():
      result.add((i, buses[i].get()))

func part2(input: Notes): string =
  let buses = input.buses
  let offsAndMods = offAndMod(buses)

  # Chinese remainder theorem
  # Search by sieving

  var n = offsAndMods[0].m
  var t = n

  for i in 1 .. high(offsAndMods):
    while ((t + offsAndMods[i].i) mod offsAndMods[i].m) != 0:
      t += n
    n *= offsAndMods[i].m

  return $t

when isMainModule:
  var
    f: File
    line: string

  let inputPath = if paramCount() > 0: paramStr(1) else: "day13.txt"
  if open(f, inputPath):
    let earliestDep = parseInt(f.readLine())
    let busIds = f.readLine().split(',')
    var buses = newSeq[Option[int]]()
    for busId in busIds:
      if busId != "x":
        buses.add(some(parseInt(busId)))
      else:
        buses.add(none(int))

    let notes = Notes(earliestDep: earliestDep, buses: buses)

    let res1 = part1(notes)
    let res2 = part2(notes)

    echo(%*{"output1": res1, "output2": res2})
  else:
    echo("Couldn't open input file " & inputPath & "!")

