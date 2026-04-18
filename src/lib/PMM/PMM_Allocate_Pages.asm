PMM_Allocate_Pages:
  ; Input
  ; rax - count pages
  ; rbx - type page
  push rax
  push rbx
  PMM_Allocate_Pages_Check_Size:
    ;if [PMM_Count_Descriptors] * 20 < [PMM_Size_Map_In_Pages] * 4096 - 40
    xor rdx, rdx
    mov rax, [PMM_Count_Descriptors]
    mov r8, 20
    mul r8
    mov rcx, rax
    
    xor rdx, rdx
    mov rax, [PMM_Size_Map_In_Pages]
    mov r8, Page_Size
    mul r8
    push rax                                           ;count bytes
    sub rax, 40
    
    cmp rcx, rax
    jl PMM_Allocate_Pages_Alloc_Clear_Stack            ;if rcx < rax
    
    mov rax, [PMM_Size_Map_In_Pages]
    inc rax
    mov rbx, PMMRuntimeServicesData
    call PMM_Allocate_Pages_After_Check
      
    ;mov rax                                           - Allocate return
    ; TODO: здесь надо бы передать ошибки если будут
    mov rbx, [PMM_Address_Map]
    pop rcx                                            ;count bytes
    call MEM_Copy_Bytes
      
    mov [PMM_Address_Map], rax                         ;save new address
    inc qword [PMM_Size_Map_In_Pages]
    mov rax, rbx
    call PMM_Free_Pages
    jmp PMM_Allocate_Pages_Alloc
    
    PMM_Allocate_Pages_Alloc_Clear_Stack:
      pop rdx
      
    PMM_Allocate_Pages_Alloc:
      pop rbx
      pop rax
      call PMM_Allocate_Pages_After_Check
      
  PMM_Allocate_Pages_End:
    ret
;------------------------------------------------------------
PMM_Allocate_Pages_After_Check:
  ;Input:
  ;rax - number of page
  ;rbx - type
  ;Using:
  ;r11 - index finded descriptor
  ;r12 - flag finded
  ;[rsp + 0] - number of pages
  ;[rsp + 8] - type
  ;Out:
  ;rax - physical start address
  ;rbx - code error, 0 == no errors, 1 == not finded free region
  ;[PMM_Count_Descriptors] - add 1
  PMM_APAC_Find_Free_Region_Loop_Init:         ; for (ulong i = 0; i < PMM_Count_Descriptors; i++)
    push rbx
    push rax
    xor rcx, rcx
    mov r8, [PMM_Count_Descriptors]
    mov r9, [PMM_Address_Map]
    xor r12, r12
    
  PMM_APAC_Find_Free_Region_Loop:
    cmp rcx, r8                                ; i < PMM_Count_Descriptors
    jnl PMM_APAC_Move_Regions_Loop_Init
    
    xor rdx, rdx
    mov rax, rcx
    mov r10, 20
    mul r10
    add rax, r9                                ; PMM_Address_Map + (Desc_Size * i)
                                               ; Descriptors[i]
    
    mov edx, [rax + 0x10]                      ; get type from descriptor
    cmp edx, PMMConventionalMemory
    jne PMM_APAC_Find_Free_Region_Loop_End
    
    mov rdx, [rax + 0x8]                       ; number of pages from descriptor
    mov r10, [rsp + 0]                         ; get number of pages from stack
    cmp r10, rdx
    jg PMM_APAC_Find_Free_Region_Loop_End      ; if (NeededPages > Descriptors[i].NumberOfPages)
    jne PMM_APAC_Find_Free_Region_Loop_Else    ; if (NeededPages != Descriptors[i].NumberOfPages)
    
    pop rbx                                    ; get type from parameter
    pop rdx                                    ; clear stack
    mov [rax + 0x10], ebx                      ; set type, rdx not used
    mov rax, [rax + 0x0]                       ; return physical address
    mov rbx, 0                                 ; no errors
    jmp PMM_APAC_End
    
    PMM_APAC_Find_Free_Region_Loop_Else:
      mov r11, rcx                             ; save index
      mov r12, 0x1
      jmp PMM_APAC_Move_Regions_Loop_Init      ; break
    
  PMM_APAC_Find_Free_Region_Loop_End:
    inc rcx                                    ; i++
    jmp PMM_APAC_Find_Free_Region_Loop
    
  PMM_APAC_Move_Regions_Loop_Init:             ; for (ulong i = PMM_Count_Descriptors - 1; i >= 0; i--)
    cmp r12, 1                                 ; if (!Finded)
    jne PMM_APAC_Error_1
    ;rcx - counter
    ;r11 - index finded descriptor
    ;[rsp + 0] - number of pages
    ;[rsp + 8] - type
    mov rcx, [PMM_Count_Descriptors]
    dec rcx
    mov r8, [PMM_Count_Descriptors]
    mov r9, [PMM_Address_Map]
    
  PMM_APAC_Move_Regions_Loop:
    cmp rcx, 0
    jl PMM_APAC_Before_End                     ; i < 0
    
    xor rdx, rdx
    mov rax, rcx
    mov r10, 20
    mul r10
    add rax, r9                                ; PMM_Address_Map + (Desc_Size * i)
    
    cmp r11, rcx                               ; if FindedIndex == rcx
    jne PMM_APAC_Move_Regions_Loop_End
    
    ; Create new descriptor                    ; [rax + Desc_Size] = (PMM_Address_Map + (Desc_Size * i)) + Desc_Size = Descriptors[i + 1]
    mov rdx, [rax + 0x0]
    mov [rax + 20 + 0x0], rdx                  ; Descriptors[i+1].PhysicalAddress = Descriptors[i].PhysicalAddress
    mov rdx, [rax + 0x8]
    mov [rax + 20 + 0x8], rdx                  ; Descriptors[i+1].NumberOfPages = Descriptors[i].NumberOfPages
    mov edx, [rax + 0x10]
    mov [rax + 20 + 0x10], edx                 ; Descriptors[i+1].Type = Descriptors[i].Type
    
    mov rdx, [rax + 20 + 0x8]                  ; Descriptors[i+1].NumberOfPages
    mov rbx, [rsp + 0]                         ; get needed number of pages
    sub rdx, rbx
    mov [rax + 20 + 0x8], rdx                  ; Descriptors[i+1].NumberOfPages -= NeededPages
    mov [rax + 0x8], rbx                       ; Descriptors[i].NumberOfPages = NeededPages
    
    push rax
    xor rdx, rdx
    mov rax, rbx
    mov r10, Page_Size
    mul r10                                    ; NeededPages * Page_Size
    
    pop rdx
    mov rbx, [rdx + 20 + 0x0]                  ; Descriptors[i+1].PhysicalAddress
    add rbx, rax
    mov [rdx + 20 + 0x0], rbx                  ; Descriptors[i+1].PhysicalAddress += NeededPages * Page_Size
    
    mov rbx, [rsp + 8]                         ; get type from stack
    mov [rdx + 0x10], ebx
    
    pop rax                                    ; clear stack
    pop rax                                    ; clear stack
    inc qword [PMM_Count_Descriptors]
    mov rax, [rdx + 0x0]                       ; return Descriptors[i].PhysicalAddress
    mov rbx, 0                                 ; no errors
    jmp PMM_APAC_End
    
  PMM_APAC_Move_Regions_Loop_End:
    mov rdx, [rax + 0x0]
    mov [rax + 20 + 0x0], rdx                  ; Descriptors[i+1].PhysicalAddress = Descriptors[i].PhysicalAddress
    mov rdx, [rax + 0x8]
    mov [rax + 20 + 0x8], rdx                  ; Descriptors[i+1].NumberOfPages = Descriptors[i].NumberOfPages
    mov edx, [rax + 0x10]
    mov [rax + 20 + 0x10], edx                 ; Descriptors[i+1].Type = Descriptors[i].Type
    
    dec rcx                                    ; i--
    jmp PMM_APAC_Move_Regions_Loop
    
  PMM_APAC_Error_1:
    ;not finded region
    mov rbx, 1
    jmp PMM_APAC_End
    
  PMM_APAC_Before_End:
    pop rax
    pop rax
    
  PMM_APAC_End:
    ret
    
