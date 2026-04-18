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
  mov [EFI_RSP], rsp
  sub rsp, 32
  and rsp, 0xffffffffffffff00
  call [rbx + EFI_BOOT_SERVICES_ALLOCATEPAGES]
  mov rsp, [EFI_RSP]
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
  
;----------------------------------------------------------------------------------------------------------------------------------------------
EFI_GetGraphicInterfase:
  ;Used:
  ;rax, rbx, rcx, rdx, r8, other unknown
  mov rbx, [EFI_BOOTSERVICES]                                     ;arg 1 - pointer to table
  lea rcx, [EFI_GRAPHICS_OUTPUT_PROTOCOL_GUID]                    ;arg 2 - pointer to guid protocol
  mov rdx, 0                                                      ;arg 3 - hz))
  lea r8, [EFI_Interface_GOP]                                     ;arg 4 - pointer to pointer Graphic_Output_Protocol, this is result
  mov [EFI_RSP], rsp
  sub rsp, 32
  and rsp, 0xffffffffffffff00
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
    ;mov rbx, [rcx + 0x0]
    ;mov [EFI_GOP_Mode_Info_Structure], rbx
    ret
; ----------------------------------------------------------------------------------------------------------------------------
EFI_Find_Set_Graphic_Mode:
  mov rax, [EFI_Interface_GOP]
  mov rax, [rax + 0x18]
  mov [EFI_GOP_Mode], rax	
  
  EFI_Find_Set_Graphic_Mode_Loop:
    xor rax, rax
    xor rbx, rbx
    mov rcx, [EFI_GOP_Mode]
    mov eax, [rcx]                      ; get total number of available modes
    mov ebx, [EFI_GOP_Number_Of_Mode]
    cmp ebx, eax
    jae EFI_Find_Set_Graphic_Mode_End
    
    xor rdx, rdx
    mov edx, [EFI_GOP_Number_Of_Mode]
    call EFI_Query_Mode
    cmp rax, EFI_SUCCESS
    jne EFI_Find_Set_Graphic_Mode_Loop_Inc
    
    mov rdx, [EFI_GOP_Mode_Info_Structure]
    xor rax, rax
    mov eax, [rdx + 0x4]
    xor rbx, rbx
    mov ebx, [rdx + 0x8]
    mul rbx
    cmp rax, [EFI_GOP_Max_Area]
    jna EFI_Find_Set_Graphic_Mode_Loop_Inc
    
    mov [EFI_GOP_Max_Area], rax
    mov edx, [EFI_GOP_Number_Of_Mode]
    mov [EFI_GOP_Max_Area_Number], edx
    
    EFI_Find_Set_Graphic_Mode_Loop_Inc:
      inc dword [EFI_GOP_Number_Of_Mode]
      jmp EFI_Find_Set_Graphic_Mode_Loop
  
  EFI_Find_Set_Graphic_Mode_End:
    ; set mode
    mov rcx, [EFI_Interface_GOP]
    mov rdx, [EFI_GOP_Max_Area_Number]
    mov [EFI_RSP], rsp
    sub rsp, 32
    and rsp, 0xffffffffffffff00
    call [rcx + 0x8]
    mov rsp, [EFI_RSP]
    cmp rax, EFI_SUCCESS
    je EFI_Find_Set_Graphic_Mode_End_ret
    push rax
    lea rdx, [EFI_Msg_GOP_SetMode] 
    call EFI_WriteText 
    pop rax
    call WriteEfiCode   
    lea rdx, [EFI_NewLine]
    call EFI_WriteText
    jmp $
    
    EFI_Find_Set_Graphic_Mode_End_ret:
      mov rax, [EFI_Interface_GOP]
      mov rax, [rax + 0x18]
      mov [EFI_GOP_Mode], rax
      mov rbx, [rax + 0x18]
      mov [EFI_FB], rbx
      mov rbx, [rax + 0x20]
      mov [EFI_FBS], rbx
      ret
; ----------------------------------------------------------------------------------------------------------------------------
EFI_Query_Mode:
  ;rdx - number of mode
  mov rcx, [EFI_Interface_GOP]
  lea r8, [EFI_GOP_Mode_Info_Size]
  lea r9, [EFI_GOP_Mode_Info_Structure]
  mov [EFI_RSP], rsp
  sub rsp, 32
  and rsp, 0xffffffffffffff00
  call [rcx]
  mov rsp, [EFI_RSP]
  ret
; ----------------------------------------------------------------------------------------------------------------------------  
EFI_GetMapMemory:
  mov rbx, [EFI_BOOTSERVICES]
  lea rcx, [EFI_MemMapSize]
  mov rdx, [EFI_MemMapPointer]
  lea r8, [EFI_MemMapKey]
  lea r9, [EFI_MemMapDescSize]
  lea r10, [EFI_MemMapDescVer]
  mov [EFI_RSP], rsp
  sub rsp, 32
  and rsp, 0xffffffffffffff00
  call [rbx + EFI_BOOT_SERVICES_GETMEMORYMAP]
  mov rsp, [EFI_RSP]
  
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
    mov rcx, [EFI_IMAGE_HANDLE]
    mov rdx, [EFI_MemMapKey]
    mov rbx, [EFI_BOOTSERVICES]
    ;mov rbx, [rbx + EFI_SYSTEM_TABLE_BOOTSERVICES]
    mov [EFI_RSP], rsp
    sub rsp, 32
    and rsp, 0xffffffffffffff00
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
  mov [EFI_RSP], rsp
  sub rsp, 32
  and rsp, 0xffffffffffffff00
  call [rcx + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_OutputString]
  mov rsp, [EFI_RSP]
  ret
  
EFI_WriteText:
  ;rdx - pointer to text
  mov rcx, [EFI_SYSTEM_TABLE]
  mov rcx, [rcx + EFI_SYSTEM_TABLE_CONOUT]
  mov [EFI_RSP], rsp
  sub rsp, 32
  and rsp, 0xffffffffffffff00
  call [rcx + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_OutputString]
  mov rsp, [EFI_RSP]
  ret
  
  


