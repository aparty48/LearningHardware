%macro Print 1
  %ifstr %1
    push rax
    push rbx
    push rdx
    push r8
    lea rbx, [%%Print_str]
    call COM_Print
    pop r8
    pop rdx
    pop rbx
    pop rax
    jmp %%Print_end
    %%Print_str: db %1, 0
    %%Print_end:
  %else
    push rax
    push rbx
    push rcx
    push rdx
    push r8
    mov rax, %1
    call DAE_Convert_DQ_To_HEX_Text
    lea rbx, [DAE_HEX_Text]
    call COM_Print
    pop r8
    pop rdx
    pop rcx
    pop rbx
    pop rax
  %endif
%endmacro

%macro Printn 1
  %ifstr %1
    push rax
    push rbx
    push rdx
    push r8
    lea rbx, [%%Print_str]
    call COM_Print
    pop r8
    pop rdx
    pop rbx
    pop rax
    jmp %%Print_end
    %%Print_str: db %1, 10, 0
    %%Print_end:
  %else
    push rax
    push rbx
    push rcx
    push rdx
    push r8
    mov rax, %1
    call DAE_Convert_DQ_To_HEX_Text
    lea rbx, [DAE_HEX_Text]
    call COM_Print
    lea rbx, [%%Print_str]
    call COM_Print
    jmp %%Print_end
    %%Print_str: db 10, 0
    %%Print_end:
    pop r8
    pop rdx
    pop rcx
    pop rbx
    pop rax
  %endif
%endmacro
