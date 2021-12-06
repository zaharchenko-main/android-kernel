#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd)"

rm -rf $DIR"/anykernel/Image.gz-dtb" $DIR"/UPDATE-kernel.zip"
cp $DIR"/out/arch/arm64/boot/Image.gz-dtb" $DIR"/anykernel/Image.gz-dtb"
cd $DIR"/anykernel" && zip -r9 UPDATE-kernel.zip *
mv $DIR"/anykernel/UPDATE-kernel.zip" $DIR"/UPDATE-kernel.zip"
rm -rf $DIR"/anykernel/Image.gz-dtb"
