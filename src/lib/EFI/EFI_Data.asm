; EFI_DATA ---------------------------------------------------------------------------------------------------------------------------
EFI_GRAPHICS_OUTPUT_PROTOCOL_GUID db 0xde, 0xa9, 0x42, 0x90, 0xdc, 0x23, 0x38, 0x4a, 0x96, 0xfb, 0x7a, 0xde, 0xd0, 0x80, 0x51, 0x6a
EFI_IMAGE_HANDLE                  dq 0x00                                     ; EFI will give use this in rcx
EFI_SYSTEM_TABLE                  dq 0x00                                     ; And this in rdx
EFI_BOOTSERVICES                  dq 0
EFI_MemMapSize                    dq 0
EFI_MemMapKey                     dq 0
EFI_MemMapDescSize                dq 0
EFI_MemMapDescVer                 dq 0
EFI_MemMapPointer                 dq 0
EFI_AllocatePages_return          dq 0xffffffffffffffff
EFI_Codes:                        db __utf16__ `0123456789ABCDEFGHIJKLMNOPTRSUVWXYZ\r\0`
EFI_Code:                         db __utf16__ `\0\0`
EFI_NewLine                       db __utf16__ `\n\r\0`
EFI_Start                         db __utf16__ `EFI app started! \n\r\0`
EFI_Msg_AllocatePages             db __utf16__ `AllocatePages code: \0`
EFI_Msg_GetGraphicInterfase       db __utf16__ `GetGraphicInterfase code: \0`
EFI_Msg_GOP_SetMode               db __utf16__ `GOP Set Mode code: \0`
EFI_Msg_GetMemoryMap              db __utf16__ `GetMemoryMap code: \0`
EFI_Msg_AllocPool                 db __utf16__ `AllocPool code: \0`
EFI_Msg_ExitBootServices          db __utf16__ `ExitBootServices code: \0`
EFI_RSP                           dq 0
EFI_Interface_GOP                 dq 0
EFI_GOP_Mode                      dq 0
EFI_GOP_Number_Of_Mode            dd 0
EFI_GOP_Max_Area                  dq 0
EFI_GOP_Max_Area_Number           dd 0
EFI_FB                            dq 0
EFI_FBS                           dq 0
;EFI_GOP_Mode_Info                dq 0
EFI_GOP_Version                   dq 0, 0
EFI_GOP_Mode_Info_Size            dq 0
EFI_GOP_Mode_Info_Structure       dq 0
    
; EFI_Consts -------------------------------------------------
; Define the needed EFI constants and offsets here.
EFI_SUCCESS                                         equ 0
EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL                     equ 64                    
EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_Reset               equ 0
EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_OutputString        equ 8

EFI_SYSTEM_TABLE_CONOUT                             equ 64
EFI_SYSTEM_TABLE_BOOTSERVICES                       equ 96
EFI_BOOT_SERVICES_ALLOCATEPAGES                     equ 40
EFI_BOOT_SERVICES_FREEPAGES                         equ 48
EFI_BOOT_SERVICES_GETMEMORYMAP                      equ 56
EFI_BOOT_SERVICES_AllocatePool                      equ 64
EFI_BOOT_SERVICES_FreePool                          equ 72
EFI_BOOT_SERVICES_EXIT                              equ 216
EFI_BOOT_SERVICES_EXITBOOTSERVICES                  equ 232
EFI_BOOT_SERVICES_LOCATEPROTOCOL                    equ 320

; EFI_GRAPHICS_OUTPUT_PROTOCOL --------------------------------------------------------------------
;EFI_GRAPHIC_OUTPUT_PROTOCOL_QUERY_MODE  QueryMode   - pointer to function 8 bytes
;EFI_GRAPHIC_OUTPUT_PROTOCOL_SET_MODE    SetMode     - pointer to function 8 bytes
;EFI_GRAPHIC_OUTPUT_PROTOCOL_BLT         Blt         - pointer to function 8 bytes
;EFI_GRAPHIC_OUTPUT_PROTOCOL_MODE*       Mode        - pointer to next structure 8 bytes

; EFI_GRAPHIC_OUTPUT_PROTOCOL_MODE -----------------------------------------------------------------
; UINT32  MaxMode          - total number of available modes
; UINT32  Mode             - number of the current mode
; VOID*   Info             - pointer to mode information structure
; UINTN   SizeOfInfo       - size of the info structure 8 bytes
; UINT64  FrameBufferBase  - Physycal address of the framebuffer
; UINTN   FrameBufferSize  - size of the framebuffer in bytes

; EFI_GRAPHIC_OUTPUT_PROTOCOL_MODE_INFORMATION
; UINT32 Version
; UINT32 HorizontalResolution
; UINT32 VerticalResolution
; UINT32 PixelFormat
; UINT32 PixelInformation
; UINT32 PixelPerScanLine
