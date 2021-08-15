#!/bin/sh
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021 Carles Pey <cpey@pm.me>

# Optional arguments:
#  ./start-vm.sh -c smep
#  ./start-vm.sh -c smap
#  ./start-vm.sh -c smep,smap
#  ./start-vm.sh -k kpti=1
#  ./start-vm.sh -k kaslr
#  ./start-vm.sh -k kpti=1,kaslr
#  ./start-vm.sh -c smep,smap -k kpti=1,kaslr

TOOLS_DIR=$(echo $0 | sed  "s/\(.*\)\(\/.*\)/\1/g")
source $TOOLS_DIR/config.sh
KERNEL_BUILD=$TOOLS_DIR/../build/linux/arch/x86_64/boot/bzImage 
ROOTFS=$TOOLS_DIR/../rootfs/$ROOTFS_IMG

CPU="kvm64"
CMD_LINE="root=/dev/sda rw console=ttyS0"

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    -c|--cpu-sec)
    MITIGATION="$2"
    CPU=$CPU,$MITIGATION
    shift # past argument
    shift # past value
    ;;
    -k|--kernel-sec)
    MITIGATION=`echo "$2" | sed "s/,/ /g"`
    CMD_LINE="$CMD_LINE $MITIGATION"
    shift # past argument
    shift # past value
    ;;
    --default)
    DEFAULT=YES
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done

qemu-system-x86_64 \
    -kernel $KERNEL_BUILD \
    -cpu $CPU \
    -drive file=$ROOTFS,index=0,media=disk,format=raw \
    -enable-kvm \
    -append "$CMD_LINE" \
    -nographic \
    -netdev user,id=net0,hostfwd=tcp::$VM_PORT-:22 \
    -device e1000,netdev=net0 &
