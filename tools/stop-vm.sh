#!/bin/sh
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021 Carles Pey <cpey@pm.me>

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -r|--reboot)
            start=1
            shift
            ;;
        -f|--force)
            force=1
            shift
            ;;
        *)
            echo "Unrecognized option: $key"
            exit 1
            ;;
    esac
done

TOOLS_DIR=$(echo $0 | sed  "s/\(.*\)\(\/.*\)/\1/g")
source $TOOLS_DIR/config.sh

if [[ $force -eq 1 ]]; then
    pid=$(ps aux | grep -E "[q]emu-system-x86_64.*rootfs/$ROOTFS_IMG" | awk '{print $2}')
    if [[ -n $pid ]]; then
        kill $pid
    fi
else
    ssh $VM_HOSTNAME "sudo /usr/sbin/shutdown -h now"
    if [[ $start -eq 1 ]]; then
        sleep 5
    fi
fi

if [[ $start -eq 1 ]]; then
    $TOOLS_DIR/start-vm.sh
fi
