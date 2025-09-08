MEM_Copy_Pages:
  ;Input
  ;rax - address source
  ;rbx - address destination
  ;rcx - count pages
  MEM_Copy_Pages_end:
    ret
;---------------------------------------------------
MEM_Copy_Bytes:
  ;Input
  ;rax - address source
  ;rbx - address destination
  ;rcx - count bytes
  ;Used
  ;rdx - 
  
  dec rcx
  
  MEM_Copy_Bytes_loop:
    mov dl, [rax + rcx]
    mov [rbx + rcx], dl
    dec rcx
    jnz MEM_Copy_Bytes_loop
    
    mov dl, [rax]
    mov [rbx], dl
    
  MEM_Copy_Bytes_end:
    ret
;----------------------------------------------------
MEM_Calc_Needed_Pages_From_Count_Bytes:
  ;Input: 
  ;rax - count bytes
  ;Output
  ;rax - count pages
  ;Used:
  ;rax, rcx, rdx
  add rax, Page_Size - 1
  xor rdx, rdx
  mov rcx, Page_Size
  div rcx
  ret
;--------------------------------------------------
MEM_Read_EFI_MemMap:
  ;Input:
  ;rax - descriptor size
  ;rbx - discriptor version
  ;rcx - pointer on map
  ;rdx - size of map in bytes
  MEM_REMM_start:
    push rcx
    push rdx
    call MEM_CheckVersionOf_EFI_MEMMAP
    pop rdx
    pop rcx
    xor rbx, rbx
    cmp r8, rbx
    jne MEM_REMM_end
    
  MEM_REMM_calc_count_elements:
    mov rbx, 48
    mov rax, rdx
    xor rdx, rdx
    div rbx
  
  ;rax - current descriptor address
  ;rbx - count descriptors in map
  ;rcx - pointer on map
  ;r8  - counter, current descriptor index
  mov rbx, rax
  xor r8, r8
  mov r10, 7
  
  MEM_REMM_loop:
    MEM_REMM_loop_check:
      cmp r8, rbx
      jnl MEM_REMM_end
      
    MEM_REMM_loop_body:
      MEM_REMM_loop_calc_address_descriptor:
        mov r9, 48
        xor rdx, rdx
        mov rax, r8
        mul r9
        add rax, rcx
        
      MEM_REMM_loop_a:
        push rbx
        push rcx
        push r8
        push r10
        mov rax, [rax]
        call DAE_Convert_DQ_To_HEX_Text
        lea rax, [DAE_HEX_Text]
        call DAE_Print
        lea rax, [MEM_Mes_4]
        call DAE_Print
        pop r10
        pop r8
        pop rcx
        pop rbx
        
        dec r10
        jnz MEM_REMM_loop_end
        push rbx
        push rcx
        push r8
        push r10
        lea rax, [MEM_Mes_3]
        call DAE_Print
        pop r10
        pop r8
        pop rcx
        pop rbx
        mov r10, 7
      
    MEM_REMM_loop_end:
      inc r8
      jmp MEM_REMM_loop
    
    
  MEM_REMM_end:
    ret
;-------------------------------------------------------------------
MEM_CheckVersionOf_EFI_MEMMAP:
  ;Input:
  ;rax - descriptor size
  ;rbx - descriptor version
  ;Output:
  ;r8 - 0 if ver == 1 && size == 48
  ;Used:
  xor r8, r8
  push r8
  
  MEM_CVEMM_ver_0:
    cmp rbx, 0
    je MEM_CVEMM_size
  MEM_CVEMM_ver_1:
    cmp rbx, 1
    je MEM_CVEMM_size
    
  MEM_CVEMM_ver_err:
    inc qword [rsp]
    inc qword [rsp]
    push rax
    push rbx
    lea rax, [MEM_Mes_1]
    call DAE_Print
    pop rax
    call DAE_Convert_DQ_To_HEX_Text
    lea rax, [DAE_HEX_Text]
    call DAE_Print
    lea rax, [MEM_Mes_3]
    call DAE_Print
    pop rax
  
  MEM_CVEMM_size:
    cmp rax, 48
    je MEM_CVEMM_end
    inc qword [rsp]
    push rax
    lea rax, [MEM_Mes_2]
    call DAE_Print
    pop rax
    call DAE_Convert_DQ_To_HEX_Text
    lea rax, [DAE_HEX_Text]
    call DAE_Print
    lea rax, [MEM_Mes_3]
    call DAE_Print
    
  MEM_CVEMM_end:
    pop r8
    ret
    


