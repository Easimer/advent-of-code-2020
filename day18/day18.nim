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

func pushValue(acc: var Option[int], prevOp: var Option[TokenKind], value: int) =
  if acc.isNone():
    acc = some(value)
  else:
    assert(prevOp.isSome())
    case prevOp.get():
      of tkPlus:
        acc = some(acc.get() + value)
      of tkMul:
        acc = some(acc.get() * value)
      else:
        assert(false)
    prevOp = none(TokenKind)


func eval(tokens: seq[Token], i: var int): int =
  var acc = none(int)
  var prevOp = none(TokenKind)
  while i < len(tokens):
    debugEcho((acc: acc, prevOp: prevOp, i: i, token: tokens[i]))
    case tokens[i].kind:
      of tkNumber:
        pushValue(acc, prevOp, tokens[i].value)
      of tkPlus:
        assert(acc.isSome())
        assert(prevOp.isNone())
        prevOp = some(tkPlus)
      of tkMul:
        assert(acc.isSome())
        assert(prevOp.isNone())
        prevOp = some(tkMul)
      of tkParenOpen:
        i += 1
        debugEcho("PSH")
        let value = eval(tokens, i)
        debugEcho("POP")
        pushValue(acc, prevOp, value)
      of tkParenClose:
        break
    i += 1

  assert(acc.isSome())
  return acc.get()

func part1(exprs: seq[seq[Token]]): string =
  var sum = 0
  for expr in exprs:
    var i = 0
    debugEcho($expr)
    let value = eval(expr, i)
    sum += value

  return $sum

func part2(exprs: seq[seq[Token]]): string = ""


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

