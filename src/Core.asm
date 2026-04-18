Macros_Print: 
  %include "src/lib/Macros/Print.asm"
;------------------------------------------------------------
; Main
Start:

Code:
  Core_Init:
    ;init new stack
    mov rbx, [rax + 0x3A]
    mov [Core_Stack_Physical_Address_Start], rbx
    mov rsp, [Core_Stack_Physical_Address_Start]
    add rsp, Core_Stack_Size_In_Pages * Page_Size
    mov [Core_Stack_Physical_Address_End], rsp
    
    ;save pointer to init data structure 
    push rax

    mov ebx, 0xffa8b17c
    call DAE_FillDisplay
    
    lea rbx, [Core_Msg_Initing]
    call COM_Print
    
    mov r8, [Core_Stack_Physical_Address_End]                                          ; get address end of stack
    sub r8, 8                                                                          ; calc init data structure from stack
    mov r8, [r8]                                                                       ; get from stack
    mov rbx, [r8 + 0x2]                                                                ; UEFI memory map descriptor version 
    mov rax, [r8 + 0xA]                                                                ; memory map descriptor size 
    mov rcx, [r8 + 0x1A]                                                               ; pointer
    mov rdx, [r8 + 0x12]                                                               ; size map in bytes
    mov r10, [r8 + 0x2A]                                                               ; pointer PMM map
    mov r11, [r8 + 0x22]                                                               ; PMM map size in pages
    call PMM_Init
    
    mov ebx, 0xff6b8141
    call DAE_FillDisplay
    
    ;check cpu vendor
    call CPUID_Where_i_am_launched
    cmp rax, 1
    jne Core_I_dont_know_this_CPU_Vendor
    
    call VMM_Init
    
    mov rax, 1
    mov rbx, 0xff
    call PMM_Allocate_Pages
    
    push rax
    
    ;call DAE_Convert_DQ_To_HEX_Text
    ;lea rbx, [DAE_HEX_Text]
    ;call COM_Print
    ;call PMM_Print_Table_Descriptors
    
    call VMM_Create_Map
    
    mov ebx, 0xff782317
    call DAE_FillDisplay
    
    ;mov rax, 0xdeadc0de0ffced11
    mov rax, 0x0
    mov rbx, 0x123456789abcdef0
    mov rcx, [rsp]
    mov rdx, 0XFFFFFFFFFFFFF9FF
    ;call VMM_Map
    
    ;call PMM_Print_Table_Descriptors
    mov rax, 4096
    mov rbx, 0x3000
    mov cl, 8
    ;call COM_Print_Block
    
    mov rax, [Core_Stack_Physical_Address_Start]
    add rax, Core_Stack_Size_In_Pages * Page_Size - 8
    mov rax, [rax]                                         ; first pointer in stack, init data structure
    mov r15, [rax + 0x32]                                  ; core phys address in structure
    
    mov rax, 0x0
    mov rbx, 0x0
    mov rcx, [rsp]
    mov rdx, 0x207
    call VMM_Map                                           ; identity map 2MB pag on 0x0 (pagging tables)
    
    xor r14, r14                                           ; clear counter
    Core_Mapping_Core_Code_Loop:                           ; identity mapping
      cmp r14, Code_Size_In_Pages
      jae Core_Mapping_Core_Code_Loop_End
      
      xor rdx, rdx
      mov rax, 0x1000
      mul r14                                              ; offset
      add rax, r15                                         ; full address of frame
      
      ; rax                                                ; virtual address arg
      mov rbx, rax                                         ; physical address arg
      mov rcx, [rsp]                                       ; base phys address of PML4 arg
      mov rdx, 0x7                                         ; attributes arg
      call VMM_Map
      
      inc r14
      jmp Core_Mapping_Core_Code_Loop
    Core_Mapping_Core_Code_Loop_End:
    
    xor r14, r14                                           ; clear counter
    Core_Mapping_Core_Data_Loop:                           ; identity mapping
      cmp r14, Data_Size_In_Pages
      jae Core_Mapping_Core_Data_Loop_End
      
      xor rdx, rdx
      mov rax, 0x1000
      mul r14                                              ; offset
      add rax, r15                                         ; full address of frame
      add rax, Code_Size_In_Pages * Page_Size              ; data offset in core
      
      ; rax                                                ; virtual address arg
      mov rbx, rax                                         ; physical address arg
      mov rcx, [rsp]                                       ; base phys address of PML4 arg
      mov rdx, 0x7                                         ; attributes arg
      call VMM_Map
      
      inc r14
      jmp Core_Mapping_Core_Data_Loop
    Core_Mapping_Core_Data_Loop_End:
    
    xor r14, r14                                           ; clear counter
    Core_Mapping_Core_Stack_Loop:                          ; the stack is not used very often, it can be mapped directly to the desired location
      cmp r14, Core_Stack_Size_In_Pages
      jae Core_Mapping_Core_Stack_Loop_End
      
      xor rdx, rdx
      mov rax, 0x1000
      mul r14                                              ; offset
      mov rbx, rax
      
      mov rax, 0xFFFF_FFFF_FFFF_F000 - Core_Stack_Size_In_Pages * Page_Size           ; virtual address arg
      add rax, rbx                                         ; full address of frame
      add rbx, [Core_Stack_Physical_Address_Start]         ; physical address arg
      
      mov rcx, [rsp]                                       ; base phys address of PML4 arg
      mov rdx, 0x7                                         ; attributes arg
      call VMM_Map
      
      inc r14
      jmp Core_Mapping_Core_Stack_Loop
    Core_Mapping_Core_Stack_Loop_End:
    
    xor r14, r14                                           ; clear counter
    Core_Main_Mapping_Core_Code_Loop:
      cmp r14, Code_Size_In_Pages
      jae Core_Main_Mapping_Core_Code_Loop_End
      
      xor rdx, rdx
      mov rax, 0x1000
      mul r14                                              ; offset
      mov rbx, rax                                         
      add rbx, r15                                         ; physical address arg
      
      mov rdx, 1
      shl rdx, 63
      mov cl, [VMM_Singed_Offset]
      sar rdx, cl
      
      add rax, rdx                                         ; virtual address arg
      mov rcx, [rsp]                                       ; base phys address of PML4 arg
      mov rdx, 0x7                                         ; attributes arg
      call VMM_Map
      
      inc r14
      jmp Core_Main_Mapping_Core_Code_Loop
    Core_Main_Mapping_Core_Code_Loop_End:
    
    xor r14, r14                                           ; clear counter
    Core_Main_Mapping_Core_Data_Loop:
      cmp r14, Data_Size_In_Pages
      jae Core_Main_Mapping_Core_Data_Loop_End
      
      xor rdx, rdx
      mov rax, 0x1000
      mul r14                                              ; offset
      add rax, Code_Size_In_Pages * Page_Size
      mov rbx, rax                                         
      add rbx, r15                                         ; physical address arg
      
      mov rdx, 1
      shl rdx, 63
      mov cl, [VMM_Singed_Offset]
      sar rdx, cl
      
      add rax, rdx                                         ; virtual address arg
      mov rcx, [rsp]                                       ; base phys address of PML4 arg
      mov rdx, 0x7                                         ; attributes arg
      call VMM_Map
      
      inc r14
      jmp Core_Main_Mapping_Core_Data_Loop
    Core_Main_Mapping_Core_Data_Loop_End:
    
    Core_Mapping_Frame_Buffer:
      mov rax, [DAE_FrameBufferSize]
      add rax, Page_Size
      dec rax
      xor rdx, rdx
      mov rbx, Page_Size
      div rbx
      mov r15, rax
      
      xor r14, r14
      Core_Mapping_Frame_Buffer_Loop:
        cmp r14, r15
        jae Core_Mapping_Frame_Buffer_Loop_End
      
        xor rdx, rdx
        mov rax, 0x1000
        mul r14                                              ; offset
        mov rbx, rax              
      
        mov rax, 0xFFFF_F000_0000_0000
        add rax, rbx                                         ; virtual address arg
        mov rcx, [DAE_FrameBuffer]
        add rbx, rcx                                         ; physical address arg
        mov rcx, [rsp]                                       ; base phys address of PML4 arg
        mov rdx, 0x1E                                        ; attributes arg
        call VMM_Map
        
        inc r14
        jmp Core_Mapping_Frame_Buffer_Loop
      Core_Mapping_Frame_Buffer_Loop_End:
    
    mov rax, 0xFFFF_F000_0000_0000
    mov [DAE_FrameBuffer], rax
    
    mov rbx, [Core_Stack_Physical_Address_End]
    sub rbx, rsp                                            ; offset in stack
    mov rdx, 0xFFFF_FFFF_FFFF_F000                          ; virtual address bottom of stack
    sub rdx, rbx
    
    mov rax, [rsp]
    mov cr3, rax                                            ; set PML4 phys address
    
    mov rax, cr0
    mov rcx, 0x80000000                                     ; PG bit
    or rax, rcx        
    mov cr0, rax                                            ; activate paging
    
    mov rsp, rdx
    
    mov ebx, 0xfff3f10e
    call DAE_FillDisplay
    
    mov rax, 4096 * 30
    mov rbx, 0
    mov cl, 8
    ;call COM_Print_Block
    ;jmp $
    
    mov rax, 0x0000_8000_0000_0000
    mov cl, [VMM_Singed_Offset]
    shl rax, cl
    sar rax, cl                                            ; make canonical virtual address
    
    jmp $
    hlt
;--------------------------------------------------------------------
Core_I_dont_know_this_CPU_Vendor:
  lea rbx, [Core_I_dont_know_this_CPU_Vendor_Msg]
  call COM_Print
  
  xor rax, rax
  cpuid
  
  sub rsp, 16
  mov [rsp], ebx
  mov [rsp + 4], edx
  mov [rsp + 8], ecx
  mov byte [rsp + 12], 0
  
  mov rbx, rsp
  call COM_Print
  
  jmp $          
  hlt
;--------------------------------------------------------------------
  
  Debug_COM_Print_Block:
    %include "src/lib/Debug/COM_Print_Block.asm"
  Debug_COM_Print:
    %include "src/lib/Debug/COM_Print.asm"
  CPUID_code:
    %include "src/lib/CPUID/CPUID.asm"
  Memory_code:
    %include "src/lib/Memory.asm"
  PMM_code:
    %include "src/lib/PMM/PMM_Init.asm"
  VMM_code:
    %include "src/lib/VMM/VMM_Init.asm"
  PCI_Lib:
    %include "src/lib/PCI.asm"
  USB_Lib:
    %include "src/lib/USB.asm"
  Draw_code:
    %include "src/lib/Draw/Draw.asm"
Code_end:

; Padding code -------------------------------------------------
Code_Padding                 equ (Code_Size_In_Pages * Page_Size) - Code_Size
Code_Size_In_Pages           equ (Code_Size + Page_Size - 1) / Page_Size
Code_Size                    equ Code_end - Code
Times Code_Padding db 0
;-----------------------------------------------------

Data:
  CPUID_data:
    %include "src/lib/CPUID/CPUID_Data.asm"
  PMM_data:
    %include "src/lib/PMM/PMM_Data.asm"
  VMM_data:
    %include "src/lib/VMM/VMM_Data.asm"
  Draw_data: 
    %include "src/lib/Draw/Draw_Data.asm"
  ;PCI_Lib:
    ;%include "src/lib/PCI.asm"
  ;USB_Lib:
    ;%include "src/lib/USB.asm"
   
  Core_Physical_Address dq 0
  Core_Stack_Physical_Address_Start dq 0
  Core_Stack_Physical_Address_End dq 0
  Core_Msg_Initing db "Initing core...", 13, 10, 0
  Core_I_dont_know_this_CPU_Vendor_Msg db "I dont know this CPU Vendor: ", 0
Data_end:

; Padding data -------------------------------------------------
Data_Padding                  equ (Data_Size_In_Pages * Page_Size) - Data_Size
Data_Size_In_Pages            equ (Data_Size + Page_Size - 1) / Page_Size
Data_Size                     equ Data_end - Data
Times Data_Padding db 0
;-----------------------------------------------------

End:

; Здесь производиться расчёт сколько нужно странц для ядра
Core_Size_In_Pages            equ Code_Size_In_Pages + Data_Size_In_Pages
Core_Stack_Size_In_Pages      equ 4

Page_Size equ 4096

;------------------------------------------------------------------------------------------------------------------------------
;Примечание: модуль Draw или DAE (Draw After EFI), является отдельным и не обязательным, он нужен чисто для отладки
;От момента выхода из UEFI до настроики нормальной отладки
;Стараюсь использовать этот модуль по минимуму, и его можно вырезать спокойно и система не сломается

; 1. Для запуска ядра нужно выделить ему память, и записать его туда, от метки Start до метки End, все байты с учётом заполнения
;  - В константе Core_Size_In_Pages храниться сколько нужно страниц памяти ядру
;  - В константе Core_Stack_Size_In_Pages храниться сколько нужно страниц памяти стэка ядра
; 2. Нужно выделить память для структуры данных инициализации ядра
; 3. Нужно получить карту памяти UEFI
; 4. Нужно выделить место для PMM
;  - Размер выдиленой памяти для PMM должен быть равным как у карты памяти UEFI

;Версия 1, Init Data Structure:
;смещение, размер, описание
;0x0,  2 байта - версия структуры данных
;0x2,  8 байт  - версия дескриптора карты памяти UEFI
;0xA,  8 байт  - размер дескриптора карты памяти UEFI
;0x12, 8 байт  - размер карты памяти UEFI, в странмцах
;0x1A, 8 байт - указатель на карту памяти UEFI
;0x22, 8 байт - размер карты памяти PMM, в байтах
;0x2A, 8 байт - указатель на карту памяти PMM
;0x32, 8 байт - указатель на физ адресс ядра
;0x3A, 8 байт - указатель на физ адресс стэка ядра

