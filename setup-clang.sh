#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd)"

rm -rf $DIR/toolchain/clang && mkdir -p $DIR/toolchain/clang

cd $DIR/toolchain/clang && wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/master/clang-r437112.tar.gz
cd $DIR/toolchain/clang && tar -xf clang-r437112.tar.gz
