PMM_Free_Pages:
  ; rax - address
  ; set region as conventional memory
  ; rcx - counter
  ; r8 - [PMM_Address_Map]
  ; r9 - [PMM_Count_Descriptors]
  ; r11 - finded flag
  ; r12 - address
  ; Out:
  ; rax - code, 0 - good, 1 - not find descriptor
  PMM_Free_Pages_Loop_Init:
    mov r8, [PMM_Address_Map]
    mov r9, [PMM_Count_Descriptors]
    xor rcx, rcx
    xor r11, r11
    mov r12, rax
    
  PMM_Free_Pages_Loop:
    cmp rcx, r9
    jnl PMM_Free_Pages_Reload_Map
    
    xor rdx, rdx
    mov rax, rcx
    mov r10, 20
    mul r10
    add rax, r8
    
    mov rbx, [rax + 0x0]
    cmp r12, rbx
    jne PMM_Free_Pages_Loop_End
    
    mov r11, 1                                        ;finded
    mov dword [rax + 0x10], PMMConventionalMemory
    jmp PMM_Free_Pages_Reload_Map
  
  PMM_Free_Pages_Loop_End:
    inc rcx
    jmp PMM_Free_Pages_Loop
  
  PMM_Free_Pages_Reload_Map:
    cmp r11, 1
    jne PMM_Free_Pages_Error
    call PMM_Merge_Of_Regions
    call PMM_Clear_Empty_Regions
    mov rax, 0                                        ; good code
    jmp PMM_Free_Pages_End
  
  PMM_Free_Pages_Error:
    mov rax, 1                                        ; not finded descriptor, wrong address
    
  PMM_Free_Pages_End:
    ret

