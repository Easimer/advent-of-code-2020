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

func transform(c: Coord, width, height: int, rot: Rotation): Coord =
  let
    x = c[0]
    y = c[1]

  assert(x in 0..width-1)
  assert(y in 0..height-1)

  var
    tx: int
    ty: int

  case rot:
    of rNorth:
      ty = y
      tx = x
    of rEast:
      ty = (height - x - 1)
      tx = y
    of rSouth:
      ty = (height - y - 1)
      tx = (width - x - 1)
    of rWest:
      ty = x
      tx = (width - y - 1)

  assert(tx in 0..width-1)
  assert(ty in 0..height-1)

  return (tx, ty)

func transform(c: Coord, width, height: int, f: Flip): Coord =
  let
    x = c[0]
    y = c[1]

  assert(x in 0..width-1)
  assert(y in 0..height-1)

  var
    tx = x
    ty = y

  case f:
    of fX:
      tx = width - x - 1
    #of fY:
      #ty = height - y - 1
    of fNone:
      discard

  assert(tx in 0..width-1)
  assert(ty in 0..height-1)
  return (tx, ty)

func accessTile(tiles: Table[int, TileData], id: int, f: Flip, r: Rotation, x: int, y: int): bool =
  assert(id in tiles)
  assert(x in 0..TILE_WIDTH-1)
  assert(y in 0..TILE_HEIGHT-1)

  let (tx, ty) = transform(transform((x, y), TILE_WIDTH, TILE_HEIGHT, r), TILE_WIDTH, TILE_HEIGHT, f)

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

proc part1(tiles: Table[int, TileData]): (Configuration, string) =
  let res = asd(tiles, Configuration())
  assert(res.isSome())
  let conf = res.get()

  return (conf, $findCornersProduct(conf))

proc reassemble(tiles: Table[int, TileData], conf: Configuration): Image =
  let (minX, minY, maxX, maxY) = extent(conf)
  let tw = maxX - minX + 1
  let th = maxY - minY + 1
  let width = tw * 8
  let height = th * 8
  result.width = width
  result.height = height

  var Tx = minX
  var Ty = minY
  var tx = 1
  var ty = 1

  while Ty <= maxY:
    while Tx <= maxX:
      assert((Tx, Ty) in conf)
      let (id, rot, flip) = conf[(Tx, Ty)]
      result.pixels.add(accessTile(tiles, id, flip, rot, tx, ty))
      tx += 1
      if tx == 9:
        Tx += 1
        tx = 1

    ty += 1
    Tx = minX

    if ty == 9:
      Ty += 1
      ty = 1

func access(img: Image, f: Flip, r: Rotation, x, y: int): bool =
  assert(x in 0..img.width-1)
  assert(y in 0..img.height-1)

  let (tx, ty) = transform(transform((x, y), img.width, img.height, r), img.width, img.height, f)

  img.pixels[ty * img.width + tx]

proc display(img: Image) =
  echo((w: img.width, h: img.height))
  for y in 0..img.height-1:
    for x in 0..img.width-1:
      stdout.write(if img.pixels[y * img.width + x]: '#' else: '.')

    stdout.write("\n")

func countKrakenParts(kraken: openarray[string]): int =
  for s in kraken:
    for ch in s:
      result += (if ch == '#': 1 else: 0)

const
  theSeaMonster = [
    "                  # ",
    "#    ##    ##    ###",
    " #  #  #  #  #  #   "
  ]

const KRAKEN_HEIGHT = len(theSeaMonster)
const KRAKEN_WIDTH = len(theSeaMonster[0])
const KRAKEN_TOTAL_PARTS = countKrakenParts(theSeaMonster)

## This is what I call the "kraken" gate
## Mask Img | Out Kraken
##    .   . |   1      0
##    .   # |   1      0
##    #   . |   0      0
##    #   # |   1      1
##
## The sea monster is present in a given region of the image
## if `kraken(pixel in the mask, pixel in the image)` is true
## for all (pixel in the mask, pixel in the image) of the region
##
## Returns whether the mask matches the image plus whether the image contains
## a part of the kraken.
func kraken(mask: bool, image: bool): tuple[match: bool, partOf: bool] =
  ((not mask) or image, mask and image)

func kraken(img: Image, rotation: Rotation, flip: Flip, maskPos: (int, int)): Option[HashSet[Coord]] =
  if not (maskPos[0] + KRAKEN_WIDTH < img.width): return
  if not (maskPos[1] + KRAKEN_HEIGHT < img.height): return

  var s: HashSet[Coord]

  for y in 0..KRAKEN_HEIGHT-1:
    let iy = maskPos[1] + y
    for x in 0..KRAKEN_WIDTH-1:
      let ix = maskPos[0] + x
      let px = access(img, flip, rotation, ix, iy)
      let (match, partOf) = kraken(theSeaMonster[y][x] == '#', px)
      if not match:
        return
      if match and partOf:
        s.incl((ix, iy))

  assert(len(s) == KRAKEN_TOTAL_PARTS)
  return some(s)

func part2(img: Image): string =
  var krakenParts: HashSet[Coord]
  for rotation in rotations():
    for flip in flips():
      for y in 0..img.height-1:
        for x in 0..img.width-1:
          let parts = kraken(img, rotation, flip, (x, y))
          if parts.isSome():
            #debugEcho("Found kraken at " & $(x, y))
            krakenParts = krakenParts + parts.get()
            #debugEcho(parts.get())

  var cnt = 0
  for pixel in img.pixels:
    if pixel: cnt += 1

  return $(cnt - len(krakenParts))

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

    var tileTable: Table[int, TileData]
    for tile in tiles:
      tileTable[tile.id] = tile

    let (conf, res1) = part1(tileTable)
    let img = reassemble(tileTable, conf)
    #display(img)
    let res2 = part2(img)

    echo(%*{"output1": res1, "output2": res2})
  else:
    echo("Couldn't open input file " & inputPath & "!")

