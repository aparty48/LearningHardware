VMM_Unmap_PML4:
  VMM_Unmap_PML4_Get_Index_PML4:
    mov r8, rax
    mov r9, 0b000000000000000_111111111_000000000_000000000_000000000_000000000000
    and r8, r9
    shr r8, 39                                         ; index in pml4
    
    mov r9, [rbx + r8 * 8]                             ; entry from pml4
  
    test r9, 0x1
    jnz VMM_Unmap_PML4_Read_Address_PML4E
    
  VMM_Unmap_PML4_Error_1:
    mov rax, 0x1                                       ; error PML4E not exists
    ret
  
  VMM_Unmap_PML4_Read_Address_PML4E:
    mov r10, r9
    mov r9, [VMM_4KB_Page_Entry_Mask]
    and r10, r9                                        ; phys address PDPT
    
  VMM_Unmap_PML4_Get_Index_PDPT:
    mov r8, rax
    mov r9, 0b000000000000000_000000000_111111111_000000000_000000000_000000000000
    and r8, r9
    shr r8, 39                                         ; index in pdpt
    
    mov r9, [r10 + r8 * 8]                             ; entry from pdpt
  
    test r9, 0x1
    jnz VMM_Unmap_PML4_Check_PS_PDPTE                  ; if P == 1
    
  VMM_Unmap_PML4_Error_2:
    mov rax, 0x2                                       ; error PDPTE not exists
    ret
  
  VMM_Unmap_PML4_Check_PS_PDPTE:
    test r9, 0x1000_0000
    jz VMM_Unmap_PML4_Read_Address_PDPTE               ; if PS == 0
  
    VMM_Unmap_PML4_PS_PDPTE:
      mov r9, [VMM_2MB_Page_Entry_Mask]
      mov rbx, [r10 + r8 * 8]                          ; get entry from pdpt
      and rbx, r9                                      ; return physical addressm
      mov qword [r10 + r8 * 8], 0x0                    ; clear entry
      mov rax, 0                                       ; return code 0 - good
      ;invlpg [rax]                                    ; update TLB
      ret
  
  VMM_Unmap_PML4_Read_Address_PDPTE:
    mov r10, r9
    mov r9, [VMM_4KB_Page_Entry_Mask]
    and r10, r9                                        ; phys address PD

  VMM_Unmap_PML4_Get_Index_PD:
    mov r8, rax
    mov r9, 0b000000000000000_000000000_000000000_111111111_000000000_000000000000
    and r8, r9
    shr r8, 39                                         ; index in pd
    
    mov r9, [r10 + r8 * 8]                             ; entry from pd
  
    test r9, 0x1                                       ; if P == 1
    jnz VMM_Unmap_PML4_Check_PS_PDE
    
  VMM_Unmap_PML4_Error_3:
    mov rax, 0x3                                       ; error PTE not exists
    ret
  
  VMM_Unmap_PML4_Check_PS_PDE:
    test r9, 0x1000_0000
    jz VMM_Unmap_PML4_Read_Address_PDE                 ; if PS == 0
  
    VMM_Unmap_PML4_PS_PDE:
      mov r9, [VMM_2MB_Page_Entry_Mask]
      mov rbx, [r10 + r8 * 8]                          ; get entry from pd
      and rbx, r9                                      ; return physical address
      mov qword [r10 + r8 * 8], 0x0                    ; clear entry
      mov rax, 0                                       ; return code 0 - good
      ;invlpg [rax]                                    ; update TLB
      ret
  
  VMM_Unmap_PML4_Read_Address_PDE:
    mov r10, r9
    mov r9, [VMM_4KB_Page_Entry_Mask]
    and r10, r9                                        ; phys address PT
  
  VMM_Unmap_PML4_Get_Index_PT:
    mov r8, rax
    mov r9, 0b000000000000000_000000000_000000000_000000000_111111111_000000000000
    and r8, r9
    shr r8, 39                                         ; index in pt
    
    mov r9, [r10 + r8 * 8]                             ; entry from pd
    
  VMM_Unmap_PML4_Read_Address_PTE:
    mov rbx, r9
    mov r9, [VMM_4KB_Page_Entry_Mask]
    and rbx, r9                                        ; phys address 4 Kb
    mov qword [r10 + r8 * 8], 0x0                      ; clear entry
    mov rax, 0                                         ; return code 0 - good
    ;invlpg [rax]                                      ; update TLB
    ret
