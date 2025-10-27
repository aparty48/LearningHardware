MEM_Copy_Pages:
  ;Input
  ;rax - address source
  ;rbx - address destination
  ;rcx - count pages
  MEM_Copy_Pages_end:
    ret
;---------------------------------------------------
MEM_Copy_Bytes:
  ;Input
  ;rax - address source
  ;rbx - address destination
  ;rcx - count bytes
  ;Used
  ;rdx - 
  
  dec rcx
  
  MEM_Copy_Bytes_loop:
    mov dl, [rax + rcx]
    mov [rbx + rcx], dl
    dec rcx
    jnz MEM_Copy_Bytes_loop
    
    mov dl, [rax]
    mov [rbx], dl
    
  MEM_Copy_Bytes_end:
    ret
;----------------------------------------------------
MEM_Calc_Needed_Pages_From_Count_Bytes:
  ;Input: 
  ;rax - count bytes
  ;Output
  ;rax - count pages
  ;Used:
  ;rax, rcx, rdx
  add rax, Page_Size - 1
  xor rdx, rdx
  mov rcx, Page_Size
  div rcx
  ret
