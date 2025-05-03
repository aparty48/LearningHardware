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
    .NUMBER_OF_SECTIONS         dw 3                                                                ; Number of sections. Indicates size of section table that immediately follows the headers
    .CREATED_DATE_TIME          dd 1657582794                                                       ; Number of seconds since 1970 since when the file was created
    .SYMBOL_TABLE_POINTER       dd 0x00                                                             ; Pointer to the symbol table. There should be no symbol table in an image so this is 0
    .NUMBER_OF_SYMBOLS          dd 0x00                                                             ; Because there are no symbol tables in an image
    .OPTIONAL_HEADER_SIZE       dw OPTIONAL_HEADER_STOP - OPTIONAL_HEADER_START                     ; Size of the optional header
    .CHARACTERISTICS            dw 0b0010111000100010                                               ; These are the attributes of the file

OPTIONAL_HEADER_START:
    .MAGIC_NUMBER               dw 0x020B                       ; PE32+ (i.e. pe64) magic number
    .MAJOR_LINKER_VERSION       db 0                            ; I'm sure this isn't needed. So set to 0
    .MINOR_LINKER_VERSION       db 0                            ; This too
    .SIZE_OF_CODE               dd CODE_END - CODE              ; The size of the code section
    .INITIALIZED_DATA_SIZE      dd DATA_END - DATA              ; Size of initialized data section
    .UNINITIALIZED_DATA_SIZE    dd 0x00                         ; Size of uninitialized data section
    .ENTRY_POINT_ADDRESS        dd EntryPoint - START           ; Address of entry point relative to image base when the image is loaded in memory
    .BASE_OF_CODE_ADDRESS       dd CODE - START                 ; Relative address of base of code
    .IMAGE_BASE                 dq 0x400000                     ; Where in memory we would prefer the image to be loaded at
    .SECTION_ALIGNMENT          dd 0x8000                       ; Alignment in bytes of sections when they are loaded in memory. Align to page boundry (8kb)
    .FILE_ALIGNMENT             dd 0x200                        ; Alignment of sections in the file. Also align to 4kb
    .MAJOR_OS_VERSION           dw 0x00                         ; I'm not sure UEFI requires these and the following 'version woo'
    .MINOR_OS_VERSION           dw 0x00                         ; More of these version thingies are to follow. Again, not sure UEFI needs them
    .MAJOR_IMAGE_VERSION        dw 0x00                         ; Major version of the image
    .MINOR_IMAGE_VERSION        dw 0x00                         ; Minor version of the image
    .MAJOR_SUBSYSTEM_VERSION    dw 0x00                         ; 
    .MINOR_SUBSYSTEM_VERSION    dw 0x00                         ;
    .WIN32_VERSION_VALUE        dd 0x00                         ; Reserved, must be 0
    .IMAGE_SIZE                 dd 0xF000                       ; The size in bytes of the image when loaded in memory including all headers
    .HEADERS_SIZE               dd HEADER_END - HEADER_START    ; Size of all the headers
    .CHECKSUM                   dd 0x00                         ; Hoping this doesn't break the application
    .SUBSYSTEM                  dw 10                           ; The subsystem. In this case we're making a UEFI application.
    .DLL_CHARACTERISTICS        dw 0b000011110010000            ; I honestly don't know what to put here
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
            ;.address            dd END - START                              ; Address of relocation table
            ;.size               dd 0                                        ; Size of relocation table
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
        .virtual_address            dd CODE - START
        .size_of_raw_data           dd CODE_END - CODE
        .pointer_to_raw_data        dd CODE - START
        .pointer_to_relocations     dd 0                                    ; Set to 0 for executable images
        .pointer_to_line_numbers    dd 0                                    ; There are no COFF line numbers
        .number_of_relocations      dw 0                                    ; Set to 0 for executable images
        .number_of_line_numbers     dw 0                                    ; Should be 0 for images
        .characteristics            dd 0x70000020                           ; Need to read up more on this

    SECTION_DATA:
        .name                       db ".data", 0x00, 0x00, 0x00
        .virtual_size               dd DATA_END - DATA
        .virtual_address            dd DATA - START
        .size_of_raw_data           dd DATA_END - DATA
        .pointer_to_raw_data        dd DATA - START
        .pointer_to_relocations     dd 0
        .pointer_to_line_numbers    dd 0
        .number_of_relocations      dw 0
        .number_of_line_numbers     dw 0
        .characteristics            dd 0xD0000040

    SECTION_RELOC:
        .name                       db ".reloc", 0x00, 0x00
        .virtual_size               dd 200
        .virtual_address            dd END - START
        .size_of_raw_data           dd 200
        .pointer_to_raw_data        dd END - START
        .pointer_to_relocations     dd 0
        .pointer_to_line_numbers    dd 0
        .number_of_relocations      dw 0
        .number_of_line_numbers     dw 0
        .characteristics            dd 0xC2000040 ;dd 0x42000040 ;

times 512-($-PE)   db 0
HEADER_END:

CODE:
    ; The code begins here with the entry point
    EntryPoint:

        ; First order of business is to store the values that were passed to us by EFI
        mov [EFI_IMAGE_HANDLE], rcx
        mov [EFI_SYSTEM_TABLE], rdx
        
    ;GetTables
        sub rsp, 6*8+8
        mov rax, [EFI_SYSTEM_TABLE]                                     ;get the EFI_SYSTEM_TABLE              
        mov rax, [rax + EFI_SYSTEM_TABLE_BOOTSERVICES]                  ;get the EFI_SYSTEM_TABLE.BootServices 
        mov [EFI_BOOTSERVICES], rax
        
    GetGraphicInterfase:
        mov rbx, [EFI_BOOTSERVICES]
        lea rcx, [EFI_GRAPHICS_OUTPUT_PROTOCOL_GUID]
        mov rdx, 0
        lea r8, [Interface_GOP]
        call [rbx + EFI_BOOT_SERVICES_LOCATEPROTOCOL]
        cmp rax, EFI_SUCCESS
        je GetGraphicBuffer
        mov rdx, 2
        mul rdx
        lea rdx, [Codes1]
        add rdx, rax
        mov rcx, [EFI_SYSTEM_TABLE]
        mov rcx, [rcx + EFI_SYSTEM_TABLE_CONOUT]
        call [rcx + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_OutputString]
        jmp $
        
    GetGraphicBuffer:
        mov rcx, [Interface_GOP]
        mov rcx, [rcx + 0x18] ;EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE
        mov rbx, [rcx + 0x18] ;EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE_FRAMEBUFFERBASE
        mov [FB], rbx
        mov rcx, [rcx + 0x20] ;EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE_FRAMEBUFFERSIZE
        mov [FBS], rcx
        
    GetMapMemory:
         mov qword [memmapsize], 4096
         lea rcx, [memmapsize]
         lea rdx, [memmap]
         lea r8, [memmapkey]
         lea r9, [memmapdescsize]
         lea r10, [memmapdescver]
         mov rbx, [EFI_BOOTSERVICES]
         mov [rsp+32], r10
         call [rbx + EFI_BOOT_SERVICES_GETMEMORYMAP]
         
         mov rdx, 2
         mul rdx
         lea rdx, [Codes]
         add rdx, rax
         mov rcx, [EFI_SYSTEM_TABLE]
         mov rcx, [rcx + EFI_SYSTEM_TABLE_CONOUT]
         call [rcx + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_OutputString]
         
         cmp rax, EFI_SUCCESS
         je endLoop
         jmp GetMapMemory
         
    endLoop:
    ; exit boot services
        lea rdx, [NewLine]
        mov rcx, [EFI_SYSTEM_TABLE]
        mov rcx, [rcx + EFI_SYSTEM_TABLE_CONOUT]
        call [rcx + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_OutputString]
    LoopExit:
        mov rcx, [EFI_IMAGE_HANDLE]
        mov rdx, [memmapkey]
        mov rbx, [EFI_SYSTEM_TABLE]
        mov rbx, [rbx + EFI_SYSTEM_TABLE_BOOTSERVICES]
        call [rbx + EFI_BOOT_SERVICES_EXITBOOTSERVICES]
        
        cmp rax, EFI_SUCCESS
        je end
        mov rdx, 2
        mul rdx
        lea rdx, [Codes1]
        add rdx, rax
        mov rcx, [EFI_SYSTEM_TABLE]
        mov rcx, [rcx + EFI_SYSTEM_TABLE_CONOUT]
        call [rcx + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_OutputString]
        jmp LoopExit
        
    end:
        mov rcx, [FB]
        mov rax, [FBS]
        
        %include "draw.asm"
        
        ;align 512
        times 8704-($-PE)   db 0

CODE_END:

; Data begins here
DATA:
    EFI_IMAGE_HANDLE    dq 0x00                                     ; EFI will give use this in rcx
    EFI_SYSTEM_TABLE    dq 0x00                                     ; And this in rdx
    EFI_BOOTSERVICES    dq 0
    Interface_GOP       dq 0
    FB                  dq 0
    FBS                 dq 0
    memmapsize          dq 4096
    memmapkey           dq 0
    memmapdescsize      dq 48
    memmapdescver       dq 0
    memmap              dq 0

    Codes:                                 db __utf16__ `0123456789ABCDEFGHIJKLMNOPTRSUVWXYZ\r\0`
    Codes1:                                db __utf16__ `ZXYWVUSRTPONMLKJIHGFEDCBA9876543210\r\0`
    NewLine  db __utf16__ `\n\0`
    EFI_GRAPHICS_OUTPUT_PROTOCOL_GUID db 0xde, 0xa9, 0x42, 0x90, 0xdc, 0x23, 0x38, 0x4a, 0x96, 0xfb, 0x7a, 0xde, 0xd0, 0x80, 0x51, 0x6a
    times 9216-($-PE) db 0
    

    ;times 13312-($-PE) db 0
    ;times 12800-($-PE)   db 0

    chars:
        %include "CharsDataDump.asm"
        times 40960-($-PE)   db 0
DATA_END:
END:

; Define the needed EFI constants and offsets here.
EFI_SUCCESS                                         equ 0
EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL                     equ 64                    
EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_Reset               equ 0
EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_OutputString        equ 8

EFI_SYSTEM_TABLE_CONOUT                             equ 64
EFI_SYSTEM_TABLE_BOOTSERVICES                       equ 96
EFI_BOOT_SERVICES_GETMEMORYMAP                      equ 56
EFI_BOOT_SERVICES_EXIT                              equ 216
EFI_BOOT_SERVICES_EXITBOOTSERVICES                  equ 232
EFI_BOOT_SERVICES_LOCATEPROTOCOL                    equ 320
