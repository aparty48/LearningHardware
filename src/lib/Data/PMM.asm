; Memory data ----------------------------------------------------------------------
PMM_Mes_1:                             db "os can work with defalut (1 version) descriptor version EFI only, current version: ", 0
PMM_Mes_2:                             db "os can work with (48 bit) descriptor size EFI only, current size: ", 0
PMM_Mes_3:                             db 13, 10, 0
PMM_Mes_4:                             db " ", 0
PMM_Address_Map                        dq 0
PMM_Count_Descriptors                  dq 0
PMM_Size_Map_In_Pages                  dq 0

; Constants ---------------------------------------------------------------

;---------------------------------------------------------------------------------------
; Версия 1 карты PMM:
; Карта это масив дкскрипторов
; PMM descriptor structure -------------------------------------------------
; 8 bytes - Physical start address
; 8 bytes - Number of pages
; 4 bytes - Type

; EFI descriptor structure ------------------------------------------------
; 48 byte efi mem map descriptor:
; 4 bytes - type
; 4 bytes - empety, padding, align
; 8 bytes - Physical start address
; 8 bytes - Virtual start address
; 8 bytes - Number of pages
; 8 bytes - Attribute
; 8 bytes - empety, padding, align

; PMM Types of descriptors ------------------------------------------------
PMMReservedMemoryType     equ 0   ; cant use
;                          equ 1   ; can use
;                          equ 2   ; can use
;                          equ 3   ; can use
;                          equ 4   ; can use
PMMRuntimeServicesCode    equ 5   ; cant use
PMMRuntimeServicesData    equ 6   ; cant use
PMMConventionalMemory     equ 7   ; can use
PMMUnusableMemory         equ 8   ; cant use
PMMACPIReclaimMemory      equ 9   ; can use, after init ACPI
PMMACPIMemoryNVS          equ 10  ; cant use
PMMMemoryMappedIO         equ 11  ; cant use, as default memory

; EFI desc attributes ------------------------------------------------
EFI_MEMORY_UC             equ 0x1                   ;Uncacheable
EFI_MEMORY_WC             equ 0x2                   ;Write coalescing
EFI_MEMORY_WT             equ 0x4                   ;Write through
EFI_MEMORY_WB             equ 0x8                   ;Write back
EFI_MEMORY_WP             equ 0x1000                ;Write protect
EFI_MEMORY_RP             equ 0x2000                ;Read protect
EFI_MEMORY_XP             equ 0x4000                ;No execute
EFI_MEMORY_RUNTIME        equ 0x8000000000000000 

; EFI Types of descriptors ------------------------------------------------
EfiReservedMemoryType     equ 0   ; cant use
EfiLoaderCode             equ 1   ; can use
EfiLoaderData             equ 2   ; can use
EfiBootServicesCode       equ 3   ; can use
EfiBootServicesData       equ 4   ; can use
EfiRuntimeServicesCode    equ 5   ; cant use
EfiRuntimeServicesData    equ 6   ; cant use
EfiConventionalMemory     equ 7   ; can use
EfiUnusableMemory         equ 8   ; cant use
EfiACPIReclaimMemory      equ 9   ; can use, after init ACPI
EfiACPIMemoryNVS          equ 10  ; cant use
EfiMemoryMappedIO         equ 11  ; cant use, as default memory


