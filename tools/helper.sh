#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021 Carles Pey <cpey@pm.me>

function trap_ctrlc ()
{
    echo "Exiting..."
    exit 130
}
trap "trap_ctrlc" 2

