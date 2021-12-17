#!/usr/bin/env bash



OS="12"

ARCH="arm64"

DEVICE="jd2019"

PROC="$(nproc --all)"

DATE_NAME="$(date +%Y%m%d)"

PATCH_LVL="$(date +%Y-%m-%d)"

DIR="$(cd "$(dirname "$0")" && pwd)"

CROSS_COMPILE=$DIR"/gcc/bin/aarch64-linux-gnu-"



setup() {
  mkdir -p $DIR/boot/bin

  sudo apt install clang wget build-essential \
    bc flex git bison gcc-aarch64-linux-gnu \
    gcc-arm-linux-gnueabihf libncurses6 lzip \
    zip unzip git wget gcc g++ libncurses5-dev  \
    xz-utils libncurses6 python3 python2 -y

  cd $DIR

  wget https://snapshots.linaro.org/gnu-toolchain/11.2-2021.12-1/aarch64-linux-gnu/gcc-linaro-11.2.1-2021.12-x86_64_aarch64-linux-gnu.tar.xz
  tar -xf gcc-linaro-11.2.1-2021.12-x86_64_aarch64-linux-gnu.tar.xz
  rm -rf  gcc-linaro-11.2.1-2021.12-x86_64_aarch64-linux-gnu.tar.xz
  mv gcc-linaro-11.2.1-2021.12-x86_64_aarch64-linux-gnu gcc

  cd $DIR/boot/bin

  wget https://android.googlesource.com/platform/system/tools/mkbootimg/+archive/refs/heads/master.tar.gz
  wget https://android.googlesource.com/platform/system/libufdt/+archive/refs/heads/master/utils/src.tar.gz

  tar -xf master.tar.gz
  tar -xf src.tar.gz

  rm -rf master.tar.gz src.tar.gz
}

clean() {
  rm -rf $DIR/boot $DIR/update/boot.img $DIR/update/dtbo.img $DIR/update/InfernoKernel_$DEVICE-$OS-$DATE_NAME.zip $DIR/gcc
}

mrproper() {
  cd $DIR/kernel && make clean mrproper
  cd $DIR/out && make clean mrproper
}

config() {
  cd $DIR/kernel && make \
    O=$DIR/out \
    ARCH=$ARCH \
    CROSS_COMPILE=$CROSS_COMPILE \
    $(echo $DEVICE)_defconfig
}

menuconfig() {
  cd $DIR/kernel && make \
    O=$DIR/out \
    ARCH=$ARCH \
    CROSS_COMPILE=$CROSS_COMPILE \
    menuconfig
}

build() {
  cd $DIR/out && make \
    ARCH=$ARCH \
    CROSS_COMPILE=$CROSS_COMPILE \
    -j$(echo $PROC)
}

update() {
  FILE=$DIR/update/META-INF/com/google/android/updater-script
  touch $FILE

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

help() {
  echo "Usage: $0 [arg]"
  echo ""
  echo "  setup      - download required components"
  echo "  config     - run device configuration"
  echo "  menuconfig - run 'menuconfig' for editing"
  echo "  build      - start build"
  echo "  update     - create flashable file .zip"
  echo "  clean      - delete files created by script"
  echo "  mrproper   - clear kernel source and 'out'"
  echo "  * help     - show this message"
  echo ""
  echo "  download-linaro-gcc -       "
  echo "  download-aosp-gcc   -       "
  echo "  download-aosp-clang -       "
  echo ""
  echo "  config-linaro-gcc   -       "
  echo "  config-aosp-gcc     -       "
  echo "  config-aosp-clang   -       "
  echo ""
  echo "  build-linaro-gcc    -       "
  echo "  build-aosp-gcc      -       "
  echo "  build-aosp-clang    -       "
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
  build )
    build
    ;;
  setup )
    setup
    ;;
  update )
    update
    ;;
  * )
    help
    ;;
esac
