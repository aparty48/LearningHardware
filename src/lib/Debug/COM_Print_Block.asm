COM_Print_Block:
  ;rax - count bytes
  ;rbx - adderess
  ;cl - settings   (count columns)
  ;Used: rdx - counter bytes, r8, r9b - counter columns
  
  COM_Print_Block_Print_Addr:
    push rax
    push rbx
    push rcx
    push rdx
    push r8
    push r9
    
    mov rax, [rsp + 32]              ;address
    call DAE_Convert_DQ_To_HEX_Text
    lea rbx, [DAE_HEX_Text]
    call COM_Print
      
    lea rbx, [COM_Print_Block_Mes1]
    call COM_Print
    
    pop r9
    pop r8
    pop rdx
    pop rcx
    pop rbx
    pop rax
    
  COM_Print_Block_Loop_Init:
    xor r9b, r9b                     ; reset column counter
    xor rdx, rdx                     ; reset counter
    
  COM_Print_Block_Loop:
    cmp rdx, rax
    jnb COM_Print_Block_End
    cmp r9b, cl
    jb COM_Print_Block_Loop_Move
    xor r9b, r9b
    
    COM_Print_Block_Loop_Print_Addr:
      push rax
      push rbx
      push rcx
      push rdx
      push r8
      push r9
    
      lea rbx, [COM_Print_Block_Mes3]
      call COM_Print
    
      mov rax, [rsp + 32]              ; address
      mov rbx, [rsp + 16]              ; count bytes
      add rax, rbx
      call DAE_Convert_DQ_To_HEX_Text
      lea rbx, [DAE_HEX_Text]
      call COM_Print
      
      lea rbx, [COM_Print_Block_Mes1]
      call COM_Print
    
      pop r9
      pop r8
      pop rdx
      pop rcx
      pop rbx
      pop rax
    
    COM_Print_Block_Loop_Move:
      push rax
      push rbx
      push rcx
      push rdx
      push r8
      push r9
      
      lea rbx, [COM_Print_Block_Mes2]
      call COM_Print
      
      mov rax, [rsp + 32]              ;address start of block
      mov rbx, [rsp + 16]              ;counter bytes
      mov rax, [rax + rbx]
      call DAE_Convert_DQ_To_HEX_Text
      lea rbx, [DAE_HEX_Text]
      call COM_Print
      
      pop r9
      pop r8
      pop rdx
      pop rcx
      pop rbx
      pop rax
      
    COM_Print_Block_Loop_Inc:
      add rdx, 8
      inc r9b
      jmp COM_Print_Block_Loop
    
  COM_Print_Block_End:
    lea rbx, [COM_Print_Block_Mes3]
    call COM_Print
    ret
    
COM_Print_Block_Mes1: db ":", 0
COM_Print_Block_Mes2: db " ", 0
COM_Print_Block_Mes3: db 13, 10, 0
COM_Test: db "test", 0
