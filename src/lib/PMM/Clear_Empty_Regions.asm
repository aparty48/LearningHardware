PMM_Clear_Empty_Regions:
  ;rbx - address to write
  ;rcx - counter Reader
  ;r8 - address PMM map
  ;r9 - count descriptors
  PMM_Clear_Empty_Regions_Loop_Init:
    mov rbx, [PMM_Address_Map]
    xor rcx, rcx
    mov r8, [PMM_Address_Map]
    mov r9, [PMM_Count_Descriptors]
    
  PMM_Clear_Empty_Regions_Loop:
    cmp rcx, r9
    jnl PMM_Clear_Empty_Regions_end
    xor rdx, rdx
    mov rax, rcx
    mov r10, 20
    mul r10
    add rax, r8
    
    mov rdx, [rax + 0x8]    ;get number of page from descriptor
    cmp rdx, 0
    je PMM_Clear_Empty_Regions_Loop_end
    
    mov rdx, [rax + 0x0]
    mov [rbx + 0x0], rdx
    mov rdx, [rax + 0x8]
    mov [rbx + 0x8], rdx
    mov edx, [rax + 0x10]
    mov [rbx + 0x10], edx

    add rbx, 20
    
  PMM_Clear_Empty_Regions_Loop_end:
    inc rcx
    jmp PMM_Clear_Empty_Regions_Loop
    
  PMM_Clear_Empty_Regions_end:
    ; Out:
    mov r10, [PMM_Address_Map]
    sub rbx, r10
    xor rdx, rdx
    mov rax, rbx
    mov r10, 20
    div r10
    mov [PMM_Count_Descriptors], rax
    ret

