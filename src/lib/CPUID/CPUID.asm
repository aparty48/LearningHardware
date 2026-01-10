CPUID_Where_i_am_launched:
  ;Out - rax: 0-unknown cpu vendor, 1 - known cpu vendor
  xor rax, rax
  xor rbx, rbx
  xor rcx, rcx
  xor rdx, rdx
  
  cpuid
  
  mov [CPUID_Max_Pages], eax
  
  cmp ebx, "Genu"
  jne CPUID_WIAL_Not_Intel
  cmp edx, "ineI"
  jne CPUID_WIAL_Not_Intel
  cmp ecx, "ntel"
  jne CPUID_WIAL_Not_Intel
  
  lea rax, [CPUID_Intel_Parser]
  mov [CPUID_Parser_Phys_Address], rax      ;save Intel Parser Pointer
  mov rax, 1
  ret

  CPUID_WIAL_Not_Intel:
    cmp ebx, "Auth"
    jne CPUID_WIAL_Not_AMD
    cmp edx, "enti"
    jne CPUID_WIAL_Not_AMD
    cmp ecx, "cAMD"
    
    lea rax, [CPUID_AMD_Parser]
    mov [CPUID_Parser_Phys_Address], rax    ;save AMD Parser Pointer
    mov rax, 1
    ret
    
  CPUID_WIAL_Not_AMD:
    mov rax, 0
    ret
;------------------------------------
CPUID_PLM5_Supporting:
  ;Out - rax: 0 - not suport, 1 - supported
  mov eax, [CPUID_Max_Pages]
  cmp eax, 0x7
  jb CPUID_PLM5_Supporting_No
  
  mov eax, 7
  xor ecx, ecx
  cpuid
  
  bt ecx, 16
  jnc CPUID_PLM5_Supporting_No
  
  mov rax, 1                      ;supported
  ret
  
  CPUID_PLM5_Supporting_No:
    mov rax, 0
    ret
  
  
  
;------------------------------------
%include "src/lib/CPUID/AMDParser.asm"
%include "src/lib/CPUID/IntelParser.asm"
