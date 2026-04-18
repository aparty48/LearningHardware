VMM_Init:
  call CPUID_What_is_BitWidth_of_the_addr_bus
  VMM_Init_4KB_Page_Entry_Mask:
    xor rax, rax
    inc rax
    mov cl, [CPUID_BitWidth_Phys_Address_Bus]
    shl rax, cl
    dec rax
    mov rcx, 0xFFFF_FFFF_FFFF_F000
    and rax, rcx
    mov [VMM_4KB_Page_Entry_Mask], rax
    mov rcx, 0xFFFF_FFFF_FFE0_0000
    and rax, rcx
    mov [VMM_2MB_Page_Entry_Mask], rax
    mov rcx, 0xFFFF_FFFF_C000_0000
    and rax, rcx
    mov [VMM_1GB_Page_Entry_Mask], rax
    
    mov al, [CPUID_BitWidth_Virt_Address_Bus]
    mov ah, 64
    sub ah, al
    mov [VMM_Singed_Offset], ah
  
  
  call CPUID_PML5_Supporting
  cmp rax, 1                  ; PML5 is supporting ?
  ;jne VMM_Init_Set_PML4
  jmp VMM_Init_Set_PML4       ; temporarily disabled
  
  lea rbx, [VMM_Create_Map_PML5]
  mov [VMM_Create_Map_Pointer], rbx
  lea rbx, [VMM_Delete_Map_PML5]
  mov [VMM_Delete_Map_Pointer], rbx
  lea rbx, [VMM_Map_PML5]
  mov [VMM_Map_Pointer], rbx
  lea rbx, [VMM_Unmap_PML5]
  mov [VMM_Unmap_Pointer], rbx
  ret
  
  VMM_Init_Set_PML4:
    lea rbx, [VMM_Create_Map_PML4]
    mov [VMM_Create_Map_Pointer], rbx
    lea rbx, [VMM_Delete_Map_PML4]
    mov [VMM_Delete_Map_Pointer], rbx
    lea rbx, [VMM_Map_PML4]
    mov [VMM_Map_Pointer], rbx
    lea rbx, [VMM_Unmap_PML4]
    mov [VMM_Unmap_Pointer], rbx
    ret


%include "src/lib/VMM/VMM_Create_Map_PML4.asm"
%include "src/lib/VMM/VMM_Create_Map_PML5.asm"
%include "src/lib/VMM/VMM_Delete_Map_PML4.asm"
%include "src/lib/VMM/VMM_Delete_Map_PML5.asm"
%include "src/lib/VMM/VMM_Map_PML4.asm"
%include "src/lib/VMM/VMM_Map_PML5.asm"
%include "src/lib/VMM/VMM_Unmap_PML4.asm"
%include "src/lib/VMM/VMM_Unmap_PML5.asm"
;--------------------------------
VMM_Create_Map:
  ; Inp: rax - pointer phys address to block bytes for PML4
  jmp [VMM_Create_Map_Pointer]
;--------------------------------
VMM_Delete_Map:
  ; Inp: rax - phys address root table
  ; Out: rax - return code
  jmp [VMM_Delete_Map_Pointer]
;--------------------------------
VMM_Map:
  ;Inp
  ; rax - virtual address
  ; rbx - physical address
  ; rcx - address root of map
  ; rdx - attributes
  ; Attributes in reg: 0b000 ...0000, 1Gb Page, 2Mb Page, NX, G, PCD, PWT, U/S, R/W
  ; Если флаги 1Gb Page и 2Mb Page будут 1, замапится 1 Гб страница
  ; Если 1Gb Page будет 1, замапится 1 Гб
  ; Если 2MB Page будет 1, замапится 2 Мб
  ; По умолчанию замапится 4 Кб странца
  ; Used: rax, rbx, rcx, rdx, r8, r9, r10, r11, r12, r13
  ; Out
  ; rax - return code
  jmp [VMM_Map_Pointer]
;-------------------------------- 
VMM_Unmap:
  ; Inp, rax - virtual address, rbx - phys address root table
  ; Used: rax, rbx, r8, r9, r10
  ; Out, rax - return code, rbx - phys address unmaped entry
  jmp [VMM_Unmap_Pointer]
