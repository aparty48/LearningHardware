; First order of business is to store the values that were passed to us by EFI
mov [EFI_IMAGE_HANDLE], rcx                                     ;save image pointer
mov [EFI_SYSTEM_TABLE], rdx                                     ;save system table

mov rax, [EFI_SYSTEM_TABLE]                                     ;get the EFI_SYSTEM_TABLE              
mov rax, [rax + EFI_SYSTEM_TABLE_BOOTSERVICES]                  ;get the EFI_SYSTEM_TABLE.BootServices 
mov [EFI_BOOTSERVICES], rax                                     ;save result

lea rdx, [EFI_Start]
call EFI_WriteText

; Settings Graphic
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

; Save GOP data to DAE data
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

; Allocate memory for Core
mov rax, Core_Size_In_Pages
mov rdx, EfiRuntimeServicesData
call EFI_AllocatePages
mov [Temp_Core_Physical_Address], rax

; Allocate memory for Core Stack
mov rax, Core_Size_In_Pages
mov rdx, EfiRuntimeServicesData
call EFI_AllocatePages
mov [Temp_Core_Stack_Physical_Address], rax

; Move Core to allocated memory
lea rax, [Core]
mov rbx, [Temp_Core_Physical_Address]
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

; Allocate memory for Init Data Structure 
mov rax, 1
mov rdx, EfiRuntimeServicesData
call EFI_AllocatePages
mov [Temp_Pointer_Init_Data_Structure], rax

call EFI_GetMapMemory

;fill init data structure
mov rax, [Temp_Pointer_Init_Data_Structure]
mov word [rax + 0x0], 0xffff                       ; version Init Data Structure
mov rbx, [EFI_MemMapDescVer]
mov [rax + 0x2], rbx
mov rbx, [EFI_MemMapDescSize]
mov [rax + 0xA], rbx
mov rbx, [EFI_MemMapSize]
mov [rax + 0x12], rbx
mov rbx, [EFI_MemMapPointer]
mov [rax + 0x1A], rbx
mov r8, rax                                        ; calc size PMM map
xor rdx, rdx
mov rax, [Temp_Size_MemMap_In_Pages]
mov rbx, Page_Size
mul rbx
mov rbx, rax
mov rax, r8
mov [rax + 0x22], rbx                              ; size PMM map
mov rbx, [Temp_Pointer_PMM_Map]
mov [rax + 0x2A], rbx                              ; pointer PMM map
mov rbx, [Temp_Core_Physical_Address]
mov [rax + 0x32], rbx
mov rbx, [Temp_Core_Stack_Physical_Address]
mov [rax + 0x3A], rbx

call EFI_ExitBootServises

;arguments to start
;rax - pointer to init data structure
mov rax, [Temp_Pointer_Init_Data_Structure]
jmp [Temp_Core_Physical_Address]

