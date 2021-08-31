#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021 Carles Pey <cpey@pm.me>

function trap_ctrlc ()
{
    echo "Exiting..."
    exit 130
}
trap "trap_ctrlc" 2

function get_path_hash ()
{
    local path=$(realpath $1)
    local str=$(echo $path | sha256sum | cut -c1-16)
    echo $str
}
