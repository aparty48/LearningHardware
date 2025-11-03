%include "src/lib/PMM/PMM_Allocate_Pages.asm"
%include "src/lib/PMM/Clear_Empty_Regions.asm"
%include "src/lib/PMM/Init.asm" 
%include "src/lib/PMM/Merge_Of_Regions.asm"
%include "src/lib/PMM/Print_Table_Descriptors.asm"
;--------------------------------------------------------------------------------------

PMM_Free_Pages:
  ; rax - address
  ; set region as conventional memory
  ; rcx - counter
  ; r8 - [PMM_Address_Map]
  ; r9 - [PMM_Count_Descriptors]
  ; Out:
  ; rax - code, 0 - good, 1 - not find descriptor
  PMM_Free_Pages_Loop_Init:
    mov r8, [PMM_Address_Map]
    mov r9, [PMM_Count_Descriptors]
    xor rcx, rcx
    
  PMM_Free_Pages_Loop:
    cmp rcx, r9
    jnl PMM_Free_Pages_Reload_Map
  
  PMM_Free_Pages_Loop_End:
    inc rcx
    jmp PMM_Free_Pages_Loop
  
  PMM_Free_Pages_Reload_Map:
    call PMM_Merge_Of_Regions
    call PMM_Clear_Empty_Regions
    
  PMM_Free_Pages_End:
    ret

