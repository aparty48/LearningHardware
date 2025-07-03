#!/bin/bash

SCRIPT_DIR=$(dirname "$0")
cd "$SCRIPT_DIR"

nasm Main.asm -o BOOTX64.EFI 
