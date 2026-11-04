#!/usr/bin/env bash

set -e;

FNAME='sleep';
BUILD_PATH='build';

EXEC_FILE="$BUILD_PATH/$FNAME";

qemu-riscv64 $EXEC_FILE $@;
