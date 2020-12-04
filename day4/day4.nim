import aocutils
import json
import os
import strutils
import options

type
  Passport = object
    birthYear: Option[int]
    issueYear: Option[int]
    expirationYear: Option[int]
    height: Option[string]
    hairColor: Option[string]
    eyeColor: Option[string]
    passportId: Option[string]
    countryId: Option[int]

  HeightKind = enum
    Centimeters,
    Inches

  Height = object
    case kind: HeightKind
    of Centimeters:
      centimeters: range[150 .. 193]
    of Inches:
      inches: range[59 .. 76]

  ValidPassport = object
    birthYear: range[1920 .. 2002]
    issueYear: range[2010 .. 2020]
    expirationYear: range[2020 .. 2030]
    height: Height
    hairColor: string
    eyeColor: string
    passportId: int
    countryId: Option[int]

func parseLine(buffer: var seq[(string, string)], line: string): bool =
  if len(strip(line)) == 0:
    return false

  let kvs = line.split()
  for raw_kv in kvs:
    let kv = raw_kv.split(':')
    buffer.add((kv[0], kv[1]))

  return true

func validateHexCode(s: string): Option[string] =
  if len(s) != 7:
    none(string)
  elif s[0] != '#':
    none(string)
  else:
    if all(s[1 .. ^1], proc (c: char): bool = (c in '0'..'9') or (c in 'a'..'f')):
      some(s)
    else:
      none(string)

func parseBuffer(buffer: seq[(string, string)]): Passport =
  var passport = Passport()
  for kv in buffer:
    case kv[0]:
      of "byr":
        passport.birthYear = some(parseInt(kv[1]))
      of "iyr":
        passport.issueYear = some(parseInt(kv[1]))
      of "eyr":
        passport.expirationYear = some(parseInt(kv[1]))
      of "hgt":
        passport.height = some(kv[1])
      of "hcl":
        passport.hairColor = some(kv[1])
      of "ecl":
        passport.eyeColor = some(kv[1])
      of "pid":
        passport.passportId = some(kv[1])
      of "cid":
        passport.countryId = some(parseInt(kv[1]))
  return passport

func parseHeight(height: string): Option[Height] =
  if len(height) >= 3:
    let units = height[^2 .. ^1]
    let value = parseInt(height[0 .. ^3])
    case units
    of "cm":
      return some(Height(kind: Centimeters, centimeters: value))
    of "in":
      return some(Height(kind: Inches, inches: value))

func validateEyeColor(s: string): Option[string] =
  if system.contains(["amb", "blu", "brn", "gry", "grn", "hzl", "oth"], s):
    some(s)
  else:
    none(string)

func validatePassportId(s: string): Option[int] =
  if len(s) == 9:
    some(parseInt(s))
  else:
    none(int)

func validate(passport: Passport): Option[ValidPassport] =
  try:
    let hairColor = validateHexCode(passport.hairColor.get()).get()
    let eyeColor = validateEyeColor(passport.eyeColor.get()).get()
    let passportId = validatePassportId(passport.passportId.get()).get()

    return some(ValidPassport(
      birthYear: passport.birthYear.get(),
      issueYear: passport.issueYear.get(),
      expirationYear: passport.expirationYear.get(),
      height: parseHeight(passport.height.get()).get(),
      hairColor: hairColor,
      eyeColor: eyeColor,
      passportId: passportId,
      countryId: passport.countryId
    ))
  except Exception:
    return none(ValidPassport)


func part1(passports: seq[Passport]): string =
  var cnt = 0

  for p in passports:
    if isSome(p.birthYear) and isSome(p.issueYear) and
      isSome(p.expirationYear) and isSome(p.height) and
      isSome(p.hairColor) and isSome(p.eyeColor) and
      isSome(p.passportId):
      cnt += 1

  return $cnt

func part2(passports: seq[Passport]): string =
  var cnt = 0
  for p in passports:
    let maybeValidPass = validate(p)
    if isSome(maybeValidPass):
      cnt += 1

  return $cnt


when isMainModule:
  var
    f: File
    line: string

  let inputPath = if paramCount() > 0: paramStr(1) else: "day4.txt"
  if open(f, inputPath):
    var passports = newSeq[Passport]()
    var buffer = newSeq[(string, string)]()
    while f.readLine(line):
      if not parseLine(buffer, line):
        let passport = parseBuffer(buffer)
        passports.add(passport)
        buffer.setLen(0)
    if len(buffer) != 0:
      let passport = parseBuffer(buffer)
      passports.add(passport)


    let res1 = part1(passports)
    let res2 = part2(passports)

    echo(%*{"output1": res1, "output2": res2})
  else:
    echo("Couldn't open input file " & inputPath & "!")

