#!/usr/bin/env bash

DIR="$(cd "$(dirname "$0")" && pwd)"
TOLCHAINS=$DIR"/toolchains"
DATE_NAME="$(date +%Y%m%d)"
PATCH_LVL="$(date +%Y-%m-%d)"
PROCS="$(nproc --all)"

FILE=$DIR"/update/META-INF/com/google/android/updater-script"

source $DIR/params

setup() {
  sudo apt install clang wget build-essential \
    bc flex git bison gcc-aarch64-linux-gnu \
    gcc-arm-linux-gnueabihf libncurses6 lzip \
    zip unzip git wget gcc g++ libncurses5-dev  \
    xz-utils libncurses6 python3 python2 -y

  rm -rf $DIR/boot && mkdir -p $DIR/boot/bin && cd $DIR/boot/bin

  wget https://android.googlesource.com/platform/system/tools/mkbootimg/+archive/refs/heads/master.tar.gz
  wget https://android.googlesource.com/platform/system/libufdt/+archive/refs/heads/master/utils/src.tar.gz

  tar -xf master.tar.gz
  tar -xf src.tar.gz

  rm -rf master.tar.gz src.tar.gz
}

clean() {
  rm -rf $DIR/boot $DIR/update/boot.img $DIR/update/dtbo.img $DIR/update/InfernoKernel_$DEVICE-$OS-$DATE_NAME.zip $TOOLCHAINS $FILE
}

config() {
  cd $DIR/kernel && make \
    O=$DIR/out \
    ARCH=$ARCH \
    SUBARCH=$ARCH \
    $(echo $DEVICE)_defconfig
}

menuconfig() {
  cd $DIR/out && make \
    ARCH=$ARCH \
    SUBARCH=$ARCH \
    menuconfig
}

update() {
  rm -rf $FILE && touch $FILE

  cp $DIR/out/arch/arm64/boot/Image.gz-dtb $DIR/boot/kernel
  cat $DIR/out/arch/arm64/boot/dts/qcom/*.dtb > $DIR/boot/dtb
  touch $DIR/boot/ramdisk

  cd $DIR/boot

  python2 $DIR/boot/bin/mkdtboimg.py create ./dtbo.img $DIR/out/arch/arm64/boot/dts/qcom/*.dtbo
  python3 $DIR/boot/bin/mkbootimg.py \
    --cmdline "console=ttyMSM0,115200n8 earlycon=msm_geni_serial,0xA90000 androidboot.hardware=qcom androidboot.console=ttyMSM0 video=vfb:640x400,bpp=32,memsize=3072000 msm_rtb.filter=0x237 ehci-hcd.park=3 lpm_levels.sleep_disabled=1 service_locator.enable=1 androidboot.configfs=true androidboot.usbcontroller=a600000.dwc3 swiotlb=1 loop.max_part=7 buildvariant=userdebug" \
    --kernel ./kernel \
    --ramdisk ./ramdisk \
    --dtb ./dtb \
    --base "0x00000000" \
    --kernel_offset "0x00008000" \
    --ramdisk_offset "0x00000000" \
    --second_offset "0x00000000" \
    --tags_offset "0x00000100" \
    --os_version $OS".0.0" \
    --os_patch_level $PATCH_LVL \
    --pagesize "4096" \
    --board "" \
    --header_version "0" \
  -o ./boot.img

  cp $DIR/boot/boot.img $DIR/update/boot.img
  cp $DIR/boot/dtbo.img $DIR/update/dtbo.img

  echo "ui_print(\"----------------------------------------------\");" > $FILE
  echo "ui_print(\"              Inferno Kernel\");" >> $FILE
  echo "ui_print(\"              by Zaharchenko\");" >> $FILE
  echo "ui_print(\"----------------------------------------------\");" >> $FILE
  echo "ui_print(\"   Device: $(echo $DEVICE)\");" >> $FILE
  echo "ui_print(\"   Android version: $(echo $OS)\");" >> $FILE
  echo "ui_print(\"   Kernel version: 4.9.280\");" >> $FILE
  echo "ui_print(\"   Build date: $(echo $PATCH_LVL)\");" >> $FILE
  echo "ui_print(\"----------------------------------------------\");" >> $FILE
  echo "ui_print(\"Patching boot image unconditionally...\");" >> $FILE
  echo "package_extract_file(\"boot.img\", \"/dev/block/bootdevice/by-name/boot\");" >> $FILE
  echo "ui_print(\"Patching dtbo image unconditionally...\");" >> $FILE
  echo "package_extract_file(\"dtbo.img\", \"/dev/block/bootdevice/by-name/dtbo\");" >> $FILE
  echo "set_progress(1.000000);" >> $FILE

  cd $DIR/update

  zip -r9 InfernoKernel_$DEVICE-$OS-$DATE_NAME.zip META-INF boot.img dtbo.img
}

clean() {
  rm -rf $DIR/boot $DIR/update/boot.img $DIR/update/dtbo.img $DIR/update/InfernoKernel_$DEVICE-$OS-$DATE_NAME.zip $TOLCHAINS $FILE
}

mrproper() {
  cd $DIR/kernel && make clean mrproper
  cd $DIR/out && make clean mrproper
}

download-linaro-gcc() {
  rm -rf $TOLCHAINS/linaro-gcc && mkdir -p $TOLCHAINS && cd $TOLCHAINS
  wget https://snapshots.linaro.org/gnu-toolchain/11.2-2021.12-1/aarch64-linux-gnu/gcc-linaro-11.2.1-2021.12-x86_64_aarch64-linux-gnu.tar.xz
  tar -xf gcc-linaro-11.2.1-2021.12-x86_64_aarch64-linux-gnu.tar.xz
  rm -rf  gcc-linaro-11.2.1-2021.12-x86_64_aarch64-linux-gnu.tar.xz
  mv gcc-linaro-11.2.1-2021.12-x86_64_aarch64-linux-gnu linaro-gcc
}

download-aosp-gcc() {
  rm -rf $TOLCHAINS/aosp-gcc && mkdir -p $TOLCHAINS/aosp-gcc && cd $TOLCHAINS/aosp-gcc
  wget https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/+archive/961622e926a1b21382dba4dd9fe0e5fb3ee5ab7c.tar.gz
  wget https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/+archive/cb7b3ac1b7fdb49474ff68761909934d1142f594.tar.gz
  tar -xf 961622e926a1b21382dba4dd9fe0e5fb3ee5ab7c.tar.gz
  tar -xf cb7b3ac1b7fdb49474ff68761909934d1142f594.tar.gz
  rm -rf 961622e926a1b21382dba4dd9fe0e5fb3ee5ab7c.tar.gz cb7b3ac1b7fdb49474ff68761909934d1142f594.tar.gz
}

download-aosp-clang() {
  rm -rf $TOLCHAINS/aosp-clang && mkdir -p $TOLCHAINS/aosp-clang && cd $TOLCHAINS/aosp-clang
  wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/master/clang-r437112.tar.gz
  wget https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/+archive/961622e926a1b21382dba4dd9fe0e5fb3ee5ab7c.tar.gz
  wget https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/+archive/cb7b3ac1b7fdb49474ff68761909934d1142f594.tar.gz

  tar -xf 961622e926a1b21382dba4dd9fe0e5fb3ee5ab7c.tar.gz
  tar -xf cb7b3ac1b7fdb49474ff68761909934d1142f594.tar.gz
  tar -xf clang-r437112.tar.gz
  rm -rf 961622e926a1b21382dba4dd9fe0e5fb3ee5ab7c.tar.gz clang-r437112.tar.gz cb7b3ac1b7fdb49474ff68761909934d1142f594.tar.gz
}

download-proton-clang() {
  rm -rf $TOLCHAINS/proton-clang && mkdir -p $TOLCHAINS && cd $TOLCHAINS
  git clone --depth=1 https://github.com/kdrag0n/proton-clang
}

build-linaro-gcc() {
  cd $DIR/out && make \
    ARCH=$ARCH \
    SUBARCH=$ARCH \
    CROSS_COMPILE=$TOLCHAINS"/linaro-gcc/bin/aarch64-linux-gnu-" \
    -j$(echo $PROCS)
}

build-aosp-gcc() {
  cd $DIR/out && make \
    ARCH=$ARCH \
    SUBARCH=$ARCH \
    CROSS_COMPILE=$TOLCHAINS"/aosp-gcc/bin/aarch64-linux-android-" \
    CROSS_COMPILE_ARM32=$TOLCHAINS"/aosp-gcc/bin/arm-linux-androideabi-" \
    -j$(echo $PROCS)
}

build-aosp-clang() {
  export CLANG_TRIPLE="aarch64-linux-gnu-"
  export PATH=$TOLCHAINS"/aosp-clang/bin":$PATH
  export LD_LIBRARY_PATH=$TOLCHAINS"/aosp-clang/lib64":$LD_LIBRARY_PATH

  cd $DIR/out && make \
    ARCH=$ARCH \
    SUBARCH=$ARCH \
    CROSS_COMPILE="aarch64-linux-android-" \
    CROSS_COMPILE_ARM32="arm-linux-androideabi-" \
    CC="clang" \
    AR="llvm-ar" \
    AS="llvm-as" \
    NM="llvm-nm" \
    OBJCOPY="llvm-objcopy" \
    OBJDUMP="llvm-objdump" \
    READELF="llvm-readelf" \
    OBJSIZE="llvm-size" \
    STRIP="llvm-strip" \
    -j$(echo $PROCS)
}

build-proton-clang() {
  export CLANG_TRIPLE="aarch64-linux-gnu-"
  export PATH=$TOLCHAINS"/proton-clang/bin":$PATH
  export LD_LIBRARY_PATH=$TOLCHAINS"/proton-clang/lib64":$LD_LIBRARY_PATH

  cd $DIR/out && make \
    ARCH=$ARCH \
    SUBARCH=$ARCH \
    CROSS_COMPILE="aarch64-linux-gnu-" \
    CROSS_COMPILE_ARM32="arm-linux-gnueabi-" \
    CC="clang" \
    AR="llvm-ar" \
    AS="llvm-as" \
    NM="llvm-nm" \
    OBJCOPY="llvm-objcopy" \
    OBJDUMP="llvm-objdump" \
    READELF="llvm-readelf" \
    OBJSIZE="llvm-size" \
    STRIP="llvm-strip" \
    -j$(echo $PROCS)
}

help() {
  echo "Usage: $0 [arg]"
  echo ""
  echo "  setup      - download required components"
  echo "  config     - run device configuration"
  echo "  menuconfig - run 'menuconfig' for editing"
  echo "  update     - create flashable file .zip"
  echo "  clean      - delete files created by script"
  echo "  mrproper   - clear kernel source and 'out'"
  echo ""
  echo "  download-linaro-gcc   - download linaro (GCC)"
  echo "  download-aosp-gcc     - download aosp (GCC)"
  echo "  download-aosp-clang   - download aosp llvm (clang)"
  echo "  download-proton-clang - download proton (clang)"
  echo ""
  echo "  build-linaro-gcc   - start building with linaro (GCC)"
  echo "  build-aosp-gcc     - start building with aosp (GCC)"
  echo "  build-aosp-clang   - start building with aosp llvm (clang)"
  echo "  build-proton-clang - start building with proton (clang)"
}

case "$1" in
  clean )
    clean
    ;;
  mrproper )
    mrproper
    ;;
  config )
    config
    ;;
  menuconfig )
    menuconfig
    ;;
  setup )
    setup
    ;;
  update )
    update
    ;;
  download-linaro-gcc )
    download-linaro-gcc
    ;;
  download-aosp-gcc )
    download-aosp-gcc
    ;;
  download-aosp-clang )
    download-aosp-clang
    ;;
  download-proton-clang )
    download-proton-clang
    ;;
  build-linaro-gcc )
    build-linaro-gcc
    ;;
  build-aosp-gcc )
    build-aosp-gcc
    ;;
  build-aosp-clang )
    build-aosp-clang
    ;;
  build-proton-clang )
    build-proton-clang
    ;;
  * )
    help
    ;;
esac
