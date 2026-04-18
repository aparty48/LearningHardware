VMM_Map_PML5:
  push rax
  push rbx
  push rcx
  push rdx
  
  VMM_Map_PML5_Get_PML5_index:
    mov r8, rax
    mov r9, 0b000000_111111111_000000000_000000000_000000000_000000000_000000000000
    and r8, r9
    shr r8, 39                                         ; index in PML5
    
    mov r10, [rcx + r8 * 8]                            ; entry from PML5
    
    test r10, 0x1                                        
    jz VMM_Map_PML5_Alloc_and_create_pml4              ; if P != 1
  
  VMM_Map_PML5_PML4_Entry_exists:
    mov r9, [VMM_4KB_Page_Entry_Mask]
    and r10, r9                                        ; phys address PML4
    jmp VMM_Map_PML5_Get_PML4_index
  
  VMM_Map_PML5_Alloc_and_create_pml4:                  ; if P != 1
    mov rax, 1
    mov rbx, 0xff
    push r8
    call PMM_Allocate_Pages
    pop r8
    cmp rbx, 0x0
    jne VMM_Map_PML5_Allocation_failed
    mov r11, rax                                       ; save phys address pdpt
    
    mov r9, [VMM_4KB_Page_Entry_Mask]
    and rax, r9                                        ; clear other bits
    
    mov r9, 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0111
    or rax, r9                                         ; set flags
    
    mov rcx, [rsp + 8]                                 ; restore values, PML5 phys addres
    mov [rcx + r8 * 8], rax                            ; write entry in plm4 table
    
    mov rax, [rsp + 24]                                ; restore values, phys address
    mov rbx, [rsp + 16]                                ; restore values, virtual address
    mov rdx, [rsp]                                     ; restore values, attributes
    
    xor rcx, rcx                                       ; init counter
    VMM_Map_PML5_Alloc_and_create_pml4_loop:
      cmp rcx, 512 * 8
      je VMM_Map_PML5_Get_PML4_index
      
      mov qword [r11 + rcx], 0x0                       ; set 0 in all entries
      
      add rcx, 8
      jmp VMM_Map_PML5_Alloc_and_create_pml4_loop
    
  
  VMM_Map_PML5_Get_PML4_index:                         ; r11 - phys address pdpt table
    mov r8, rax
    mov r9, 0b000000_000000000_111111111_000000000_000000000_000000000_000000000000
    and r8, r9
    shr r8, 39                                         ; index in PML4
    
    mov r11, [r11 + r8 * 8]                            ; entry from PML4
                                                       ; 8 - is length of entry
  
    test r11, 0x1                                        
    jz VMM_Map_PML5_Alloc_and_create_pdpt              ; if P != 1
  
  VMM_Map_PML5_PDPT_Entry_exists:
    mov r9, [VMM_4KB_Page_Entry_Mask]
    mov r10, r11                                       ; use entry
    and r10, r9                                        ; phys address PDPT
    jmp VMM_Map_PML5_Get_PDPT_index
  
  VMM_Map_PML5_Alloc_and_create_pdpt:                  ; if P != 1
    mov rax, 1
    mov rbx, 0xff
    push r8
    call PMM_Allocate_Pages
    pop r8
    cmp rbx, 0x0
    jne VMM_Map_PML5_Allocation_failed
    mov r10, rax                                       ; save phys address pdpt
    
    mov r9, [VMM_4KB_Page_Entry_Mask]
    and rax, r9                                        ; clear other bits
    
    mov r9, 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0111
    or rax, r9                                         ; set flags
    
    mov rcx, [rsp + 8]                                 ; restore values, PML5 phys addres
    mov [rcx + r8 * 8], rax                            ; write entry in plm4 table
    
    mov rax, [rsp + 24]                                ; restore values, phys address
    mov rbx, [rsp + 16]                                ; restore values, virtual address
    mov rdx, [rsp]                                     ; restore values, attributes
    
    xor rcx, rcx                                       ; init counter
    VMM_Map_PML5_Alloc_and_create_pdpt_loop:
      cmp rcx, 512 * 8
      je VMM_Map_PML5_Get_PDPT_index
      
      mov qword [r10 + rcx], 0x0                       ; set 0 in all entries
      
      add rcx, 8
      jmp VMM_Map_PML5_Alloc_and_create_pdpt_loop
  
  
  VMM_Map_PML5_Get_PDPT_index:                         ; r10 - phys address pdpt table
    mov r8, rax
    mov r9, 0b000000_000000000_000000000_111111111_000000000_000000000_000000000000
    and r8, r9
    shr r8, 30                                         ; get index in pdpt
    mov r9, [r10 + r8 * 8]                             ; get entry from pdpt
    
    test r9, 0x1                                       
    jnz VMM_Map_PML5_Entry_In_PDPT_exists              ; if P != 0
    
    VMM_Map_PML5_Entry_In_PDPT_not_exists:
      test rdx, 0b100_0000_0000
      jz VMM_Map_PML5_Alloc_and_create_pd              ; if 1Gb Page == 0
      
      VMM_Map_PML5_Create_1Gb_Page_Entry:
        mov r9, 0b1111_1000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_1001_0001_1110
        and rdx, r9                                    ; clear other bits
        
        mov r9, 0b1
        or rdx, r9                                     ; set P bit = 1
        mov r9, 0b10000000
        or rdx, r9                                     ; set PS bit = 1
        
        mov r9, [VMM_1GB_Page_Entry_Mask]
        and rbx, r9
        or rbx, rdx
	
	mov [r10 + r8 * 8], rbx                        ; write
	;invlpg [rax]                                  ; update TLB
	
	pop rdx
	pop rcx
	pop rbx
	pop rax
	xor rax, rax                                   ; return code - 0
	ret
        
      VMM_Map_PML5_Alloc_and_create_pd:
        mov rax, 1                                     ; count pages
        mov rbx, 0xff                                  ; type pages
        push r10
        push r8
        call PMM_Allocate_Pages
        pop r8
        pop r10
        cmp rbx, 0x0                                   ; check return code, 0 is good
        jne VMM_Map_PML5_Allocation_failed
        mov r12, rax                                   ; save phys address pd table
    
        mov r9, [VMM_4KB_Page_Entry_Mask]
        and rax, r9 
        mov r9, 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0111
        or rax, r9                                     ; set flags
        
        mov [r10 + r8 * 8], rax                        ; write entry in pdpt table

        mov rax, [rsp + 24]                            ; restore values, phys address
        mov rbx, [rsp + 16]                            ; restore values, virtual address
        mov rdx, [rsp]                                 ; restore values, attributes
    
        xor rcx, rcx                                   ; init counter
        VMM_Map_PML5_Alloc_and_create_pd_loop:
          cmp rcx, 512 * 8
          je VMM_Map_PML5_Get_PD_index
      
          mov qword [r12 + rcx], 0x0                   ; set 0 in all entries
      
          add rcx, 8
          jmp VMM_Map_PML5_Alloc_and_create_pd_loop
        
        jmp VMM_Map_PML5_Get_PD_index
        
    VMM_Map_PML5_Entry_In_PDPT_exists:
      mov rdx, [rsp]                                   ; restore values, attributes
      test rdx, 0b100_0000_0000
      jnz VMM_Map_PML5_Entry_In_PDPT_exists_error      ; if 1Gb Page != 1
      
      VMM_Map_PML5_Entry_In_PDPT_exists_not_error:
        mov r11, [VMM_4KB_Page_Entry_Mask]
        mov r12, r9                                    ; use entry from pdpt
        and r12, r11                                   ; final phys address pd
        jmp VMM_Map_PML5_Get_PD_index
      
      VMM_Map_PML5_Entry_In_PDPT_exists_error:
        pop rdx
        pop rcx
        pop rbx
        pop rax
        mov rax, 0x2                                   ; 1 Gb entry is exists error code
        ret
      
      
  VMM_Map_PML5_Get_PD_index:                           ; r12 - phys address pd table
    mov r8, rax
    mov r9, 0b000000_000000000_000000000_000000000_111111111_000000000_000000000000
    and r8, r9
    shr r8, 21                                         ; get index in pd
    mov r9, [r12 + r8 * 8]                             ; get entry from pd
    
    test r9, 0x1
    jnz VMM_Map_PML5_Get_PD_Entry_Exists               ; if P != 0
    
    VMM_Map_PML5_Get_PD_Entry_Not_Exists:
      mov rdx, [rsp]                                   ; restore values, attributes
      test rdx, 0b10_0000_0000
      jz VMM_Map_PML5_Alloc_and_create_pt              ;if 2Mb Page != 1
      
      VMM_Map_PML5_Create_2Mb_Page_Entry:
        mov r9, 0b1111_1000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_1001_0001_1110
        and rdx, r9                                    ; clear other bits
        
        mov r9, 0b1
        or rdx, r9                                     ; set P bit = 1
        mov r9, 0b10000000
        or rdx, r9                                     ; set PS bit = 1
        
        mov r9, [VMM_2MB_Page_Entry_Mask]
        and rbx, r9                                    ; use mask on phys address from args
	or rbx, rdx                                    ; final entry
	
	mov [r12 + r8 * 8], rbx                        ; write
	;invlpg [rax]                                  ; update TLB
	
	pop rdx
	pop rcx
	pop rbx
	pop rax
	xor rax, rax                                   ; return code - 0
	ret
  
      VMM_Map_PML5_Alloc_and_create_pt:
        mov rax, 1                                     ; count pages
        mov rbx, 0xff                                  ; type pages
        push r12
        push r10
        push r8
        call PMM_Allocate_Pages
        pop r8
        pop r10
        pop r12
        cmp rbx, 0x0                                   ; check return code, 0 is good
        jne VMM_Map_PML5_Allocation_failed
        mov r13, rax                                   ; save phys address pd table
    
        mov r9, [VMM_4KB_Page_Entry_Mask]
        and rax, r9
        mov r9, 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0111
        or rax, r9                                     ; set flags
        
        mov [r12 + r8 * 8], rax                        ; write entry in pd table

        mov rax, [rsp + 24]                            ; restore values, phys address
        mov rbx, [rsp + 16]                            ; restore values, virtual address
        mov rdx, [rsp]                                 ; restore values, attributes
    
        xor rcx, rcx                                   ; init counter
        VMM_Map_PML5_Alloc_and_create_pt_loop:
          cmp rcx, 512 * 8
          je VMM_Map_PML5_Get_PT_index
      
          mov qword [r13 + rcx], 0x0                   ; set 0 in all entries
      
          add rcx, 8
          jmp VMM_Map_PML5_Alloc_and_create_pt_loop
        
        jmp VMM_Map_PML5_Get_PT_index
        
  
    VMM_Map_PML5_Get_PD_Entry_Exists:
      mov rdx, [rsp]                                   ; restore values, attributes
      test rdx, 0b10_0000_0000
      jnz VMM_Map_PML5_Get_PD_Entry_Exists_Error       ; if 2Mb Page != 0
      
      VMM_Map_PML5_Get_PD_Entry_Exists_Not_Error:
        mov r13, r9                                    ; use entry from pd
        mov r9, [VMM_4KB_Page_Entry_Mask]
        and r13, r9                                    ; final phys address pt
        jmp VMM_Map_PML5_Get_PT_index
        
      VMM_Map_PML5_Get_PD_Entry_Exists_Error:
        pop rdx
        pop rcx
        pop rbx
        pop rax
        mov rax, 0x3                                   ; 2 Mb entry is exists error code
        ret

  
  VMM_Map_PML5_Get_PT_index:                           ; r13 - phys address pt table
    mov r8, rax
    mov r9, 0b000000_000000000_000000000_000000000_000000000_111111111_000000000000
    and r8, r9
    shr r8, 12                                         ; get index in pt
    mov r9, [r13 + r8 * 8]                             ; get entry from pt
    
    test r9, 0x1
    jnz VMM_Map_PML5_Get_PT_Error                      ; if P == 1
    VMM_Map_PML5_Get_PT_Entry_Not_Exists:
        mov r9, 0b1111_1000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1001_1001_1110
        and rdx, r9                                    ; clear other bits
        
        mov r9, 0b1
        or rdx, r9                                     ; set P bit = 1
        
        mov r9, [VMM_4KB_Page_Entry_Mask]
	and rbx, r9
	or rbx, rdx                                    ; final entry
	
	mov [r13 + r8 * 8], rbx                        ; write
	;invlpg [rax]                                  ; update TLB
	
	pop rdx
	pop rcx
	pop rbx
	pop rax
	xor rax, rax                                   ; return code - 0
	ret

    VMM_Map_PML5_Get_PT_Error:
      pop rdx
      pop rcx
      pop rbx
      pop rax
      mov rax, 0x4                                   ; 4 Kb entry is exists error code
      ret


  VMM_Map_PML5_Allocation_failed:
    pop rdx
    pop rcx
    pop rbx
    pop rax
    mov rax, 0x1                                       ; Failed to allocate frame from tables error code
    ret
