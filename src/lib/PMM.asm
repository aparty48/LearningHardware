%include "src/lib/PMM/Clear_Empty_Regions.asm"
%include "src/lib/PMM/Init.asm" 
%include "src/lib/PMM/Merge_Of_Regions.asm"
%include "src/lib/PMM/Print_Table_Descriptors.asm"
;--------------------------------------------------------------------------------------
PMM_Allocate_Pages:
  ; Input
  ; rax - count pages
  ; rbx - type page
  ret
PMM_Free_Pages:
  ; rax - address
  ; set region as conventional memory
  call PMM_Merge_Of_Regions
  call PMM_Clear_Empty_Regions
  ret

