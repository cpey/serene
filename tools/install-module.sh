#!/bin/sh

MODULE=$1
DEVICE=$2

if [[ ! -n $MODULE ]]; then
    echo "Please specify the module you wish to install"
    exit 1
fi

ssh test "sudo insmod $MODULE"

if [[ -n $DEVICE ]]; then
    ssh test "sudo chmod 666 $DEVICE"
fi
