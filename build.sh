#!/bin/bash
set -e

SCRIPT_DIR=$(dirname "$0")
cd "$SCRIPT_DIR"

nasm Main.asm -o BOOTX64.EFI 
Utils/checksumpe BOOTX64.EFI
