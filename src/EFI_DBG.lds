OUTPUT_FORMAT(elf64-x86-64)
OUTPUT_ARCH(i386:x86-64)

ENTRY(_start)
BASE_ADDRESS = 0x0;
SECTIONS
{
	.text BASE_ADDRESS : {
		*(.text)
		. = ALIGN(0X10);
	}
	.data : ALIGN(0x10) {
		*(.data)
		*(.data.*)
	}
	.debug_info 0 : { *(.debug_info) }
	.debug_abbrev 0 : { *(.debug_abbrev) }
	.debug_loc 0 : { *(.debug_loc) }
	.debug_aranges 0 : { *(.debug_aranges) }
	.debug_line 0 : { *(.debug_line) }
	.debug_str 0 : { *(.debug_str) }
	.debug_ranges 0 : { *(.debug_ranges) }
	.debug_frame 0 : { *(.debug_frame) }
}
