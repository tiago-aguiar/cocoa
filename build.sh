#!/bin/sh

mkdir build
pushd build
clang -g -o cocoa ../src/osx_main.mm
popd
