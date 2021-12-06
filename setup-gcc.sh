#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd)"

sudo apt install clang wget build-essential bc flex git \
        bison gcc-aarch64-linux-gnu gcc-arm-linux-gnueabi \
        zip unzip git wget gcc g++ libncurses5-dev  \
        xz-utils -y

rm -rf $DIR/toolchain/gcc && mkdir -p $DIR/toolchain/gcc

cd $DIR/toolchain/gcc && wget https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/+archive/cb7b3ac1b7fdb49474ff68761909934d1142f594.tar.gz
cd $DIR/toolchain/gcc && wget https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/+archive/961622e926a1b21382dba4dd9fe0e5fb3ee5ab7c.tar.gz

cd $DIR/toolchain/gcc && tar -xf cb7b3ac1b7fdb49474ff68761909934d1142f594.tar.gz
cd $DIR/toolchain/gcc && tar -xf 961622e926a1b21382dba4dd9fe0e5fb3ee5ab7c.tar.gz
