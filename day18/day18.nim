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
  TokenKind = enum
    tkNumber, tkPlus, tkMul, tkParenOpen, tkParenClose
  Token = object
    case kind: TokenKind
    of tkNumber:
      value: int
    else: discard

func tokenize(line: string): seq[Token] =
  for ch in line:
    if ch in '0'..'9':
      result.add(Token(kind: tkNumber, value: parseInt($ch)))
    elif ch == '+':
      result.add(Token(kind: tkPlus))
    elif ch == '*':
      result.add(Token(kind: tkMul))
    elif ch == '(':
      result.add(Token(kind: tkParenOpen))
    elif ch == ')':
      result.add(Token(kind: tkParenClose))

func evalPrefix(tokens: var seq[Token]): int =
  let top = tokens.pop()

  case top.kind:
    of tkNumber:
      return top.value
    of tkPlus:
      let lhs = evalPrefix(tokens)
      let rhs = evalPrefix(tokens)
      return lhs + rhs
    of tkMul:
      let lhs = evalPrefix(tokens)
      let rhs = evalPrefix(tokens)
      return lhs * rhs
    else: assert(false)

func eval(tokens: seq[Token], prec: Table[TokenKind, int]): int =
  var output: seq[Token]
  var operators: seq[Token]

  for i in 0 .. high(tokens):
    let tok = tokens[i]
    if tok.kind == tkNumber:
      output.add(tok)
    elif tok.kind in @[tkPlus, tkMul]:
      assert(tok.kind in prec)
      let tokPrec = prec[tok.kind]
      while len(operators) > 0:
        let top = operators[^1]
        if top.kind == tkParenOpen:
          break
        if (prec[top.kind] >= tokPrec):
          output.add(operators.pop())
        else:
          break
      operators.add(tok)
    elif tok.kind == tkParenOpen:
      operators.add(tok)
    elif tok.kind == tkParenClose:
      while len(operators) > 0 and operators[^1].kind != tkParenOpen:
        output.add(operators.pop())
      assert(len(operators) > 0)
      assert(operators[^1].kind == tkParenOpen)
      discard operators.pop()
  while len(operators) > 0:
    output.add(operators.pop())

  return evalPrefix(output)

func part1(exprs: seq[seq[Token]]): string =
  var sum = 0
  for expr in exprs:
    var i = 0
    let prec = { tkPlus: 0, tkMul: 0 }.toTable()
    let value = eval(expr, prec)
    sum += value

  return $sum

func part2(exprs: seq[seq[Token]]): string =
  var sum = 0
  for expr in exprs:
    var i = 0
    let prec = { tkPlus: 1, tkMul: 0 }.toTable()
    let value = eval(expr, prec)
    sum += value

  return $sum

when isMainModule:
  var
    f: File
    line: string
    exprs: seq[seq[Token]]

  let inputPath = if paramCount() > 0: paramStr(1) else: "day18.txt"
  if open(f, inputPath):
    for line in f.lines():
      let tokens = tokenize(line)
      exprs.add(tokens)

    let res1 = part1(exprs)
    let res2 = part2(exprs)

    echo(%*{"output1": res1, "output2": res2})
  else:
    echo("Couldn't open input file " & inputPath & "!")

