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

type
  Rule = ref object of RootObj

  RuleRefKind = enum
    rrkPresent, rrkIndex

  RuleRef = object
    case kind: RuleRefKind
    of rrkPresent:
      rule: Rule
    of rrkIndex:
      index: int

  RuleSingleChar = ref object of Rule
    ch: char

  RuleAnd = ref object of Rule
    subrules: seq[RuleRef]

  RuleOr = ref object of Rule
    r0: RuleAnd
    r1: RuleAnd

func parseRule(line: string): tuple[idx: int, rule: Rule] =
  var ch: string
  var i0: int
  var i1: int
  var i2: int
  var i3: int
  if scanf(line, "$i: $i $i | $i $i$.", result.idx, i0, i1, i2, i3):
    let r0 = RuleRef(kind: rrkIndex, index: i0)
    let r1 = RuleRef(kind: rrkIndex, index: i1)
    let ra0 = RuleAnd(subrules: @[r0, r1])
    let r2 = RuleRef(kind: rrkIndex, index: i2)
    let r3 = RuleRef(kind: rrkIndex, index: i3)
    let ra1 = RuleAnd(subrules: @[r2, r3])
    result.rule = RuleOr(r0: ra0, r1: ra1)
  elif scanf(line, "$i: $i | $i$.", result.idx, i0, i1):
    let r0 = RuleRef(kind: rrkIndex, index: i0)
    let ra0 = RuleAnd(subrules: @[r0])
    let r1 = RuleRef(kind: rrkIndex, index: i1)
    let ra1 = RuleAnd(subrules: @[r1])
    result.rule = RuleOr(r0: ra0, r1: ra1)
  elif scanf(line, "$i: $i $i $i$.", result.idx, i0, i1, i2):
    let r0 = RuleRef(kind: rrkIndex, index: i0)
    let r1 = RuleRef(kind: rrkIndex, index: i1)
    let r2 = RuleRef(kind: rrkIndex, index: i2)
    result.rule = RuleAnd(subrules: @[r0, r1, r2])
  elif scanf(line, "$i: $i $i$.", result.idx, i0, i1):
    let r0 = RuleRef(kind: rrkIndex, index: i0)
    let r1 = RuleRef(kind: rrkIndex, index: i1)
    result.rule = RuleAnd(subrules: @[r0, r1])
  elif scanf(line, "$i: $i$.", result.idx, i0):
    let r0 = RuleRef(kind: rrkIndex, index: i0)
    result.rule = RuleAnd(subrules: @[r0])
  elif scanf(line, "$i: \"$+\"$.", result.idx, ch):
    result.rule = RuleSingleChar(ch: ch[0])
  else:
    debugEcho(line)
    assert(false)

method resolveRule(rule: Rule, rules: var Table[int, Rule]) {.base.} =
  assert(false)

method resolveRule(rule: RuleSingleChar, rules: var Table[int, Rule]) = discard

method resolveRule(rule: RuleAnd, rules: var Table[int, Rule]) =
  for i in 0 .. high(rule.subrules):
    let subrule = rule.subrules[i]
    if subrule.kind == rrkIndex:
      debugEcho("resolving rule " & $subrule.index)
      resolveRule(rules[subrule.index], rules)
      rule.subrules[i] = RuleRef(kind: rrkPresent, rule: rules[subrule.index])

method resolveRule(rule: RuleOr, rules: var Table[int, Rule]) =
  resolveRule(rule.r0, rules)
  resolveRule(rule.r1, rules)

func resolveRules(rules: var Table[int, Rule]) =
  for idx, rule in rules:
    debugEcho("resolving top rule " & $idx)
    resolveRule(rule, rules)

method tryMatchRule(s: string, rule: Rule, i: var int): bool {.base.} =
  quit("pure virtual")

method tryMatchRule(s: string, rule: RuleSingleChar, i: var int): bool =
  debugEcho("matching " & $rule.ch & " at " & $i)
  if i > high(s): return false
  result = s[i] == rule.ch
  i += 1

method tryMatchRule(s: string, rule: RuleAnd, i: var int): bool =
  result = true
  debugEcho("matching n=" & $len(rule.subrules) & " rules")
  for subrule in rule.subrules:
    assert(subrule.kind == rrkPresent)
    let res = tryMatchRule(s, subrule.rule, i)
    result = result and res

method tryMatchRule(s: string, rule: RuleOr, i: var int): bool =
  let iOrig = i
  if tryMatchRule(s, rule.r0, i):
    return true
  i = iOrig
  if tryMatchRule(s, rule.r1, i):
    return true
  return false

proc part1(rules: Table[int, Rule], strings: seq[string]): string =
  var cnt = 0
  for s in strings:
    debugEcho("string: " & s)
    var i = 0
    if tryMatchRule(s, rules[0], i):
      # is the cursor one past the end?
      if i == high(s) + 1:
        cnt += 1
  return $cnt

proc part2(rulesOrig: Table[int, Rule], strings: seq[string]): string = ""

when isMainModule:
  var
    f: File
    line: string
    rules: Table[int, Rule]
    strings: seq[string]

  let inputPath = if paramCount() > 0: paramStr(1) else: "day19.txt"
  if open(f, inputPath):
    # Read rules
    for line in f.lines():
      if len(line) == 0:
        break
      let (idx, rule) = parseRule(line)
      rules[idx] = rule
    # Read strings
    for line in f.lines():
      strings.add(line)
    
    resolveRules(rules)
    let res1 = part1(rules, strings)
    let res2 = part2(rules, strings)

    echo(%*{"output1": res1, "output2": res2})
  else:
    echo("Couldn't open input file " & inputPath & "!")

