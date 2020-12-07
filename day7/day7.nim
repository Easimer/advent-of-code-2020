import deques
import json
import os
import options
import sets
import strscans
import strutils
import tables

type
  Bag = tuple[kind: string, color: string]
  BagRule = tuple[lhs: Bag, rhs: Table[Bag, int]]

func parseLine(line: string): BagRule =
  let splitContains = split(line, " bags contain ")
  discard scanf(splitContains[0], "$w $w", result.lhs.kind, result.lhs.color)
  if splitContains[1] != "no other bags.":
    let rhss = split(splitContains[1], ", ")
    for rhs in rhss:
      var b: Bag
      var n: int
      discard scanf(rhs, "$i $w $w", n, b.kind, b.color)
      result.rhs[b] = n

func part1(rules: seq[BagRule]): string =
  let myBag: Bag = (kind: "shiny", color: "gold")
  var mayContain = initHashSet[Bag]()
  var q = initDeque[Bag]()

  for rule in rules:
    if myBag in rule.rhs:
      mayContain.incl(rule.lhs)
      q.addLast(rule.lhs)

  while len(q) != 0:
    let curBag = q.popFirst()
    for rule in rules:
      if curBag in rule.rhs:
        mayContain.incl(rule.lhs)
        q.addLast(rule.lhs)

  return $len(mayContain)

func howManyBagsAreRequiredInside(ruleTable: Table[Bag, Table[Bag, int]], bag: Bag): int =
  result = 1

  for k,v in ruleTable[bag]:
    result += v * ruleTable.howManyBagsAreRequiredInside(k)

func part2(rules: seq[BagRule]): string =
  let ruleTable = rules.toTable()
  let myBag: Bag = (kind: "shiny", color: "gold")

  # Don't count the shiny gold bag itself
  return $(ruleTable.howManyBagsAreRequiredInside(myBag) - 1)


when isMainModule:
  var
    f: File
    line: string
    rules: seq[BagRule]

  let inputPath = if paramCount() > 0: paramStr(1) else: "day7.txt"
  if open(f, inputPath):
    while f.readLine(line):
      let rule = parseLine(line)
      rules.add(rule)

    let res1 = part1(rules)
    let res2 = part2(rules)

    echo(%*{"output1": res1, "output2": res2})
  else:
    echo("Couldn't open input file " & inputPath & "!")

