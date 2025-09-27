Bits 64
DEFAULT REL

START:
PE:
HEADER_START:
STANDARD_HEADER:
    .DOS_SIGNATURE              db 'MZ'                                                             ; The DOS signature. This is apparently compulsory
    .DOS_HEADERS                times 60-($-STANDARD_HEADER) db 0                                   ; The DOS Headers. Probably not needed by UEFI
    .SIGNATURE_POINTER          dd .PE_SIGNATURE - START                                            ; Pointer to the PE Signature
    .DOS_STUB                   times 64 db 0                                                       ; The DOS stub. Fill with zeros
    .PE_SIGNATURE               dd 'PE'                                                             ; This is the pe signature. The characters 'PE' followed by 2 null bytes
    .MACHINE_TYPE               dw 0x8664                                                           ; Targetting the x64 machine
    .NUMBER_OF_SECTIONS         dw 2                                                                ; Number of sections. Indicates size of section table that immediately follows the headers
    .CREATED_DATE_TIME          dd 1754463360                                                       ; Number of seconds since 1970 since when the file was created
    .SYMBOL_TABLE_POINTER       dd 0x00                                                             ; Pointer to the symbol table. There should be no symbol table in an image so this is 0
    .NUMBER_OF_SYMBOLS          dd 0x00                                                             ; Because there are no symbol tables in an image
    .OPTIONAL_HEADER_SIZE       dw OPTIONAL_HEADER_STOP - OPTIONAL_HEADER_START                     ; Size of the optional header
    .CHARACTERISTICS            dw 0b0010111000100010                                               ; These are the attributes of the file

OPTIONAL_HEADER_START:
    .MAGIC_NUMBER               dw 0x020B                       ; PE32+ (i.e. pe64) magic number
    .MAJOR_LINKER_VERSION       db 0                            ; I'm sure this isn't needed. So set to 0
    .MINOR_LINKER_VERSION       db 0                            ; This too
    .SIZE_OF_CODE               dd CODE_END - CODE              ; The size of the code section
    .INITIALIZED_DATA_SIZE      dd FILE_DATA_SECTIONS_COUNT * FILE_ALIGNMENT              ; Size of initialized data section
    .UNINITIALIZED_DATA_SIZE    dd 0x00                         ; Size of uninitialized data section
    .ENTRY_POINT_ADDRESS        dd EntryPoint                   ; Address of entry point relative to image base when the image is loaded in memory
    .BASE_OF_CODE_ADDRESS       dd CODE_RVA                     ; Relative address of base of code
    .IMAGE_BASE                 dq 0x40000                      ; Where in memory we would prefer the image to be loaded at
    .SECTION_ALIGNMENT          dd SECTION_ALIGNMENT            ; Alignment in bytes of sections when they are loaded in memory. Align to page boundry (4kb)
    .FILE_ALIGNMENT             dd FILE_ALIGNMENT               ; Alignment of sections in the file. Also align to 512 byte
    .MAJOR_OS_VERSION           dw 0x00                         ; I'm not sure UEFI requires these and the following 'version woo'
    .MINOR_OS_VERSION           dw 0x00                         ; More of these version thingies are to follow. Again, not sure UEFI needs them
    .MAJOR_IMAGE_VERSION        dw 0x00                         ; Major version of the image
    .MINOR_IMAGE_VERSION        dw 0x00                         ; Minor version of the image
    .MAJOR_SUBSYSTEM_VERSION    dw 0x00                         ; 
    .MINOR_SUBSYSTEM_VERSION    dw 0x00                         ;
    .WIN32_VERSION_VALUE        dd 0x00                         ; Reserved, must be 0
    .IMAGE_SIZE                 dd DATA_RVA + (SECTION_ALIGNMENT * ((FILE_DATA_SIZE + SECTION_ALIGNMENT - 1) / SECTION_ALIGNMENT))   ; The size in bytes of the image when loaded in memory including all headers
    .HEADERS_SIZE               dd HEADER_END - HEADER_START    ; Size of all the headers
    .CHECKSUM                   dd 0x00                         ; Hoping this doesn't break the application
    .SUBSYSTEM                  dw 10                           ; The subsystem. In this case we're making a UEFI application.
    .DLL_CHARACTERISTICS        dw 0b000011111010000            ; I honestly don't know what to put here
    .STACK_RESERVE_SIZE         dq 0x200000                     ; Reserve 2MB for the stack... I guess...
    .STACK_COMMIT_SIZE          dq 0x1000                       ; Commit 4kb of the stack
    .HEAP_RESERVE_SIZE          dq 0x200000                     ; Reserve 2MB for the heap... I think... :D
    .HEAP_COMMIT_SIZE           dq 0x1000                       ; Commit 4kb of heap
    .LOADER_FLAGS               dd 0x00                         ; Reserved, must be zero
    .NUMBER_OF_RVA_AND_SIZES    dd 0x10                         ; Number of entries in the data directory

    DATA_DIRECTORIES:
        EDATA:
            .address            dd 0                                        ; Address of export table
            .size               dd 0                                        ; Size of export table
        IDATA:
            .address            dd 0                                        ; Address of import table
            .size               dd 0                                        ; Size of import table
        RSRC:
            .address            dd 0                                        ; Address of resource table
            .size               dd 0                                        ; Size of resource table
        PDATA:
            .address            dd 0                                        ; Address of exception table
            .size               dd 0                                        ; Size of exception table
        CERT:
            .address            dd 0                                        ; Address of certificate table
            .size               dd 0                                        ; Size of certificate table
        RELOC:
            .address            dd 0 ;RELOC_RVA                             ; Address of relocation table
            .size               dd 0 ;4096                                  ; Size of relocation table
        DEBUG:
            .address            dd 0                                        ; Address of debug table
            .size               dd 0                                        ; Size of debug table
        ARCHITECTURE:
            .address            dd 0                                        ; Reserved. Must be 0
            .size               dd 0                                        ; Reserved. Must be 0
        GLOBALPTR:
            .address            dd 0                                        ; RVA to be stored in global pointer register
            .size               dd 0                                        ; Must be 0
        TLS:
            .address            dd 0                                        ; Address of TLS table
            .size               dd 0                                        ; Size of TLS table
        LOADCONFIG:
            .address            dd 0                                        ; Address of Load Config table
            .size               dd 0                                        ; Size of Load Config table
        BOUNDIMPORT:
            .address            dd 0                                        ; Address of bound import table
            .size               dd 0                                        ; Size of bound import table
        IAT:
            .address            dd 0                                        ; Address of IAT
            .size               dd 0                                        ; Size of IAT
        DELAYIMPORTDESCRIPTOR:
            .address            dd 0                                        ; Address of delay import descriptor
            .size               dd 0                                        ; Size of delay import descriptor
        CLRRUNTIMEHEADER:
            .address            dd 0                                        ; Address of CLR runtime header
            .size               dd 0                                        ; Size of CLR runtime header
        RESERVED:
            .address            dd 0                                        ; Reserved, must be 0
            .size               dd 0                                        ; Reserved, must be 0

OPTIONAL_HEADER_STOP:

SECTION_HEADERS:
    SECTION_CODE:
        .name                       db ".text", 0x00, 0x00, 0x00
        .virtual_size               dd CODE_END - CODE
        .virtual_address            dd CODE_RVA
        .size_of_raw_data           dd FILE_CODE_SECTIONS_COUNT * FILE_ALIGNMENT
        .pointer_to_raw_data        dd CODE - START
        .pointer_to_relocations     dd 0                ; Set to 0 for executable images
        .pointer_to_line_numbers    dd 0                ; There are no COFF line numbers
        .number_of_relocations      dw 0                ; Set to 0 for executable images
        .number_of_line_numbers     dw 0                ; Should be 0 for images
        .characteristics            dd 0x70000020       ; Need to read up more on this

    SECTION_DATA:
        .name                       db ".data", 0x00, 0x00, 0x00
        .virtual_size               dd DATA_END - DATA
        .virtual_address            dd DATA_RVA
        .size_of_raw_data           dd FILE_DATA_SECTIONS_COUNT * FILE_ALIGNMENT
        .pointer_to_raw_data        dd DATA - START
        .pointer_to_relocations     dd 0
        .pointer_to_line_numbers    dd 0
        .number_of_relocations      dw 0
        .number_of_line_numbers     dw 0
        .characteristics            dd 0xF0000040;0xD0000040

    ;SECTION_RELOC:
        ;.name                       db ".reloc", 0x00, 0x00
        ;.virtual_size               dd 4096
        ;.virtual_address            dd RELOC_RVA
        ;.size_of_raw_data           dd 4096
        ;.pointer_to_raw_data        dd END - START
        ;.pointer_to_relocations     dd 0
        ;.pointer_to_line_numbers    dd 0
        ;.number_of_relocations      dw 0
        ;.number_of_line_numbers     dw 0
        ;.characteristics            dd 0xC2000040 ;dd 0x42000040 ;

times 4096-($-PE)   db 0
HEADER_END:

CODE:
    ; The code begins here with the entry point
    EntryPoint:
        ; First order of business is to store the values that were passed to us by EFI
        mov [EFI_IMAGE_HANDLE], rcx                                     ;save image pointer
        mov [EFI_SYSTEM_TABLE], rdx                                     ;save system table
        
        sub rsp, 6*8+8                                                  ;shadow space in stack
        mov rax, [EFI_SYSTEM_TABLE]                                     ;get the EFI_SYSTEM_TABLE              
        mov rax, [rax + EFI_SYSTEM_TABLE_BOOTSERVICES]                  ;get the EFI_SYSTEM_TABLE.BootServices 
        mov [EFI_BOOTSERVICES], rax                                     ;save result
        
        lea rdx, [EFI_Start]
        call EFI_WriteText
        add rsp, 6*8+8
        
        call EFI_GetGraphicInterfase
        call EFI_Find_Set_Graphic_Mode
        mov rdx, [EFI_GOP_Mode]
        xor rbx, rbx
        mov ebx, [rdx + 0x4]
        call EFI_Query_Mode
        
        ; Move addresses from EFI data to DAE data
        mov rcx, [EFI_FB]
        mov [DAE_FrameBuffer], rcx
        mov rcx, [EFI_FBS]
        mov [DAE_FrameBufferSize], rcx

        mov ebx, 0xff4c8db0
        call DAE_FillDisplay
        
        mov rcx, [EFI_GOP_Mode_Info_Structure]
        xor rbx, rbx
        mov ebx, [rcx + 4]
        mov [DAE_Display_Heigth + 4], ebx
        mov ebx, [rcx + 8]
        mov [DAE_Display_Width + 4], ebx
        mov ebx, [rcx + 0x0C]
        mov [DAE_Display_PixelFormat], ebx
        mov ebx, [rcx + 0x10]
        mov [DAE_Display_PixelInfo], ebx
        mov ebx, [rcx + 0x14]
        mov [DAE_Display_PixelPerScanLine], ebx
        
        
        mov rcx, [EFI_GOP_Mode_Info_Structure]
        xor rax, rax
        mov eax, [rcx + 0x4]
        call DAE_Convert_DQ_To_HEX_Text
        lea rax, [DAE_HEX_Text]
        call DAE_Print
        
        mov rcx, [EFI_GOP_Mode_Info_Structure]
        mov qword [DAE_Y], 7
        xor rax, rax
        mov eax, [rcx + 0x8]
        call DAE_Convert_DQ_To_HEX_Text
        lea rax, [DAE_HEX_Text]
        call DAE_Print
        
        mov rcx, [EFI_GOP_Mode_Info_Structure]
        mov qword [DAE_Y], 14
        xor rax, rax
        mov eax, [rcx + 0x0C]
        call DAE_Convert_DQ_To_HEX_Text
        lea rax, [DAE_HEX_Text]
        call DAE_Print
        
        mov rcx, [EFI_GOP_Mode_Info_Structure]
        mov qword [DAE_Y], 21
        xor rax, rax
        mov eax, [rcx + 0x10]
        call DAE_Convert_DQ_To_HEX_Text
        lea rax, [DAE_HEX_Text]
        call DAE_Print
        
        mov rcx, [EFI_GOP_Mode_Info_Structure]
        mov qword [DAE_Y], 28
        xor rax, rax
        mov eax, [rcx + 0x14]
        call DAE_Convert_DQ_To_HEX_Text
        lea rax, [DAE_HEX_Text]
        call DAE_Print
        jmp $
        
        mov rax, Core_END - Core
        call DAE_Convert_DQ_To_HEX_Text
        lea rax, [DAE_HEX_Text]
        call DAE_Print
        
        ; Allocate memory for Core
        mov rax, Core_Size_In_Pages
        mov rdx, EfiRuntimeServicesData
        call EFI_AllocatePages
        mov [Core_Physical_Address], rax
        
        ; Allocate memory for Core Stack
        mov rax, Core_Size_In_Pages
        mov rdx, EfiRuntimeServicesData
        call EFI_AllocatePages
        mov [Core_Stack_Physical_Address], rax

        ; Move Core to allocated memory
        lea rax, [Core]
        mov rbx, [Core_Physical_Address]
        mov rcx, Core_END - Core
        call MEM_Copy_Bytes
        
        call EFI_GetMapMemory
        
        mov rax, [EFI_MemMapSize]
        call MEM_Calc_Needed_Pages_From_Count_Bytes
        mov [Temp_Size_MemMap_In_Pages], rax

        ; Allocate memory for mem map
        mov rax, [Temp_Size_MemMap_In_Pages]
        mov rdx, EfiRuntimeServicesData
        call EFI_AllocatePages
        mov [EFI_MemMapPointer], rax
        
        ; Allocate memory for PMM map
        mov rax, [Temp_Size_MemMap_In_Pages]
        mov rdx, EfiRuntimeServicesData
        call EFI_AllocatePages
        mov [Temp_Pointer_PMM_Map], rax
        
        call EFI_GetMapMemory
        
        call EFI_ExitBootServises

        ;arguments to start
        mov rax, [EFI_MemMapPointer]
        mov rbx, [Temp_Pointer_PMM_Map]
        
        jmp [Core_Physical_Address]
        
CODE_END:

; Padding code -----------------------------------------------------------------------------------
FILE_CODE_PADDING           EQU (FILE_CODE_SECTIONS_COUNT * FILE_ALIGNMENT) - FILE_CODE_SIZE
FILE_CODE_SECTIONS_COUNT    EQU (FILE_CODE_SIZE + FILE_ALIGNMENT - 1) / FILE_ALIGNMENT
FILE_CODE_SIZE              EQU CODE_END - CODE
TIMES FILE_CODE_PADDING     DB 0
;------------------------------------------------------------

; Data begins here
DATA:
  EFI:
    %include "Lib/EFI.asm"
    
  Core:
    %include "Core.asm"
  Core_END:
  Temp_Size_MemMap_In_Pages dq 0
  Temp_Pointer_PMM_Map dq 0
DATA_END:

; Padding data ------------------------------------------------------------------------------------
FILE_DATA_PADDING           EQU (FILE_DATA_SECTIONS_COUNT * FILE_ALIGNMENT) - FILE_DATA_SIZE
FILE_DATA_SECTIONS_COUNT    EQU (FILE_DATA_SIZE + FILE_ALIGNMENT - 1) / FILE_ALIGNMENT
FILE_DATA_SIZE              EQU DATA_END - DATA
TIMES FILE_DATA_PADDING     DB 0
;-------------------------------------------------------------
END:

CODE_RVA  equ 0x1000 ;code section after header
DATA_RVA  equ CODE_RVA + (SECTION_ALIGNMENT * ((FILE_CODE_SIZE + SECTION_ALIGNMENT - 1) / SECTION_ALIGNMENT))
;RELOC_RVA equ DATA_RVA + (SECTION_ALIGNMENT * ((FILE_DATA_SIZE + SECTION_ALIGNMENT - 1) / SECTION_ALIGNMENT))

SECTION_ALIGNMENT equ 0x1000
FILE_ALIGNMENT    equ 0x1000

