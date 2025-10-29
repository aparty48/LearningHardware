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
    mov rbx, [rsp]
    xor rax, rax
    mov eax, [rbx + 0x10]            ;addr 
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
