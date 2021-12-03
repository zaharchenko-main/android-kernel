#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd)"

sudo apt install clang wget build-essential bc flex git \
        bison gcc-aarch64-linux-gnu gcc-arm-linux-gnueabi \
        zip unzip git wget gcc g++ libncurses5-dev  \
        xz-utils -y

rm -rf $DIR/toolchain && mkdir -p $DIR/toolchain

cd $DIR/toolchain && wget https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/+archive/cb7b3ac1b7fdb49474ff68761909934d1142f594.tar.gz
cd $DIR/toolchain && wget https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/+archive/961622e926a1b21382dba4dd9fe0e5fb3ee5ab7c.tar.gz
cd $DIR/toolchain && wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/master/clang-r437112.tar.gz

cd $DIR/toolchain && tar -xf cb7b3ac1b7fdb49474ff68761909934d1142f594.tar.gz
cd $DIR/toolchain && tar -xf 961622e926a1b21382dba4dd9fe0e5fb3ee5ab7c.tar.gz
cd $DIR/toolchain && tar -xf clang-r437112.tar.gz

cd $DIR && git clone --depth=1 https://github.com/zaharchenko-main/kernel_lenovo_sdm710 kernel
