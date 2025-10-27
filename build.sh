#!/bin/bash

SCRIPT_DIR=$(dirname "$0")
cd "$SCRIPT_DIR"

nasm src/BOOTX64.asm -o out/EFI/BOOT/BOOTX64.EFI
#nasm -f elf64 -g -F dwarf -o temp/Debug.o src/BOOTX64_DBG.asm
#ld -T src/EFI_DBG.lds -o out/BOOTX64_DBG.elf temp/Debug.o
#objcopy -j .text -j .data --target=pei-x86-64 "temp/BOOTX64_DBG.elf" -O "out/EFI/BOOT/BOOTX64.EFI"
utils/checksumpe out/EFI/BOOT/BOOTX64.EFI

#sudo apt install genisoimage
#sudo apt install xorriso
#genisoimage -o MyOS.iso -R -J -eltorito-alt-boot -no-emul-boot -efi-boot EFI/BOOT/BOOTX64.EFI Out
#xorriso -as mkisofs -o MyOS.iso -isohybrid-mbr /usr/lib/syslinux/mbr/gptmbr.bin -c boot.catalog -b EFI/boot/bootx64.efi -no-emul-boot -eltorito-alt-boot -e EFI/boot/bootx64.efi -no-emul-boot -isohybrid-gpt-basdat Out
dd if=/dev/zero of=OS.img bs=1024 count=100
mkfs.vfat OS.img
if grep -qs "/mnt" /proc/mounts; 
then sudo umount /mnt; fi
sudo mount OS.img /mnt
sudo cp -rf out/* /mnt/
sudo umount /mnt

##
# qemu-system-x86_64 -drive if=pflash,format=raw,readonly=on,file=/usr/share/ovmf/OVMF.fd -hda out/MyOS.img -enable-kvm -m 512 -serial stdio -gdb tcp::1111
# qemu-system-x86_64 -drive if=pflash,format=raw,readonly=on,file=/usr/share/ovmf/OVMF.fd -cdrom MyOS.iso -gdb tcp::1111 -S
# gdb
# target remote localhost:1111
##
