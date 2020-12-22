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

type
  Deck = Deque[int]

proc readDeck(f: var File): Deck =
  discard f.readline()
  var line: string

  while f.readline(line) and len(line) != 0:
    result.addLast(parseInt(line))

func `~+`(playerIdx: int): int =
  if playerIdx == 0: 1 else: 0

func part1(decksOrig: array[2, Deck]): string =
  var decks = decksOrig
  while true:
    let cards = [decks[0].popFirst(), decks[1].popFirst()]
    let winner = if cards[0] > cards[1]: 0 else: 1
    decks[winner].addLast(cards[winner])
    decks[winner].addLast(cards[~+winner])

    if len(decks[~+winner]) == 0:
      var mul = 1
      var sum = 0

      while len(decks[winner]) > 0:
        sum += decks[winner].popLast() * mul
        mul += 1

      return $sum

when isMainModule:
  var
    f: File

  let inputPath = if paramCount() > 0: paramStr(1) else: "day22.txt"
  if open(f, inputPath):

    let deck1 = readDeck(f)
    let deck2 = readDeck(f)

    let res1 = part1([deck1, deck2])
    let res2 = ""

    echo(%*{"output1": res1, "output2": res2})
  else:
    echo("Couldn't open input file " & inputPath & "!")

