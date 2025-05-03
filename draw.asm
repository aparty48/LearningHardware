  
  mov ebx, 0xff333333
  call Fill
    
  mov r8, 71
  mov r10, 0
  mov r11, 0
  mov r12d, 0xff000000
  call DrawChar
  mov r8, 72
  mov r10, 6
  mov r11, 0
  mov r12d, 0xff000000
  call DrawChar
  
  mov r8, 127
  mov r10, 0
  mov r11, 8
  mov r12d, 0xffff0000
  call DrawChar
  mov r8, 127
  mov r10, 6
  mov r11, 8
  mov r12d, 0xff00ff00
  call DrawChar
  mov r8, 127
  mov r10, 12
  mov r11, 8
  mov r12d, 0xff0000ff
  call DrawChar
  
  hlt
    
;3281
Fill:
  mov rcx, [FB]
  mov rax, [FBS]
  FillLoop:
    dec rax
    dec rax
    dec rax
    dec rax
    mov [rcx+rax], ebx
    jnz FillLoop
  ret
;-----------------------------------------------------------------------------
DrawChar:
  ;r8 регистр это index на символ который надо отрисовать
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
  lea rcx, [chars]
  mov rbx, 35
  mul rbx
  add rcx, rax
  mov r8, rcx
  
  DrawCharLoop:
    ;calc color
    mov rax, r9
    add rax, r8
    xor rcx, rcx
    mov cl, [rax]
    mov rbx, 0
    cmp rcx, rbx
    je DrawCharInc     ;skip draw
  
  ;calc offset pixels
    xor rdx, rdx
    mov rax, r9
    mov rbx, 5
    div rbx
    
  ;calc full pos pixels
    mov rcx, rdx
    add rax, r11   ;y
    add rcx, r10   ;x
    
  ;check out range
    mov rbx, 640
    cmp rax, rbx
    jnl DrawCharInc
    mov rbx, 800
    cmp rcx, rbx
    jnl DrawCharInc
  
  ;calc address pixel
    mov rbx, 800
    mul rbx
    add rax, rcx
    mov rbx, 4
    mul rbx
    
  ;draw
    mov rbx, [FB]
    add rbx, rax
    mov [rbx], r12d
    
  DrawCharInc:
    inc r9
    mov rbx, 35
    cmp r9, rbx
    jne DrawCharLoop
    
    pop r8

  ret
     
