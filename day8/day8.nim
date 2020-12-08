import deques
import json
import os
import options
import sets
import strscans
import strutils
import tables

type
  InstructionKind = enum
    kNop, kAcc, kJmp

  Instruction = object
    case kind: InstructionKind
    of kNop:
      arg: int
    of kAcc:
      inc: int
    of kJmp:
      rel: int

  MachineState = object
    pc: int
    acc: int

  Program = seq[Instruction]

  Execution = tuple[state: var MachineState, program: Program]

func parseLine(line: string): Instruction =
  var mnemonic: string
  var arg: int

  if scanf(line, "$w $i", mnemonic, arg):
    case mnemonic:
      of "nop":
        result = Instruction(kind: kNop, arg: arg)
      of "acc":
        result = Instruction(kind: kAcc, inc: arg)
      of "jmp":
        result = Instruction(kind: kJmp, rel: arg)
      else:
        assert(false)

proc step(state: var MachineState, program: Program) =
  let instr = program[state.pc]
  var nextPc: Option[int]
  case instr.kind:
    of kAcc:
      state.acc += instr.inc
    of kJmp:
      nextPc = some(state.pc + instr.rel)
    else:
      discard

  if isSome(nextPc):
    state.pc = nextPc.get()
  else:
    state.pc += 1

func part1(program: Program): string =
  var pcSet = initHashSet[int]()
  var state = MachineState()

  while not (state.pc in pcSet):
    pcSet.incl(state.pc)
    step(state, program)
  return $state.acc

func part2(origProgram: Program): string =
  let haltPC = len(origProgram)

  for i in 0 ..< haltPC:
    if not (origProgram[i].kind in [kJmp, kNop]):
      continue
    var program = origProgram
    var pcSet = initHashSet[int]()

    case program[i].kind:
    of kJmp:
      program[i] = Instruction(kind: kNop, arg: program[i].rel)
    of kNop:
      program[i] = Instruction(kind: kJmp, rel: program[i].arg)
    else:
      assert(false)
    
    var state = MachineState()
    while state.pc != haltPC:
      if state.pc in pcSet:
        break
      pcSet.incl(state.pc)
      step(state, program)

    if state.pc == haltPC:
      return $state.acc

when isMainModule:
  var
    f: File
    line: string
    program: Program = newSeq[Instruction]()

  let inputPath = if paramCount() > 0: paramStr(1) else: "day8.txt"
  if open(f, inputPath):
    while f.readLine(line):
      let instr = parseLine(line)
      program.add(instr)

    let res1 = part1(program)
    let res2 = part2(program)

    echo(%*{"output1": res1, "output2": res2})
  else:
    echo("Couldn't open input file " & inputPath & "!")

