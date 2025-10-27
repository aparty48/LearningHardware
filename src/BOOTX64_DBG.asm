Bits 64
DEFAULT REL

global _start

section .text align=16
_start:
	%include "src/EFI_Code.asm"

section .data align=16
	%include "src/EFI_Data.asm"
