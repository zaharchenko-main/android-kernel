## building any android kernel

    git clone --depth=1 https://github.com/zaharchenko-main/android-kernel
    cd android-kernel && ./setup.sh
    git clone --depth=1 https://github.com/zaharchenko-main/kernel_lenovo_jd2019 kernel
    ./config.sh
    ./build.sh
    ./mkboot.sh
