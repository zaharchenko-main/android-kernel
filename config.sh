#!/bin/sh

DIR="$(cd "$(dirname "$0")" && pwd)"

cd $DIR/kernel && make \
	O=$DIR/out \
	ARCH=arm64 \
	CROSS_COMPILE=$DIR"/gcc/bin/aarch64-linux-gnu-" \
	$(cat $DIR/devive)_defconfig \
	menuconfig
