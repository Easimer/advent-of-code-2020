#!/bin/bash

for dir in day*/; do
    pushd $dir
    make
    popd
done
