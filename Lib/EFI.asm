; EFI_Code ------------------------------------------------------------------------------------------------------------------------------------
EFI_AllocatePages:
  ;Input
  ;rax - count pages
  ;rdx - type page
  ;Output
  ;rax - address
  mov rbx, [EFI_BOOTSERVICES]
  mov rcx, 0                      ;type, 0 - allocateAnyPages, 1 - AllocateMaxAddress, 2 - AllocateAddress
  mov r8, rax
  lea r9, [EFI_AllocatePages_return]
  call [rbx + EFI_BOOT_SERVICES_ALLOCATEPAGES]
  cmp rax, EFI_SUCCESS
  je EFI_AllocatePages_end
  
  push rax
  lea rdx, [EFI_Msg_GetGraphicInterfase]                           ;if no: write EFI_Code error 
  call EFI_WriteText 
  pop rax
  call WriteEfiCode   
  lea rdx, [EFI_NewLine]
  call EFI_WriteText
  jmp $
  
  EFI_AllocatePages_end:
    mov rax, [EFI_AllocatePages_return]
    ret
  
  EFI_AllocatePages_return:
    dq 0
;----------------------------------------------------------------------------------------------------------------------------------------------
EFI_GetGraphicInterfase:
  ;Used:
  ;rax, rbx, rcx, rdx, r8, other unknown
  
  mov [EFI_RSP], rsp
  mov rbx, [EFI_BOOTSERVICES]                                     ;arg 1 - pointer to table
  lea rcx, [EFI_GRAPHICS_OUTPUT_PROTOCOL_GUID]                    ;arg 2 - pointer to guid protocol
  mov rdx, 0                                                      ;arg 3 - hz))
  lea r8, [EFI_Interface_GOP]                                     ;arg 4 - pointer to pointer Graphic_Output_Protocol, this is result
  call [rbx + EFI_BOOT_SERVICES_LOCATEPROTOCOL]
  mov rsp, [EFI_RSP]
  
  cmp rax, EFI_SUCCESS                                            ;if call is success?
  je EFI_GetGraphicBuffer 
  
  push rax
  lea rdx, [EFI_Msg_GetGraphicInterfase]                           ;if no: write EFI_Code error 
  call EFI_WriteText 
  pop rax
  call WriteEfiCode   
  lea rdx, [EFI_NewLine]
  call EFI_WriteText
  jmp $
  
  EFI_GetGraphicBuffer:
    mov rcx, [EFI_Interface_GOP]
    mov rcx, [rcx + 0x18] ;EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE
    mov rbx, [rcx + 0x18] ;EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE_FRAMEBUFFERBASE
    mov [EFI_FB], rbx
    mov rbx, [rcx + 0x20] ;EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE_FRAMEBUFFERSIZE
    mov [EFI_FBS], rbx
    mov rbx, [rcx + 0x8]
    mov [EFI_GOP_Mode_Info], rbx
    ret
; ----------------------------------------------------------------------------------------------------------------------------  
EFI_GetMapMemory:
  mov rbx, [EFI_BOOTSERVICES]
  lea rcx, [EFI_MemMapSize]
  mov rdx, [EFI_MemMapPointer]
  lea r8, [EFI_MemMapKey]
  lea r9, [EFI_MemMapDescSize]
  lea r10, [EFI_MemMapDescVer]
  call [rbx + EFI_BOOT_SERVICES_GETMEMORYMAP]
  
  cmp rax, EFI_SUCCESS
  je EFI_GetMapMemory_End
  cmp al, 5
  je EFI_GetMapMemory_End
  jne EFI_GetMapMemory_WriteMsg
  
  EFI_GetMapMemory_WriteMsg:
    push rax
    lea rdx, [EFI_Msg_GetMemoryMap] 
    call EFI_WriteText 
    pop rax
    call WriteEfiCode   
    lea rdx, [EFI_NewLine]
    call EFI_WriteText
    jmp $
  
  EFI_GetMapMemory_End:
    ret
;------------------------------------------------------------
EFI_ExitBootServises:
    mov [EFI_RSP], rsp
    mov rcx, [EFI_IMAGE_HANDLE]
    mov rdx, [EFI_MemMapKey]
    mov rbx, [EFI_BOOTSERVICES]
    ;mov rbx, [rbx + EFI_SYSTEM_TABLE_BOOTSERVICES]
    call [rbx + EFI_BOOT_SERVICES_EXITBOOTSERVICES]
    mov rsp, [EFI_RSP]
    
    cmp rax, EFI_SUCCESS
    je EFI_ExitBootServises_End
    
    push rax
    lea rdx, [EFI_Msg_ExitBootServices] 
    call EFI_WriteText 
    pop rax
    call WriteEfiCode   
    lea rdx, [EFI_NewLine]
    call EFI_WriteText
    jmp $
    
  EFI_ExitBootServises_End:
    ret

WriteEfiCode:
  ;Input:
  ;rax - EFI_Code
  mov rdx, 2
  mul rdx
  lea rdx, [EFI_Code]
  lea rcx, [EFI_Codes]
  add rax, rcx
  mov cx, WORD[rax]
  mov WORD[rdx], cx
  mov rcx, [EFI_SYSTEM_TABLE]
  mov rcx, [rcx + EFI_SYSTEM_TABLE_CONOUT]
  call [rcx + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_OutputString]
  ret
  
EFI_WriteText:
  ;rdx - pointer to text
  mov rcx, [EFI_SYSTEM_TABLE]
  mov rcx, [rcx + EFI_SYSTEM_TABLE_CONOUT]
  call [rcx + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_OutputString]
  ret
  
  

; EFI_DATA ---------------------------------------------------------------------------------------------------------------------------
EFI_GRAPHICS_OUTPUT_PROTOCOL_GUID db 0xde, 0xa9, 0x42, 0x90, 0xdc, 0x23, 0x38, 0x4a, 0x96, 0xfb, 0x7a, 0xde, 0xd0, 0x80, 0x51, 0x6a
EFI_IMAGE_HANDLE                  dq 0x00                                     ; EFI will give use this in rcx
EFI_SYSTEM_TABLE                  dq 0x00                                     ; And this in rdx
EFI_BOOTSERVICES                  dq 0
EFI_Interface_GOP                 dq 0
EFI_MemMapSize                    dq 0
EFI_MemMapKey                     dq 0
EFI_MemMapDescSize                dq 0
EFI_MemMapDescVer                 dq 0
EFI_MemMapPointer                 dq 0
EFI_FB                            dq 0
EFI_FBS                           dq 0
EFI_Codes:                        db __utf16__ `0123456789ABCDEFGHIJKLMNOPTRSUVWXYZ\r\0`
EFI_Code:                         db __utf16__ `\0\0`
EFI_NewLine                       db __utf16__ `\n\r\0`
EFI_Start                         db __utf16__ `EFI app started! \0`
EFI_Msg_AllocatePages             db __utf16__ `AllocatePages code: \0`
EFI_Msg_GetGraphicInterfase       db __utf16__ `GetGraphicInterfase code: \0`
EFI_Msg_GetMemoryMap              db __utf16__ `GetMemoryMap code: \0`
EFI_Msg_AllocPool                 db __utf16__ `AllocPool code: \0`
EFI_Msg_ExitBootServices          db __utf16__ `ExitBootServices code: \0`
EFI_RSP                           dq 0
EFI_GOP_Mode_Info                 dq 0
    
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
