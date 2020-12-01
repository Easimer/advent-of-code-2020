# Package

version       = "1.0.0"
author        = "Daniel Meszaros"
description   = "AoC 2020 - Day 1"
license       = "MIT"
srcDir        = "src"
bin           = @["day1.exe"]

backend       = "c"

# Dependencies

requires "nim >= 1.0.0"
requires "bignum >= 1.0.4"
requires "aocutils >= 0.1.2"
