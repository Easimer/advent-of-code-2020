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

func part1(nums: seq[int]): string =
  var heap = initHeapQueue[int]()
  for item in nums: heap.push(item)
  var cur = 0
  var diff1 = 0
  var diff3 = 1

  while len(heap) > 0:
    let adapter = heap.pop()
    let diff = adapter - cur
    assert(0 <= diff and diff <= 3)
    cur = adapter
    if diff == 1:
      diff1 += 1
    elif diff == 3:
      diff3 += 1

  return $(diff1 * diff3)

type
  Context = object
    builtinAdapterJolts: int
    accepted: int64
    cache: Table[int, int64]

func reject(ctx: Context, chain: seq[int]): bool =
  if len(chain) < 1: return false

  if chain[0] > 3: return true

  if len(chain) < 2: return false

  let last = chain[^1]
  let penultimate = chain[^2]
  let diff = last - penultimate

  if penultimate >= last: true
  elif diff > 3: true
  else: false

func accept(ctx: Context, chain: seq[int]): bool =
  if len(chain) == 0: return false

  chain[^1] + 3 == ctx.builtinAdapterJolts

# Let's say the `i`th adapter is `A` and the number of ways to order the remaining
# adapters from there is `N`.
# The value of N doesn't depend on the path already traveled, so we can cache
# it.
func bt(ctx: var Context, availableAdapters: HashSet[int], chain: seq[int]) =
  if reject(ctx, chain):
    return

  if accept(ctx, chain):
    ctx.accepted += 1
    return

  for adapter in availableAdapters:
    if adapter in ctx.cache:
      var newChain = chain
      newChain.add(adapter)
      if not reject(ctx, newChain):
        ctx.accepted += ctx.cache[adapter]
      continue

    var newSet = availableAdapters
    newSet.excl(adapter)
    var newChain = chain
    newChain.add(adapter)

    let start = ctx.accepted
    bt(ctx, newSet, newChain)
    let finish = ctx.accepted

    let ways = finish - start
    if ways != 0:
      ctx.cache[adapter] = ways

func part2(adapters: seq[int]): string =
  let builtinAdapterJolts = max(adapters) + 3
  var ctx = Context(
    builtinAdapterJolts: builtinAdapterJolts,
    accepted: 0,
  )

  bt(ctx, toHashSet(adapters), newSeq[int]())

  return $ctx.accepted

when isMainModule:
  var
    f: File
    line: string
    nums: seq[int]

  let inputPath = if paramCount() > 0: paramStr(1) else: "day10.txt"
  if open(f, inputPath):
    while f.readLine(line):
      nums.add(parseInt(line))

    let res1 = part1(nums)
    let res2 = part2(nums)

    echo(%*{"output1": res1, "output2": res2})
  else:
    echo("Couldn't open input file " & inputPath & "!")

