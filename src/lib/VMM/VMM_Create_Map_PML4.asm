VMM_Create_Map_PML4:
  ;Inp
  ;rax - pointer phys address to block bytes for PML4
  VMM_CM_PML4_Loop_Init:
    xor rcx, rcx
    
  VMM_CM_PML4_Loop:
    cmp rcx, 512 * 8                                   ; 512 records of 8 byte each in table
    jnb VMM_Create_Map_PML4_End
    
    mov [rax + rcx], 0x0                               ; Empty entry in the table
    
  VMM_CM_PML4_Loop_Inc:
    add rcx, 8
    jmp VMM_CM_PML4_Loop
    
  VMM_Create_Map_PML4_End:  
    ret
