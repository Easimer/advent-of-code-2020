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
import hashes

type
  Deck = Deque[int]
  PlayerIndex = range[0..1]
  Round = array[2, Deck]
  GameResult = tuple[score: int, player: PlayerIndex]
  Memory = Table[array[2, Deck], GameResult]

func hash(deck: Deck): Hash =
  var h: Hash = 0
  for elem in deck:
    h = h !& elem
  return !$h

proc readDeck(f: var File): Deck =
  discard f.readline()
  var line: string

  while f.readline(line) and len(line) != 0:
    result.addLast(parseInt(line))

## Maps player indices to the opponents' index
func `~+`(playerIdx: PlayerIndex): int =
  if playerIdx == 0: 1 else: 0

func deckScore(deck: Deck): int =
  var mul = 1

  for i in countdown(len(deck) - 1, 0):
    result += deck[i] * mul
    mul += 1

func part1(deck1, deck2: Deck): string =
  var decks = [deck1, deck2]
  while true:
    let cards = [decks[0].popFirst(), decks[1].popFirst()]
    let winner: PlayerIndex = if cards[0] > cards[1]: 0 else: 1
    decks[winner].addLast(cards[winner])
    decks[winner].addLast(cards[~+winner])

    if len(decks[~+winner]) == 0:
      return $deckScore(decks[winner])

func makeDeckCopy(deck: Deck, count: int): Deck =
  for i in 0..count-1:
    result.addLast(deck[i])

proc game(deck1, deck2: Deck, mem: var Memory): GameResult =
  var decks = [deck1, deck2]
  var prevRounds: HashSet[Round]
  while true:
    if decks in prevRounds:
      return (deckScore(decks[0]), PlayerIndex(0))

    prevRounds.incl(decks)
    let cards = [decks[0].popFirst(), decks[1].popFirst()]

    let winner: PlayerIndex =
      if len(decks[0]) >= cards[0] and len(decks[1]) >= cards[1]:
        let newDeck0 = makeDeckCopy(decks[0], cards[0])
        let newDeck1 = makeDeckCopy(decks[1], cards[1])
        let k0 = [newDeck0, newDeck1]
        if k0 in mem:
          mem[k0].player
        else:
          let k1 = [newDeck1, newDeck0]
          if k1 in mem:
            mem[k1].player
          else:
            let res = game(newDeck0, newDeck1, mem)
            mem[k0] = res
            res.player
      else:
        if cards[0] > cards[1]: 0 else: 1

    decks[winner].addLast(cards[winner])
    decks[winner].addLast(cards[~+winner])

    if len(decks[~+winner]) == 0:
      return (deckScore(decks[winner]), winner)


proc part2(deck1, deck2: Deck): string =
  var mem: Memory
  let winnerScore = game(deck1, deck2, mem).score
  return $(winnerScore)

when isMainModule:
  var
    f: File

  let inputPath = if paramCount() > 0: paramStr(1) else: "day22.txt"
  if open(f, inputPath):

    let deck1 = readDeck(f)
    let deck2 = readDeck(f)

    let res1 = part1(deck1, deck2)
    let res2 = part2(deck1, deck2)

    echo(%*{"output1": res1, "output2": res2})
  else:
    echo("Couldn't open input file " & inputPath & "!")

