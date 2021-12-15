#!/bin/sh

DIR="$(cd "$(dirname "$0")" && pwd)"

cd $DIR/out && make \
	ARCH=arm64 \
	CROSS_COMPILE=$DIR"/toolchain/bin/aarch64-linux-gnu-" \
	-j$(nproc --all)
