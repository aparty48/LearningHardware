VMM_Create_Map_PML5:
  VMM_CM_PML5_Loop_Init:
    xor rcx, rcx
    
  VMM_CM_PML5_Loop:
    cmp rcx, 512 * 8                                   ; 512 records of 8 byte each in table
    je VMM_Create_Map_PML5_End
    
    mov qword [rax + rcx], 0x0                         ; Empty entry in the table
    
  VMM_CM_PML5_Loop_Inc:
    add rcx, 8
    jmp VMM_CM_PML5_Loop
    
  VMM_Create_Map_PML5_End:  
    ret
