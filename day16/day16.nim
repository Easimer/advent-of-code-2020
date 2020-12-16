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

type
  Rule = tuple[
    id: string,
    r00: int,
    r01: int,
    r10: int,
    r11: int,
  ]
  Ticket = seq[int]

func parseRule(line: string): Rule =
  if scanf(line, "$*: $i-$i or $i-$i", result.id, result.r00, result.r01, result.r10, result.r11):
    discard
  else:
    assert(false)

func parseTicket(line: string): seq[int] =
  let vs = line.split(',')
  for s in vs:
    result.add(parseInt(s))

func findValidTickets(rules: seq[Rule], nearbyTickets: seq[Ticket]): seq[Ticket] =
  for ticket in nearbyTickets:
    var ticketFlag = true
    for field in ticket:
      var fieldFlag = false 
      for rule in rules:
        if ((field in rule.r00 .. rule.r01) or (field in rule.r10 .. rule.r11)):
          fieldFlag = true 
          break
      if not fieldFlag:
        ticketFlag = false
        break
    if ticketFlag:
      result.add(ticket)

func part1(rules: seq[Rule], nearbyTickets: seq[Ticket]): string =
  var cnt = 0
  for ticket in nearbyTickets:
    for field in ticket:
      var flag = false 
      for rule in rules:
        if ((field in rule.r00 .. rule.r01) or (field in rule.r10 .. rule.r11)):
          flag = true
      if not flag:
        cnt += field
  return $cnt

func part2(rules: seq[Rule], nearbyTickets: seq[Ticket], myTicket: Ticket): string =
  var colTable = newTable[string, int]() # rule id -> col idx
  let nearbyValidTickets = findValidTickets(rules, nearbyTickets)
  var knownColSet = initHashSet[int]()

  while len(colTable) != len(myTicket):
    for col in 0 .. high(myTicket):
      if col in knownColSet:
        continue

      var colSet = initHashSet[Rule]()
      for rule in rules:
        if not (rule.id in colTable):
          colSet.incl(rule)

      for ticket in nearbyValidTickets:
        for rule in colSet:
          let field = ticket[col]
          if not ((field in rule.r00 .. rule.r01) or (field in rule.r10 .. rule.r11)):
            #debugEcho((ev: "exclude", col: col, field: field, rule: rule))
            colSet.excl(rule)

        if len(colSet) == 1:
          break
      #assert(len(colSet) == 1)
      if len(colSet) == 1:
        let id = colSet.pop().id
        colTable[id] = col
        knownColSet.incl(col)
        #debugEcho((ev: "matched", col: col, id: id))
      #else:
        #debugEcho((ev: "dontknow", col: col))

  var acc = 1
  for ruleId, colIdx in colTable:
    if ruleId.startswith("departure"):
      acc *= myTicket[colIdx]

  return $acc


when isMainModule:
  var
    f: File
    line: string
    rules: seq[Rule]
    myTicket: Ticket
    nearbyTickets: seq[Ticket]

  let inputPath = if paramCount() > 0: paramStr(1) else: "day16.txt"
  if open(f, inputPath):
    while true:
      line = f.readline()
      if len(line) > 0:
        rules.add(parseRule(line))
      else:
        break
    discard f.readline() # eat "your ticket:"
    myTicket = parseTicket(f.readline())

    discard f.readline() # eat empty line
    discard f.readline() # eat "nearby tickets:"

    while f.readline(line):
      nearbyTickets.add(parseTicket(line))

    let res1 = part1(rules, nearbyTickets)
    let res2 = part2(rules, nearbyTickets, myTicket)

    echo(%*{"output1": res1, "output2": res2})
  else:
    echo("Couldn't open input file " & inputPath & "!")

