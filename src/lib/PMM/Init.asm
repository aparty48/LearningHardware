PMM_Init:
  ;Input:
  ;rax - descriptor size
  ;rbx - discriptor version
  ;rcx - pointer on map
  ;rdx - size of map in bytes
  ;r10 - address to PMM map
  ;r11 - Size PMM map in pages
  PMM_Init_start:
    mov [PMM_Address_Map], r10
    mov [PMM_Size_Map_In_Pages], r11
    push rcx
    push rdx
    push r10
    call PMM_CheckVersionOf_EFI_PMMMAP
    pop r10
    pop rdx
    pop rcx
    xor rbx, rbx
    cmp r8, rbx       ; result checking
    jne PMM_Init_end
    
  PMM_Init_calc_count_elements:
    mov rbx, 48
    mov rax, rdx
    xor rdx, rdx
    div rbx
    
    mov [PMM_Count_Descriptors], rbx
  
  ;rax - current descriptor address uefi
  ;rbx - count descriptors in map
  ;rcx - pointer on map UEFI
  ;r8  - counter, current descriptor index
  ;r10 - pointer on map PMM
  ;r11 - current descriptor address pmm
  mov rbx, rax
  xor r8, r8
  
  PMM_Init_loop:
    PMM_Init_loop_check:
      cmp r8, rbx
      jnl PMM_Init_end
      
    PMM_Init_loop_body:
      PMM_Init_loop_calc_address_descriptor_UEFI:
        mov r9, 48
        xor rdx, rdx
        mov rax, r8
        mul r9
        add rax, rcx
        push rax
        
      PMM_Init_loop_calc_address_descriptor_PMM:
        mov r9, 20
        xor rdx, rdx
        mov rax, r8
        mul r9
        add rax, r10
        mov r11, rax
        pop rax
        
      PMM_Init_loop_move:
        mov rdx, [rax + 0x8]   ; get from UEFI descriptor, Physical start address
        mov [r11 + 0x0], rdx   ; set to PMM descriptor
        mov rdx, [rax + 0x18]  ; Number of pages
        mov [r11 + 0x8], rdx
        mov rdx, [rax + 0x0]   ; Type
        mov [r11 + 0x10], edx

    PMM_Init_loop_end:
      inc r8
      jmp PMM_Init_loop

  PMM_Init_end:
    call PMM_Init_Replace_Types
    ;call PMM_Print_Table_Descriptors
    call PMM_Merge_Of_Regions
    ;call PMM_Print_Table_Descriptors
    call PMM_Clear_Empty_Regions
    call PMM_Print_Table_Descriptors
    ret
;-------------------------------------------------------------------
PMM_CheckVersionOf_EFI_PMMMAP:
  ;Input:
  ;rax - descriptor size
  ;rbx - descriptor version
  ;Output:
  ;r8 - 0 if ver == 1 && size == 48
  ;Used:
  xor r8, r8
  push r8
  
  PMM_CVEMM_ver_0:
    cmp rbx, 0
    je PMM_CVEMM_size
  PMM_CVEMM_ver_1:
    cmp rbx, 1
    je PMM_CVEMM_size
    
  PMM_CVEMM_ver_err:
    inc qword [rsp]
    inc qword [rsp]
    push rax
    push rbx
    lea rbx, [PMM_Mes_1]
    call COM_Print
    pop rax
    call DAE_Convert_DQ_To_HEX_Text
    lea rbx, [DAE_HEX_Text]
    call COM_Print
    lea rbx, [PMM_Mes_3]
    call COM_Print
    pop rax
  
  PMM_CVEMM_size:
    cmp rax, 48
    je PMM_CVEMM_end
    inc qword [rsp]
    push rax
    lea rbx, [PMM_Mes_2]
    call COM_Print
    pop rax
    call DAE_Convert_DQ_To_HEX_Text
    lea rbx, [DAE_HEX_Text]
    call COM_Print
    lea rbx, [PMM_Mes_3]
    call COM_Print
    
  PMM_CVEMM_end:
    pop r8
    ret
;-------------------------------------------------------------------------------------
PMM_Init_Replace_Types:
  ;rcx - counter
  ;r8 - PMM_Address_Map
  PMM_Init_Replace_Types_Loop_init:
    xor rcx, rcx
    mov rbx, [PMM_Count_Descriptors]
    mov r8, [PMM_Address_Map]
    mov r9, 20
    
  PMM_Init_Replace_Types_Loop:
    cmp rcx, rbx
    jnl PMM_Init_Replace_Types_end
    
    xor rdx, rdx
    mov rax, rcx
    mul r9
    add rax, r8
    
    xor rdx, rdx
    mov edx, [rax + 0x10]
    cmp rdx, EfiLoaderCode
    je PMM_Init_Replace_Types_Replace
    cmp rdx, EfiLoaderData
    je PMM_Init_Replace_Types_Replace
    cmp rdx, EfiBootServicesCode
    je PMM_Init_Replace_Types_Replace
    cmp rdx, EfiBootServicesData
    je PMM_Init_Replace_Types_Replace
    inc rcx
    jne PMM_Init_Replace_Types_Loop
    
    PMM_Init_Replace_Types_Replace:
      mov edx, 7
      mov [rax + 0x10], edx
      inc rcx
      jmp PMM_Init_Replace_Types_Loop
      
    PMM_Init_Replace_Types_end:
      ret
    
