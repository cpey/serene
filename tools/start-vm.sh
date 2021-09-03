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
source $TOOLS_DIR/helper.sh

CPU="kvm64"
CMD_LINE="root=/dev/sda rw console=ttyS0"

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -c|--cpu-sec)
            MITIGATION="$2"
            CPU=$CPU,$MITIGATION
            shift
            shift
            ;;
        -k|--kernel-sec)
            MITIGATION=`echo "$2" | sed "s/,/ /g"`
            CMD_LINE="$CMD_LINE $MITIGATION"
            shift
            shift
            ;;
        -d|--debug)
            DEBUG=1
            shift
            ;;
        -w|--wait-debug)
            WAIT_DEBUG=1
            shift
            ;;
        -l|--linux-src)
            srctree="$2"
            shift
            shift
            ;;
        *)
            echo "Unrecognized option: $key"
            exit 1
            ;;
    esac
done

if [[ -n $srctree ]]; then
    LINUX_SRC=$srctree
else
    LINUX_SRC=$TOOLS_DIR/../src/linux
fi
LINUX_SRC_HASH=$(get_path_hash $LINUX_SRC)
KERNEL_BUILD=$TOOLS_DIR/../build/linux/arch/x86_64/boot/bzImage-$LINUX_SRC_HASH
ROOTFS=$TOOLS_DIR/../rootfs/$ROOTFS_IMG

DEBUG_OPTS=''
if (( $DEBUG )); then
    DEBUG_OPTS+="-serial tcp::1234,server,nowait"
    CMD_LINE+="console=ttyS0,115200 kgdboc=ttyS0,115200"
    if (( $WAIT_DEBUG )); then
        CMD_LINE+="console=ttyS0,115200 kgdboc=ttyS0,115200 kgdbwait"
    fi
fi

qemu-system-x86_64 \
    $DEBUG_OPTS \
    -kernel $KERNEL_BUILD \
    -cpu $CPU \
    -drive file=$ROOTFS,index=0,media=disk,format=raw \
    -enable-kvm \
    -append "$CMD_LINE" \
    -nographic \
    -netdev user,id=net0,hostfwd=tcp::$VM_PORT-:22 \
    -device e1000,netdev=net0

