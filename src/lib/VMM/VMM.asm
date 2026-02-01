VMM_Init:
  call CPUID_PLM5_Supporting
  cmp rax, 1                  ; PLM5 is supporting ?
  jne VMM_Init_Set_PLM4
  
  lea rbx, [VMM_Create_Map_PLM5]
  mov [VMM_Create_Map_Pointer], rbx
  lea rbx, [VMM_Delete_Map_PLM5]
  mov [VMM_Delete_Map_Pointer], rbx
  lea rbx, [VMM_Map_PLM5]
  mov [VMM_Map_Pointer], rbx
  lea rbx, [VMM_Unmap_PLM5]
  mov [VMM_Unmap_Pointer], rbx
  ret
  
  VMM_Init_Set_PLM4:
    lea rbx, [VMM_Create_Map_PLM4]
    mov [VMM_Create_Map_Pointer], rbx
    lea rbx, [VMM_Delete_Map_PLM4]
    mov [VMM_Delete_Map_Pointer], rbx
    lea rbx, [VMM_Map_PLM4]
    mov [VMM_Map_Pointer], rbx
    lea rbx, [VMM_Unmap_PLM4]
    mov [VMM_Unmap_Pointer], rbx
    ret
;--------------------------------
VMM_Create_Map:
  jmp [VMM_Create_Map_Pointer]

VMM_Create_Map_PLM4:
  ;Inp
  ;rax - pointer phys address to block bytes for plm4
  ret
  
VMM_Create_Map_PLM5:
  VMM_CM_PLM5_Loop_Init:
    xor rcx, rcx
    
  VMM_CM_PLM5_Loop:
    cmp rcx, 512                                       ; 512 records in table
    je VMM_Create_Map_PLM5_End
    
    mov qword [rax + rcx], 0x8000000000000000          ; Empty entry in the table
    
  VMM_CM_PLM5_Loop_Inc:
    add rcx, 8
    jmp VMM_CM_PLM5_Loop
    
  VMM_Create_Map_PLM5_End:  
    ret
;--------------------------------
VMM_Delete_Map:
  jmp [VMM_Delete_Map_Pointer]
  
VMM_Delete_Map_PLM4:
  ret
VMM_Delete_Map_PLM5:
  VMM_DM_PLM5_Loop_Init:
    
  ret
;--------------------------------
VMM_Map:
  jmp [VMM_Map_Pointer]
  
VMM_Map_PLM4:
  ret
VMM_Map_PLM5:
  ret
;-------------------------------- 
VMM_Unmap:
  jmp [VMM_Unmap_Pointer]
  
VMM_Unmap_PLM4:
  ret
VMM_Unmap_PLM5:
  ret

