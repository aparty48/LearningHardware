COM_Print:
  ;rbx - pointer to massage
  ;Used: r8, rdx, rax
  COM_Print_Loop:
    xor r8, r8
    mov r8b, [rbx]
    cmp r8b, 0
    je COM_Print_end
      
    COM_Print_out_byte:
      mov dx, 0x3FD
      in al, dx
      test al, 0x20
      jz COM_Print_out_byte
      mov dx, 0x3F8
      mov al, r8b
      out dx, al
      inc rbx
      jmp COM_Print_Loop
        
  COM_Print_end: 
    ret
