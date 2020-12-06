import json
import os
import sets
import options

type
  Person = HashSet[char]
  Group = HashSet[char]

func parseLine(line: string): Option[Person] =
  if len(line) == 0:
    return none(Person)
  else:
    var ret = Person()
    for ch in line:
      ret.incl(ch)
    return some(ret)

func countElements(groups: seq[Group]): string =
  var cnt = 0

  for g in groups:
    cnt += len(g)

  return $cnt

func neutralGroup(): Group =
  for ch in 'a'..'z':
    result.incl(ch)

when isMainModule:
  var
    f: File
    line: string

  let inputPath = if paramCount() > 0: paramStr(1) else: "day6.txt"
  if open(f, inputPath):
    var groups = newSeq[Group]()
    var groupsIntersected = newSeq[Group]()
    var currentGroup = Group()
    var currentGroupIntersected = neutralGroup()
    while f.readLine(line):
      let maybePerson = parseLine(line)
      if isSome(maybePerson):
        currentGroup = union(currentGroup, maybePerson.get())
        currentGroupIntersected = intersection(currentGroupIntersected, maybePerson.get())
      else:
        groups.add(currentGroup)
        currentGroup = Group()

        groupsIntersected.add(currentGroupIntersected)
        currentGroupIntersected = neutralGroup()

    groups.add(currentGroup)

    groupsIntersected.add(currentGroupIntersected)

    let res1 = countElements(groups)
    let res2 = countElements(groupsIntersected)

    echo(%*{"output1": res1, "output2": res2})
  else:
    echo("Couldn't open input file " & inputPath & "!")

