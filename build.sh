#!/bin/sh

mkdir build
pushd build
clang -g -framework AppKit -o cocoa ../src/osx_main.mm
popd
