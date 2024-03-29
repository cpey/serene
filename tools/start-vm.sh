#!/bin/bash
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
RAM=512M
CMD_LINE="root=/dev/sda rw console=ttyS0 no_hash_pointers kasan_multi_shot"

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -c|--cpu-sec)
            MITIGATION="$2"
            CPU=$CPU,$MITIGATION
            shift
            shift
            ;;
        -d|--debug)
            DEBUG=1
            shift
            ;;
        -e|--extra)
            EXTRA="$2"
            shift
            shift
            ;;
        -k|--kernel-sec)
            MITIGATION=`echo "$2" | sed "s/,/ /g"`
            CMD_LINE="$CMD_LINE $MITIGATION"
            shift
            shift
            ;;
        -l|--linux-src)
            srctree="$2"
            shift
            shift
            ;;
        -n|--kernel-name)
            suffix="$2"
            shift
            shift
            ;;
        -q|--qemu-bin)
            QEMU="$2"
            shift
            shift
            ;;
        -r|--root-fs)
            rootfs="$2"
            shift
            shift
            ;;
        -w|--wait-debug)
            WAIT_DEBUG=1
            shift
            ;;
        *)
            echo "Unrecognized option: $key"
            exit 1
            ;;
    esac
done

if [[ ! -n $srctree ]]; then
    srctree=$TOOLS_DIR/../src/linux
fi

if [[ ! -n $suffix ]]; then
    suffix=$(get_path_hash $srctree)
fi

if [[ ! -n $rootfs ]]; then
    rootfs=$TOOLS_DIR/../rootfs/$ROOTFS_IMG
fi

if [[ ! -n $QEMU ]]; then
    QEMU=qemu-system-x86_64
fi

KERNEL_BUILD=$TOOLS_DIR/../build/linux/arch/x86_64/boot/bzImage-$suffix

DEBUG_OPTS=''
KVM_OPTS=''
if (( $DEBUG )); then
    DEBUG_OPTS+="-serial tcp::1234,server,nowait -smp 1"
    CMD_LINE+=" kgdboc=ttyS0,115200 nokaslr"
    if (( $WAIT_DEBUG )); then
        CMD_LINE+=" kgdbwait"
    fi
else
    KVM_OPTS="-enable-kvm"
fi
echo Booting $KERNEL_BUILD
$QEMU \
    $DEBUG_OPTS \
    $KVM_OPTS \
    -kernel $KERNEL_BUILD \
    -m $RAM \
    -cpu $CPU \
    -drive file=$rootfs,index=0,media=disk,format=raw \
    -append "$CMD_LINE -device vhost-vsock-pci,guest-cid=" \
    -nographic \
    -netdev user,id=net0,hostfwd=tcp::$VM_PORT-:22 \
    -device e1000,netdev=net0 \
    ${EXTRA}

