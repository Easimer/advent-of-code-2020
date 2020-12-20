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

const TILE_WIDTH = 10
const TILE_HEIGHT = 10

# There are some rotation-flip combinations which result in the same
# transformation.
# For example, a tile facing north with it's X axis flipped is the same as if
# the tile was facing west with it's Y axis flipped.
#
#   N E S W
# N 0 1 2 3
# X 4 5 6 7
# Y 7 6 5 4
#
# Due to this property of these transformations, we don't flip the Y-axes
# of the tiles, because that would lead to duplicate work.

type
  TileData = object
    id: int
    data: array[TILE_WIDTH * TILE_HEIGHT, bool]

  Coord = tuple[x: int, y: int]
  Rotation = enum
    rNorth, rEast, rSouth, rWest
  Flip = enum
    #fNone, fX, fY
    # We don't actually need fY
    fNone, fX
  TileID = int

  Configuration = Table[Coord, (TileID, Rotation, Flip)]

  Image = object
    width: int
    height: int
    pixels: seq[bool]

proc readTile(f: File, t: var TileData): bool =
  if f.endOfFile():
    return false

  let idLine = f.readline()
  if not scanf(idLine, "Tile $i:$.", t.id):
    assert(false)

  for y in 0..TILE_HEIGHT-1:
    let line = f.readline()
    for x in 0..TILE_WIDTH-1:
      t.data[y * TILE_WIDTH + x] = (line[x] == '#')

  # Discard empty file between tiles
  discard f.readline()
  return true

iterator rotations(): Rotation =
  for r in [rNorth, rEast, rSouth, rWest]: yield r

iterator flips(): Flip =
  #for f in [fNone, fX, fY]: yield f
  for f in [fNone, fX]: yield f

iterator unboundTiles(tiles: Table[int, TileData], configuration: Configuration): TileID =
  var boundIdSet: HashSet[TileID]
  for coord, rotTileId in configuration:
    boundIdSet.incl(rotTileId[0])

  for id, data in tiles:
    if id notin boundIdSet:
      yield id

iterator emptyCoords(configuration: Configuration): Coord =
  if len(configuration) == 0:
    yield (0, 0)

  for coord, rotTileId in configuration:
    #debugEcho("emptyCoord rel=" & $coord)
    for d in [-1, 1]:
      let nCoordX = (coord[0] + d, coord[1])
      if nCoordX notin configuration:
        yield nCoordX
      let nCoordY = (coord[0], coord[1] + d)
      if nCoordY notin configuration:
        yield nCoordY

iterator borderCoords(coord: Coord, nCoord: Coord): (Coord, Coord) =
  let dx = nCoord[0] - coord[0]
  let dy = nCoord[1] - coord[1]

  #debugEcho(coord, nCoord, (dx, dy))
  if dx == 1: # neighbor is to the right
    assert(dy == 0)
    for y in 0..TILE_HEIGHT-1:
      yield ((TILE_WIDTH - 1, y), (0, y))
  elif dx == -1: # neighbor is to the left
    assert(dy == 0)
    for y in 0..TILE_HEIGHT-1:
      yield ((0, y), (TILE_WIDTH - 1, y))
  elif dy == 1: # neighbor is to the south
    assert(dx == 0)
    for x in 0..TILE_WIDTH-1:
      yield ((x, TILE_HEIGHT - 1), (x, 0))
  elif dy == -1: # neighbor is to the north
    assert(dx == 0)
    for x in 0..TILE_WIDTH-1:
      yield ((x, 0), (x, TILE_HEIGHT - 1))

func transform(c: Coord, rot: Rotation): Coord =
  let
    x = c[0]
    y = c[1]

  assert(x in 0..TILE_WIDTH-1)
  assert(y in 0..TILE_HEIGHT-1)

  var
    tx: int
    ty: int

  case rot:
    of rNorth:
      ty = y
      tx = x
    of rEast:
      ty = (TILE_HEIGHT - x - 1)
      tx = y
    of rSouth:
      ty = (TILE_HEIGHT - y - 1)
      tx = (TILE_WIDTH - x - 1)
    of rWest:
      ty = x
      tx = (TILE_WIDTH - y - 1)

  assert(tx in 0..TILE_WIDTH-1)
  assert(ty in 0..TILE_HEIGHT-1)

  return (tx, ty)

func transform(c: Coord, f: Flip): Coord =
  let
    x = c[0]
    y = c[1]

  assert(x in 0..TILE_WIDTH-1)
  assert(y in 0..TILE_HEIGHT-1)

  var
    tx = x
    ty = y

  case f:
    of fX:
      tx = TILE_WIDTH - x - 1
    #of fY:
      #ty = TILE_HEIGHT - y - 1
    of fNone:
      discard

  assert(tx in 0..TILE_WIDTH-1)
  assert(ty in 0..TILE_HEIGHT-1)
  return (tx, ty)

func accessTile(tiles: Table[int, TileData], id: int, f: Flip, r: Rotation, x: int, y: int): bool =
  assert(id in tiles)
  assert(x in 0..TILE_WIDTH-1)
  assert(y in 0..TILE_HEIGHT-1)

  let (tx, ty) = transform(transform((x, y), r), f)

  tiles[id].data[ty * TILE_WIDTH + tx]

func mismatchPresent(tiles: Table[int, TileData], configuration: Configuration): bool =
  for coord, rotTileId in configuration: # for every tile
    let (id, rotation, flip) = rotTileId
    for dy in -1..1:
      for dx in -1..1:
        if (dx != 0 or dy != 0) and ((dx != 0 and dy == 0) or (dy != 0 and dx == 0)):
          let nCoord = (coord[0] + dx, coord[1] + dy)
          if nCoord in configuration: # for every neighbor
            let (nID, nRotation, nFlip) = configuration[nCoord]

            for bc in borderCoords(coord, nCoord): # check coordinates
              let px = accessTile(tiles, id, flip, rotation, bc[0][0], bc[0][1])
              let nPx = accessTile(tiles, nID, nFlip, nRotation, bc[1][0], bc[1][1])
              if px != nPx:
                return true
  return false

func allTilesAreInConfiguration(tiles: Table[int, TileData], configuration: Configuration): bool =
  #debugEcho((len(tiles), len(configuration)))
  len(tiles) == len(configuration)

func extent(c: Configuration): tuple[minX: int, minY: int, maxX: int, maxY: int] =
  result.minX = 9999
  result.maxX = -9999
  result.minY = 9999
  result.maxY = -9999

  for coord, tileIdTrans in c:
    result.minX = min(coord[0], result.minX)
    result.maxX = max(coord[0], result.maxX)
    result.minY = min(coord[1], result.minY)
    result.maxY = max(coord[1], result.maxY)

proc debugEchoTileIDs(configuration: Configuration) =
  let (minX, minY, maxX, maxY) = extent(configuration)

  debugEcho(">=====================")
  debugEcho((minX, minY))
  for y in minY..maxY:
    for x in minX..maxX:
      if (x, y) in configuration:
        stdout.write($configuration[(x, y)][0] & ", ")
      else:
        stdout.write("----, ")
    stdout.write("\n")
  debugEcho("<=====================")

proc asd(tiles: Table[int, TileData], configuration: Configuration): Option[Configuration] =
  #debugEchoTileIDs(configuration)

  if mismatchPresent(tiles, configuration): return none(Configuration)
  if allTilesAreInConfiguration(tiles, configuration):
    return some(configuration)

  for emptyCoord in emptyCoords(configuration):
    for unboundTileID in unboundTiles(tiles, configuration):
      for rotation in rotations():
        for flip in flips():
          var configurationCopy = configuration
          assert(emptyCoord notin configurationCopy)
          #debugEcho("[<] " & $unboundTileID)
          configurationCopy[emptyCoord] = (unboundTileID, rotation, flip)
          let res = asd(tiles, configurationCopy)
          if res.isSome(): return res

func findCornersProduct(c: Configuration): int =
  let (minX, minY, maxX, maxY) = extent(c)

  let c0 = c[(minX, minY)][0]
  let c1 = c[(minX, maxY)][0]
  let c2 = c[(maxX, minY)][0]
  let c3 = c[(maxX, maxY)][0]

  return c0 * c1 * c2 * c3

proc part1(tiles: seq[TileData]): (Configuration, string) =
  var tileTable: Table[int, TileData]
  for tile in tiles:
    tileTable[tile.id] = tile

  let res = asd(tileTable, Configuration())
  assert(res.isSome())
  let conf = res.get()

  return (conf, $findCornersProduct(conf))

proc reassemble(tiles: seq[TileData], conf: Configuration): Image =
  let (minX, minY, maxX, maxY) = extent(conf)
  let tw = maxX - minX
  let th = maxY - minY
  let width = tw * 9
  let height = th * 9
  result.width = width
  result.height = height

when isMainModule:
  var
    f: File
    tile: TileData
    tiles: seq[TileData]
    strings: seq[string]

  let inputPath = if paramCount() > 0: paramStr(1) else: "day20.txt"
  if open(f, inputPath):
    while readTile(f, tile):
      tiles.add(tile)
    let (conf, res1) = part1(tiles)
    let res2 = "" 

    echo(%*{"output1": res1, "output2": res2})
  else:
    echo("Couldn't open input file " & inputPath & "!")

