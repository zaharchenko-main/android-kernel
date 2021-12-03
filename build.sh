#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd)"

export PATH=$DIR"/toolchain/bin":$PATH
export LD_LIBRARY_PATH=$DIR"/toolchain/lib64":$LD_LIBRARY_PATH

export ARCH=arm64
export SUBARCH=arm64
export CLANG_TRIPLE=aarch64-linux-gnu-
export CROSS_COMPILE=aarch64-linux-android-
export CROSS_COMPILE_ARM32=arm-linux-androideabi-

cd $DIR/kernel && make \
	O=$DIR/out \
	CC=clang \
	AR=llvm-ar \
	NM=llvm-nm \
	AS=llvm-as \
	OBJCOPY=llvm-objcopy \
	OBJDUMP=llvm-objdump \
	READELF=llvm-readelf \
	OBJSIZE=llvm-size \
	STRIP=llvm-strip \
	-j$(nproc --all)
