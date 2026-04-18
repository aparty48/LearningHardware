VMM_Delete_Map_PML4:
    xor rbx, rbx
    sub rsp, 48                                 ; alloc memory
    mov [rsp + PML4_Phys_Addr_VMMDM4], rax      ; save root table phys address
    
    PML4E_Index_VMMDM4 equ 40
    PDPTE_Index_VMMDM4 equ 32
    PDE_Index_VMMDM4 equ 24
    
    PML4_Phys_Addr_VMMDM4 equ 16
    PDPT_Phys_Addr_VMMDM4 equ 8
    PD_Phys_Addr_VMMDM4 equ 0
    
VMM_Delete_Map_PML4_Loop_PLM4:                 ; {
  cmp qword [rsp + PML4E_Index_VMMDM4], 512
  jae VMM_Delete_Map_PML4_Loop_PLM4_End
      
  mov rax, [rsp + PML4_Phys_Addr_VMMDM4]
  mov rbx, [rsp + PML4E_Index_VMMDM4]
  mov rax, [rax + rbx * 8]
  test rax, 0x1
  jz VMM_Delete_Map_PML4_Loop_PLM4_Inc
      
  and rax, [VMM_4KB_Page_Entry_Mask]
  mov [rsp + PDPT_Phys_Addr_VMMDM4], rax
      
  mov qword [rsp + PDPTE_Index_VMMDM4], 0
  VMM_Delete_Map_PML4_Loop_PDPT:               ; {
    cmp qword [rsp + PDPTE_Index_VMMDM4], 512
    jae VMM_Delete_Map_PML4_Loop_PDPT_Inc
        
    mov rax, [rsp + PDPT_Phys_Addr_VMMDM4]
    mov rbx, [rsp + PDPTE_Index_VMMDM4]
    mov rax, [rax + rbx * 8]
    test rax, 0x1
    jz VMM_Delete_Map_PML4_Loop_PDPT_Inc
        
    test rax, 0x1000_0000                      ; PS bit
    jnz VMM_Delete_Map_PML4_Loop_PDPT_Inc      ; skip
        
    and rax, [VMM_4KB_Page_Entry_Mask]
    mov [rsp + PD_Phys_Addr_VMMDM4], rax
        
    mov qword [rsp + PDE_Index_VMMDM4], 0
    VMM_Delete_Map_PML4_Loop_PD:               ; {
      cmp qword [rsp + PDE_Index_VMMDM4], 512
      jae VMM_Delete_Map_PML4_Loop_PD_Inc
          
      mov rax, [rsp + PD_Phys_Addr_VMMDM4]
      mov rbx, [rsp + PDE_Index_VMMDM4]
      mov rax, [rax + rbx * 8]
      test rax, 0x1
      jz VMM_Delete_Map_PML4_Loop_PD_Inc
          
      test rax, 0x1000_0000                    ; PS bit
      jnz VMM_Delete_Map_PML4_Loop_PD_Inc      ; skip
          
      and rax, [VMM_4KB_Page_Entry_Mask]       ; PT table phys address
      call PMM_Free_Pages
          
    VMM_Delete_Map_PML4_Loop_PD_Inc:
      inc qword [rsp + PDE_Index_VMMDM4]
      jmp VMM_Delete_Map_PML4_Loop_PD
    VMM_Delete_Map_PML4_Loop_PD_End:           ; }
      mov rax, [rsp + PD_Phys_Addr_VMMDM4]
      call PMM_Free_Pages
        
  VMM_Delete_Map_PML4_Loop_PDPT_Inc:
    inc qword [rsp + PDPTE_Index_VMMDM4]
    jmp VMM_Delete_Map_PML4_Loop_PDPT
  VMM_Delete_Map_PML4_Loop_PDPT_End:           ; }
    mov rax, [rsp + PDPT_Phys_Addr_VMMDM4]
    call PMM_Free_Pages
      
VMM_Delete_Map_PML4_Loop_PLM4_Inc:
  inc qword [rsp + PML4E_Index_VMMDM4]
  jmp VMM_Delete_Map_PML4_Loop_PLM4
VMM_Delete_Map_PML4_Loop_PLM4_End:             ; }

add rsp, 48
ret
