#!/bin/sh

if [ -z $AOC_SESSION]; then
    echo "Please set AOC_SESSION to your session token!"
    exit 1
fi

BASE_URL=https://adventofcode.com/2020/day
for i in $(seq 1 25); do
    DIR=day$i/
    if [ ! -d $DIR ]; then
        continue
    fi
    INPUT_URL=$BASE_URL/$i/input
    curl -v --cookie "session=$AOC_SESSION" -o $DIR/day$i.txt $INPUT_URL
done
