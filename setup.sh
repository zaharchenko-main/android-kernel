#!/bin/sh

DIR="$(cd "$(dirname "$0")" && pwd)"

sudo apt install clang wget build-essential bc flex git \
        bison gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf \
        zip unzip git wget gcc g++ libncurses5-dev  \
        xz-utils libncurses6 lzip -y

cd $DIR && wget https://snapshots.linaro.org/gnu-toolchain/11.2-2021.12-1/aarch64-linux-gnu/gcc-linaro-11.2.1-2021.12-x86_64_aarch64-linux-gnu.tar.xz
cd $DIR && tar -xf gcc-linaro-11.2.1-2021.12-x86_64_aarch64-linux-gnu.tar.xz
cd $DIR && rm gcc-linaro-11.2.1-2021.12-x86_64_aarch64-linux-gnu.tar.xz
cd $DIR && mv gcc-linaro-11.2.1-2021.12-x86_64_aarch64-linux-gnu gcc
