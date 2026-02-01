#!/bin/bash

PROJECT_DIR=$(cd "$(dirname "$0")" && pwd)
CONFIG_FILE="$PROJECT_DIR/Config.sh"
EXIT_CODE=0

# Check existing config file
if [ ! -f "$CONFIG_FILE" ]; then
	echo "ERROR: '$CONFIG_FILE' not found."
	exit 1
fi

# Include config
source $CONFIG_FILE

# Check folders
if [ ! -d "$PROJECT_DIR$TMP_DIR" ]; then mkdir -p "$PROJECT_DIR$TMP_DIR"; fi
if [ ! -d "$PROJECT_DIR$MNT_DIR" ]; then mkdir -p "$PROJECT_DIR$MNT_DIR"; fi
if [ ! -d "$PROJECT_DIR$OUT_DIR/EFI/BOOT" ]; then mkdir -p "$PROJECT_DIR$OUT_DIR/EFI/BOOT"; fi

# Build BOOTX64.EFI
if [ "$BOOTX64_EFI_BUILD_MODE" -eq 0 ]; then
	echo "Build: BOOTX64.EFI ..."
	"$NASM_BIN" "$PROJECT_DIR$BOOTX64_EFI_SRC_FILE" -o "$PROJECT_DIR$BOOTX64_EFI_OUT_FILE"
	EXIT_CODE=$?
	if [ "$EXIT_CODE" -eq 0 ]; then 
		"$PROJECT_DIR$CHECKSUM_LOCAL_BIN" "$PROJECT_DIR$BOOTX64_EFI_OUT_FILE"
		EXIT_CODE=$?
		if [ "$EXIT_CODE" -eq 0 ]; then 
			echo "Success." 
		fi
	fi
fi

# Build DEBUG BOOTX64.EFI
if [ "$BOOTX64_EFI_BUILD_MODE" -eq 1 ]; then
	echo "Build: Debug BOOTX64.ELF ..."
	"$NASM_BIN" -f elf64 $BOOTX64_DBG_FLAGS "$PROJECT_DIR$BOOTX64_DBG_ELF_SRC_FILE" -o "$PROJECT_DIR$BOOTX64_DBG_O_TMP_FILE"
	EXIT_CODE=$?
	if [ "$EXIT_CODE" -eq 0 ]; then 
		"$LD_BIN" -T "$PROJECT_DIR$BOOTX64_DBG_LD_SCRIPT" -o "$PROJECT_DIR$BOOTX64_DBG_ELF_TMP_FILE"
		EXIT_CODE=$?
		if [ "$EXIT_CODE" -eq 0 ]; then
			"$OBJCOPY_BIN" -j .text -j data --target=efi-app-x86-64 "$PROJECT_DIR$BOOTX64_DBG_ELF_TMP_FILE" -O "$PROJECT_DIR$BOOTX64_EFI_OUT_FILE"
			EXIT_CODE=$?
			if [ "$EXIT_CODE" -eq 0 ]; then
				echo "Success." 
			fi
		fi
		
	fi
fi

# Create .img file
if [ "$ENABLE_CREATE_IMG_FILE" -eq 1 ]; then
	dd if=/dev/zero of=$IMAGE_NAME bs=1024 count=$IMAGE_SIZE
	mkfs.vfat $IMAGE_NAME
	if grep -qs "$PROJECT_DIR$MNT_DIR" /proc/mounts; 
	then sudo umount "$PROJECT_DIR$MNT_DIR"; fi
	sudo mount "$IMAGE_NAME" "$PROJECT_DIR$MNT_DIR"
	sudo cp -rf $PROJECT_DIR$OUT_DIR/* "$PROJECT_DIR$MNT_DIR/"
	sudo umount "$PROJECT_DIR$MNT_DIR"
	rm -rf "$PROJECT_DIR$MNT_DIR"
fi


#sudo apt install genisoimage
#sudo apt install xorriso
#genisoimage -o MyOS.iso -R -J -eltorito-alt-boot -no-emul-boot -efi-boot EFI/BOOT/BOOTX64.EFI Out
#xorriso -as mkisofs -o MyOS.iso -isohybrid-mbr /usr/lib/syslinux/mbr/gptmbr.bin -c boot.catalog -b EFI/boot/bootx64.efi -no-emul-boot -eltorito-alt-boot -e EFI/boot/bootx64.efi -no-emul-boot -isohybrid-gpt-basdat Out

##
# qemu-system-x86_64 -drive if=pflash,format=raw,readonly=on,file=/usr/share/ovmf/OVMF.fd -hda OS.img -enable-kvm -m 512 -serial stdio -gdb tcp::1111,wait -S -serial tcp::2222,server,nowait
# qemu-system-x86_64 -drive if=pflash,format=raw,readonly=on,file=/usr/share/ovmf/OVMF.fd -hda OS.img -enable-kvm -m 512
# nc localhost 2222
# gdb
# target remote localhost:1111
