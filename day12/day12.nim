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
  Command = enum
    N, S, E, W,
    L, R, F
  Instruction = tuple[c: Command, n: int]
  Position = tuple[x: int, y: int]

func turnLeft(c: Command): Command =
  assert(c in [N, S, E, W])
  case c:
    of N: W
    of W: S
    of S: E
    of E: N
    else: N

func turnRight(c: Command): Command =
  assert(c in [N, S, E, W])
  case c:
    of N: E
    of W: N
    of S: W
    of E: S
    else: N

func goForward(pos: Position, dir: Command, n: int): Position =
  assert(dir in [N, S, E, W])
  result = pos
  case dir:
    of N:
      result.y += n
    of S:
      result.y -= n
    of E:
      result.x += n
    of W:
      result.x -= n
    else: discard

func part1(input: seq[Instruction]): string =
  var pos: Position = (0, 0)
  var dir = E

  for instr in input:
    case instr.c:
      of N:
        pos.y += instr.n
      of S:
        pos.y -= instr.n
      of E:
        pos.x += instr.n
      of W:
        pos.x -= instr.n
      of L:
        for i in 1 .. instr.n div 90: dir = turnLeft(dir)
      of R:
        for i in 1 .. instr.n div 90: dir = turnRight(dir)
      of F:
        pos = goForward(pos, dir, instr.n)

  return $(abs(pos.x) + abs(pos.y))

func rotateLeft(wp: Position): Position =
  (-(wp.y), (wp.x))

func rotateRight(wp: Position): Position =
  ((wp.y), -(wp.x))

func part2(input: seq[Instruction]): string =
  var pos: Position = (0, 0)
  var wp: Position = (10, 1)
  var dir = E

  for instr in input:
    case instr.c:
      of N:
        wp.y += instr.n
      of S:
        wp.y -= instr.n
      of E:
        wp.x += instr.n
      of W:
        wp.x -= instr.n
      of L:
        for i in 1 .. instr.n div 90: wp = rotateLeft(wp)
      of R:
        for i in 1 .. instr.n div 90: wp = rotateRight(wp)
      of F:
        pos = (pos.x + instr.n * wp.x, pos.y + instr.n * wp.y)

  return $(abs(pos.x) + abs(pos.y))

when isMainModule:
  var
    f: File
    line: string
    input: seq[Instruction]

  let inputPath = if paramCount() > 0: paramStr(1) else: "day12.txt"
  if open(f, inputPath):
    for line in f.lines():
      let cmd = case line[0]:
        of 'N': N
        of 'S': S
        of 'E': E
        of 'W': W
        of 'L': L
        of 'R': R
        of 'F': F
        else: quit(1)
      let n = parseInt(line[1 .. ^1])
      input.add((cmd, n))

    let res1 = part1(input)
    let res2 = part2(input)

    echo(%*{"output1": res1, "output2": res2})
  else:
    echo("Couldn't open input file " & inputPath & "!")

