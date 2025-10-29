PMM_Merge_Of_Regions:
  ; rbx - count descriptors
  ; rcx - counter
  ; r8 - address memory map
  ; r10 - count descriptors
  ; r11 - index merged descriptor
  ; r12 - flag finded
  ; r13 - current address descriptor[i]
  
  PMM_Merge_Of_Regions_Init_Loop:
    mov r8, [PMM_Address_Map]
    mov r10, [PMM_Count_Descriptors]
    xor r11, r11
    xor r12, r12
    xor rcx, rcx
    
  PMM_Merge_Of_Regions_Loop:
    PMM_Merge_Of_Regions_Loop_Check:
      cmp rcx, r10
      jnl PMM_Merge_Of_Regions_End
      
    PMM_Merge_Of_Regions_Calc_Addr_Descriptor:
      xor rdx, rdx
      mov rax, rcx
      mov r9, 20                                   ; size of descriptor
      mul r9
      add rax, r8                                  ;calc address descriptor[i]
      mov r13, rax
    
      cmp r12, 1
      jne PMM_Merge_Of_Regions_Not_Finded
      
    PMM_Merge_Of_Regions_Finded:
      xor rdx, rdx
      mov edx, [r13 + 0x10]                        ;get type from descriptor[i]
      cmp rdx, EfiConventionalMemory
      je PMM_Merge_Of_Regions_Finded_A
      jne PMM_Merge_Of_Regions_Finded_B
      
      PMM_Merge_Of_Regions_Finded_A:
        xor rdx, rdx
        mov rax, r11
        mov r9, 20             ;size of descriptor PMM
        mul r9
        add rax, r8            ;calc address merged descriptor
        
        mov rdx, [r13 + 0x8]   ;get number of pages from descriptor[i]
        mov r9, 0
        mov [r13 + 0x8], r9    ;set 0, number of pages from descriptor[i]
        mov r9, [rax + 0x8]    ;get number of pages from merged descriptor
        add r9, rdx            ;add pages
        mov [rax + 0x8], r9    ;save to merged descriptor
        
        jmp PMM_Merge_Of_Regions_End_Loop
        
      PMM_Merge_Of_Regions_Finded_B:
        mov r12, 0
        jmp PMM_Merge_Of_Regions_End_Loop
      
    PMM_Merge_Of_Regions_Not_Finded:
      xor rdx, rdx
      mov edx, [r13 + 0x10]                        ;get type from descriptor[i]
      
      cmp rdx, EfiConventionalMemory
      je PMM_Merge_Of_Regions_Not_Finded_C
      jne PMM_Merge_Of_Regions_End_Loop
      
      PMM_Merge_Of_Regions_Not_Finded_C:
        mov r12, 1           ;set flag
        mov r11, rcx         ;save index finded merged descriptor
    
  PMM_Merge_Of_Regions_End_Loop:
    inc rcx
    jmp PMM_Merge_Of_Regions_Loop
    
  PMM_Merge_Of_Regions_End:
    ret
