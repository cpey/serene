#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021 Carles Pey <cpey@pm.me>

positional=()
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -l|--linux-src)
            srctree="$2"
            shift
            shift
            ;;
        -m|--module-path)
            module="$2"
            shift
            shift
            ;;
        -o|--output)
            output="$2"
            shift
            shift
            ;;
        *)
            positional+=("$1")
            shift
            ;;
    esac
done

if [[ -n ${positional[0]} ]]; then
    stacktrace=${positional[0]}
else
    echo "Missing stacktrace"
    exit 1;
fi

if [[ -n $srctree ]]; then
    LINUX_SRC=$srctree
else
    echo "Missing Linux source tree"
    exit 1;
fi

if [[ -n $module ]]; then
    MODULE_PATH=$module
else
    MODULE_PATH=''
fi

if [[ -n $output ]]; then
    exec 1>$output
fi

$LINUX_SRC/scripts/decode_stacktrace.sh \
    $LINUX_SRC/vmlinux $LINUX_SRC $MODULE_PATH < $stacktrace

