#!/bin/bash

###################### CONFIG ######################

# root directory of Kernel git repo (default is this script's location)
RDIR=$(pwd)

# directory containing cross-compile arm64 toolchain
TOOLCHAIN=/home/zero/toolchains/aarch64-linux-android-4.9

[ -z $PERMISSIVE ] && \
# should we boot with SELinux mode set to permissive? (1 = permissive, 0 = enforcing)
PERMISSIVE=2

OUT_NAME=ZeroKernel-mkIII

############## SCARY NO-TOUCHY STUFF ###############

export ARCH=arm64
export SUBARCH=arm64
export HEADER_ARCH=arm64
export CROSS_COMPILE=$TOOLCHAIN/bin/aarch64-linux-android-
export PATH=/home/zero/toolchains/aarch64-linux-android-4.9/bin:$PATH

if ! [ -f $RDIR"/arch/arm64/configs/zero_defconfig" ] ; then
	echo "zero_defconfig not found in arm64 configs!"
	exit -1
fi

[ $PERMISSIVE -eq 1 ] && SELINUX="never_enforce" || SELINUX="always_enforce"

KDIR=$RDIR/build/arch/arm/boot

CLEAN_BUILD()
{
	echo "Cleaning build..."
	cd $RDIR
	rm -rf build
}

BUILD_KERNEL()
{
	echo "Creating kernel config..."
	cd $RDIR
	mkdir -p build
	make -C $RDIR O=build zero_defconfig
	POST_DEFCONFIG_CMDS="check_defconfig"
	echo "Starting build..."
	make -C $RDIR O=build -j$(nproc --all)
}

DO_BUILD()
{
	echo "Starting build for $OUT_NAME, SELINUX = $SELINUX..."
	CLEAN_BUILD && BUILD_KERNEL || {
		echo "Error!"
		exit -1
	}
}

DO_BUILD
