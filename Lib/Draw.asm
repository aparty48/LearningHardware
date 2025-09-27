; DAE code ----------------------------------------------------------------
DAE_Print:
  ;Input
  ;rax - pointer to massage
  ;Used:
  ;rbx - counter
  ; 0x00 in massage, is end of text
  
  DAE_Print_Loop:
    xor r8, r8
    mov r8b, [rax]
    cmp r8b, 31
    jl DAE_Print_EscCodes
    
    ;mov rbx, [DAE_X]
    ;cmp rbx, DAE_Display_Symbols_Width 
    ;je DAE_Print_Loop
    
    push rax
    ;mov r8, rcx                    ; symbol
    mov r10, [DAE_X]               ; x
    mov r11, [DAE_Y]               ; y
    mov r12d, [DAE_Color]          ; color
    call DAE_DrawChar
    
    pop rax
    inc rax
    mov rcx, [DAE_Display_Width]
    sub rcx, DAE_Symbol_Width
    mov rbx, [DAE_X]
    cmp rbx, rcx
    jnl DAE_Print_Loop
    mov rcx, DAE_Symbol_Width + 1
    add rbx, rcx
    mov [DAE_X], rbx
    
    jmp DAE_Print_Loop
    
  DAE_Print_EscCodes:
    cmp r8b, 0
    je DAE_Print_End
    cmp r8b, 8
    je DAE_Print_b_code
    cmp r8b, 10
    je DAE_Print_n_code 
    cmp r8b, 12
    je DAE_Print_w_code 
    cmp r8b, 13
    je DAE_Print_r_code
    
    inc rax
    jmp DAE_Print_Loop
  
  DAE_Print_b_code:
    inc rax
    mov rbx, [DAE_X]
    cmp rbx, 0
    jl DAE_Print_Loop
    mov rcx, [DAE_Display_Width]
    inc rcx
    sub rbx, rcx
    mov [DAE_X], rbx
    jmp DAE_Print_Loop
  
  DAE_Print_n_code:
    inc rax
    mov rcx, [DAE_Display_Heigth]
    sub rcx, DAE_Symbol_Height
    mov rbx, [DAE_Y]
    cmp rbx, rcx
    jnl DAE_Print_Loop
    mov rcx, DAE_Symbol_Height + 1
    add rbx, rcx
    mov [DAE_Y], rbx
    jmp DAE_Print_Loop
  
  DAE_Print_w_code:
    inc rax
    mov rbx, [DAE_Y]
    cmp rbx, 0
    jl DAE_Print_Loop
    mov rcx, [DAE_Display_Heigth]
    inc rcx
    sub rbx, rcx
    mov [DAE_Y], rbx
    jmp DAE_Print_Loop
  
  DAE_Print_r_code:
    inc rax
    mov rbx, 0
    mov [DAE_X], rbx
    jmp DAE_Print_Loop
    
  DAE_Print_End:
    ret
;------------------------------------------------------------------------------------
DAE_Convert_DQ_To_HEX_Text:
  ;rax - bytes to convert
  push rax
  
  
  DAE_Convert_DQ_To_HEX_Text_Loop:
  xor rax, rax
  mov al, [rsp + 0]
  call DAE_Convert_Byte_To_HEX_Text
  lea rbx, [DAE_HEX_Text]
  mov [rbx + 15], al
  mov [rbx + 14], ah
  
  
  xor rax, rax
  mov al, [rsp + 1]
  call DAE_Convert_Byte_To_HEX_Text
  lea rbx, [DAE_HEX_Text]
  mov [rbx + 13], al
  mov [rbx + 12], ah
  
  
  xor rax, rax
  mov al, [rsp + 2]
  call DAE_Convert_Byte_To_HEX_Text
  lea rbx, [DAE_HEX_Text]
  mov [rbx + 11], al
  mov [rbx + 10], ah
  
  
  xor rax, rax
  mov al, [rsp + 3]
  call DAE_Convert_Byte_To_HEX_Text
  lea rbx, [DAE_HEX_Text]
  mov [rbx + 9], al
  mov [rbx + 8], ah
  
  
  xor rax, rax
  mov al, [rsp + 4]
  call DAE_Convert_Byte_To_HEX_Text
  lea rbx, [DAE_HEX_Text]
  mov [rbx + 7], al
  mov [rbx + 6], ah
  
  
  xor rax, rax
  mov al, [rsp + 5]
  call DAE_Convert_Byte_To_HEX_Text
  lea rbx, [DAE_HEX_Text]
  mov [rbx + 5], al
  mov [rbx + 4], ah
  
  
  xor rax, rax
  mov al, [rsp + 6]
  call DAE_Convert_Byte_To_HEX_Text
  lea rbx, [DAE_HEX_Text]
  mov [rbx + 3], al
  mov [rbx + 2], ah
  
  
  xor rax, rax
  mov al, [rsp + 7]
  call DAE_Convert_Byte_To_HEX_Text
  lea rbx, [DAE_HEX_Text]
  mov [rbx + 1], al
  mov [rbx + 0], ah
  
  DAE_Convert_DQ_To_HEX_Text_End:
    pop rax
    ret
;----------------------------------------------------------------------------------
DAE_Convert_Byte_To_HEX_Text:
  ;Input
  ;al - byte
  ;Output
  ;ax - text
  xor rbx, rbx
  
  mov bl, al
  and bl, 0x0F 
  lea rcx, [DAE_Convert_Byte_To_HEX_Text_hexes]
  add rcx, rbx
  mov bl, [rcx]
  shl rbx, 8
  or rax, rbx
  xor rbx, rbx
  
  mov bl, al
  and bl, 0xF0
  shr bl, 4
  lea rcx, [DAE_Convert_Byte_To_HEX_Text_hexes]
  add rcx, rbx
  mov bl, [rcx]
  shl rbx, 16
  or rax, rbx
  
  shr rax, 8
  jmp DAE_Convert_Byte_To_HEX_Text_End
  
  DAE_Convert_Byte_To_HEX_Text_hexes: 
    db "0123456789ABCDEF"
    
  DAE_Convert_Byte_To_HEX_Text_End:
    ret
;-----------------------------------------------------------------------------
DAE_PrintHi:
  mov ebx, 0xffffffff
  call DAE_FillDisplay
    
  mov r8, 72
  mov r10, 0
  mov r11, 0
  mov r12d, 0xff000000
  call DAE_DrawChar
  mov r8, 73
  mov r10, 6
  mov r11, 0
  mov r12d, 0xff000000
  call DAE_DrawChar
  
  ret
;----------------------------------------------------------------------------
DAE_FillDisplay:
  ;Input:
  ;ebx - color  0xAARRGGBB
  
  mov rcx, [DAE_FrameBuffer]
  mov rax, [DAE_FrameBufferSize]
  DAE_FillDisplayLoop:
    dec rax
    dec rax
    dec rax
    dec rax
    mov [rcx+rax], ebx
    jnz DAE_FillDisplayLoop
  ret
;--------------------------------------------------------------------------  
DAE_DrawChar:
  ;Input:
  ;r8 char
  ;r9 counter
  ;r10 coordiates x
  ;r11 coordinaes y
  ;r12 - color   0x00000000AARRGGBB
  ;jg - ax > bx
  ;je - ax = bx
  ;jl - ax < bx
  ;adr = y * sizeDisplayY + x
  
  xor r9, r9
  push r8
  
  ;get address char
  mov rax, r8
  lea rcx, [DAE_Chars]
  mov rbx, DAE_Symbol_Height * DAE_Symbol_Width
  mul rbx
  add rcx, rax
  mov r8, rcx
  
  DAE_DrawCharLoop:
    ;calc color
    mov rax, r9
    add rax, r8
    xor rcx, rcx
    mov cl, [rax]
    mov rbx, 0
    cmp rcx, rbx
    je DAE_DrawCharInc     ;skip draw
  
  ;calc offset pixels
    xor rdx, rdx
    mov rax, r9
    mov rbx, DAE_Symbol_Width
    div rbx
    
  ;calc full pos pixels
    mov rcx, rdx
    add rax, r11   ;y
    add rcx, r10   ;x
    
  ;check out range
    mov rbx, [DAE_Display_Heigth]
    cmp rax, rbx
    jnl DAE_DrawCharInc
    mov rbx, [DAE_Display_Width]
    cmp rcx, rbx
    jnl DAE_DrawCharInc
  
  ;calc address pixel
    xor rbx, rbx
    mov ebx, [DAE_Display_Width]
    mul rbx
    add rax, rcx
    mov rbx, 4                   ;1 pixel - 4 bytes, argb
    mul rbx
    
  ;draw
    mov rbx, [DAE_FrameBuffer]
    add rbx, rax
    mov [rbx], r12d
    
  DAE_DrawCharInc:
    inc r9
    mov rbx, DAE_Symbol_Height * DAE_Symbol_Width
    cmp r9, rbx
    jne DAE_DrawCharLoop
    
    pop r8
    ret
;--------------------------------------------------------------------
