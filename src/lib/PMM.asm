PMM_Init:
  ;Input:
  ;rax - descriptor size
  ;rbx - discriptor version
  ;rcx - pointer on map
  ;rdx - size of map in bytes
  PMM_Init_start:
    push rcx
    push rdx
    call PMM_CheckVersionOf_EFI_PMMMAP
    pop rdx
    pop rcx
    xor rbx, rbx
    cmp r8, rbx
    jne PMM_Init_end
    
  PMM_Init_calc_count_elements:
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
  
  PMM_Init_loop:
    PMM_Init_loop_check:
      cmp r8, rbx
      jnl PMM_Init_end
      
    PMM_Init_loop_body:
      PMM_Init_loop_calc_address_descriptor:
        mov r9, 48
        xor rdx, rdx
        mov rax, r8
        mul r9
        add rax, rcx
        
      PMM_Init_loop_a:
        push rbx
        push rcx
        push r8
        push r10
        mov rax, [rax]
        call DAE_Convert_DQ_To_HEX_Text
        lea rax, [DAE_HEX_Text]
        call DAE_Print
        lea rax, [PMM_Mes_4]
        call DAE_Print
        pop r10
        pop r8
        pop rcx
        pop rbx
        
        dec r10
        jnz PMM_Init_loop_end
        push rbx
        push rcx
        push r8
        push r10
        lea rax, [PMM_Mes_3]
        call DAE_Print
        pop r10
        pop r8
        pop rcx
        pop rbx
        mov r10, 7
        
      PMM_Init_loop_b:
        
      
    PMM_Init_loop_end:
      inc r8
      jmp PMM_Init_loop
    
    
  PMM_Init_end:
    ret
;-------------------------------------------------------------------
PMM_CheckVersionOf_EFI_PMMMAP:
  ;Input:
  ;rax - descriptor size
  ;rbx - descriptor version
  ;Output:
  ;r8 - 0 if ver == 1 && size == 48
  ;Used:
  xor r8, r8
  push r8
  
  PMM_CVEMM_ver_0:
    cmp rbx, 0
    je PMM_CVEMM_size
  PMM_CVEMM_ver_1:
    cmp rbx, 1
    je PMM_CVEMM_size
    
  PMM_CVEMM_ver_err:
    inc qword [rsp]
    inc qword [rsp]
    push rax
    push rbx
    lea rax, [PMM_Mes_1]
    call DAE_Print
    pop rax
    call DAE_Convert_DQ_To_HEX_Text
    lea rax, [DAE_HEX_Text]
    call DAE_Print
    lea rax, [PMM_Mes_3]
    call DAE_Print
    pop rax
  
  PMM_CVEMM_size:
    cmp rax, 48
    je PMM_CVEMM_end
    inc qword [rsp]
    push rax
    lea rax, [PMM_Mes_2]
    call DAE_Print
    pop rax
    call DAE_Convert_DQ_To_HEX_Text
    lea rax, [DAE_HEX_Text]
    call DAE_Print
    lea rax, [PMM_Mes_3]
    call DAE_Print
    
  PMM_CVEMM_end:
    pop r8
    ret
    
;--------------------------------------------------------------------------------------
PMM_Allocate_Pages:
  ; Input
  ; rax - count pages
  ; rbx - type page
  ret
PMM_Free_Pages:
  ret
