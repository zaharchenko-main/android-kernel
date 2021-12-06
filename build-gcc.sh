#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd)"

export PATH=$DIR"/toolchain/gcc/bin":$PATH

export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-android-
export CROSS_COMPILE_ARM32=arm-linux-androideabi-

cd $DIR/kernel && make \
	O=$DIR/out \
	ARCH=$ARCH \
	CROSS_COMPILE=$CROSS_COMPILE \
	-j$(nproc --all)
