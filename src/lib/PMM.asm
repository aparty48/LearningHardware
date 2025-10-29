PMM_Init:
  ;Input:
  ;rax - descriptor size
  ;rbx - discriptor version
  ;rcx - pointer on map
  ;rdx - size of map in bytes
  ;r10 - address to PMM map
  PMM_Init_start:
    mov [PMM_Address_Map], r10
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
    
  ;call PMM_Merge_Of_Regions
  ;call PMM_Clear_Empty_Regions

  PMM_Init_end:
    call PMM_Init_Replace_Types
    call PMM_Print_Table_Descriptors
    call PMM_Merge_Of_Regions
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
    
;--------------------------------------------------------------------------------------
PMM_Allocate_Pages:
  ; Input
  ; rax - count pages
  ; rbx - type page
  ret
PMM_Free_Pages:
  ; rax - address
  ; set region as conventional memory
  call PMM_Merge_Of_Regions
  call PMM_Clear_Empty_Regions
  ret
  
PMM_Merge_Of_Regions:
  ; rbx - count descriptors
  ; rcx - counter
  ; r8 - address memory map
  ; r10 - count descriptors
  ; r11 - index merged descriptor
  ; r12 - flag finded
  ; r13 - current address descriptor[i]
  
  PMM_Merge_Of_Regions_Init_Loop:
    mov r8, [PMM_Address_Map]
    mov r10, [PMM_Count_Descriptors]
    xor r11, r11
    xor r12, r12
    xor rcx, rcx
    
  PMM_Merge_Of_Regions_Loop:
    PMM_Merge_Of_Regions_Loop_Check:
      cmp rcx, r10
      jnl PMM_Merge_Of_Regions_End
      
    PMM_Merge_Of_Regions_Calc_Addr_Descriptor:
      xor rdx, rdx
      mov rax, rcx
      mov r9, 20                                   ; size of descriptor
      mul r9
      add rax, r8                                  ;calc address descriptor[i]
      mov r13, rax
    
      cmp r12, 1
      jne PMM_Merge_Of_Regions_Not_Finded
      
    PMM_Merge_Of_Regions_Finded:
      xor rdx, rdx
      mov edx, [r13 + 0x10]                        ;get type from descriptor[i]
      cmp rdx, EfiConventionalMemory
      je PMM_Merge_Of_Regions_Finded_A
      jne PMM_Merge_Of_Regions_Finded_B
      
      PMM_Merge_Of_Regions_Finded_A:
        xor rdx, rdx
        mov rax, r11
        mov r9, 20             ;size of descriptor PMM
        mul r9
        add rax, r8            ;calc address merged descriptor
        
        mov rdx, [r13 + 0x8]   ;get number of pages from descriptor[i]
        mov r9, 0
        mov [r13 + 0x8], r9    ;set 0, number of pages from descriptor[i]
        mov r9, [rax + 0x8]    ;get number of pages from merged descriptor
        add r9, rdx            ;add pages
        mov [rax + 0x8], r9    ;save to merged descriptor
        
        jmp PMM_Merge_Of_Regions_End_Loop
        
      PMM_Merge_Of_Regions_Finded_B:
        mov r12, 0
        jmp PMM_Merge_Of_Regions_End_Loop
      
    PMM_Merge_Of_Regions_Not_Finded:
      xor rdx, rdx
      mov edx, [r13 + 0x10]                        ;get type from descriptor[i]
      
      cmp rdx, EfiConventionalMemory
      je PMM_Merge_Of_Regions_Not_Finded_C
      jne PMM_Merge_Of_Regions_End_Loop
      
      PMM_Merge_Of_Regions_Not_Finded_C:
        mov r12, 1           ;set flag
        mov r11, rcx         ;save index finded merged descriptor
    
  PMM_Merge_Of_Regions_End_Loop:
    inc rcx
    jmp PMM_Merge_Of_Regions_Loop
    
  PMM_Merge_Of_Regions_End:
    ret
;--------------------------------------------------------------------------------------------
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
    
;--------------------------------------------------------------------------------------------
PMM_Print_Table_Descriptors:
  PMM_Print_Table_Descriptors_Loop_init:
    xor rcx, rcx
    mov rbx, [PMM_Count_Descriptors]
    
  PMM_Print_Table_Descriptors_Loop:
    cmp rcx, rbx
    jnl PMM_Print_Table_Descriptors_end
    
    xor rdx, rdx
    mov r9, 20
    mov rax, rcx
    mul r9
    mov r9, [PMM_Address_Map]
    add rax, r9
    
    push rbx
    push rcx
    push rax
    mov rax, [rsp]
    mov rax, [rax + 0x0]             ;type
    call DAE_Convert_DQ_To_HEX_Text
    lea rbx, [DAE_HEX_Text]
    call COM_Print
    lea rbx, [PMM_Mes_4]
    call COM_Print
    mov rax, [rsp]
    mov rax, [rax + 0x8]             ;num
    call DAE_Convert_DQ_To_HEX_Text
    lea rbx, [DAE_HEX_Text]
    call COM_Print
    lea rbx, [PMM_Mes_4]
    call COM_Print
    mov rax, [rsp]
    mov eax, [rax + 0x10]            ;addr 
    and rax, 0xFFFFFFFF
    call DAE_Convert_DQ_To_HEX_Text
    lea rbx, [DAE_HEX_Text]
    call COM_Print
    lea rbx, [PMM_Mes_4]
    call COM_Print
    lea rbx, [PMM_Mes_3]
    call COM_Print
    pop rax
    pop rcx
    pop rbx
    
    inc rcx
    jmp PMM_Print_Table_Descriptors_Loop
    
  PMM_Print_Table_Descriptors_end:
    lea rbx, [PMM_Mes_3]
    call COM_Print
    ret
;--------------------------------------------------------------------------------------------
PMM_Clear_Empty_Regions:
  ret
