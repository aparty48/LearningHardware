;------------------------------------------------------------
; Main
Start:

Code:
  Core_Init:
    ;init new stack
    mov rsp, [Core_Stack_Physical_Address]
    add rsp, Core_Stack_Size_In_Pages * Page_Size

    mov ebx, 0xffa8b17c
    call DAE_FillDisplay
    
    lea rax, [DAE_Hello_World]
    call DAE_Print
    
    hlt
    
  Draw_code:
    %include "Lib/Draw.asm"
  Memory_code:
    %include "Lib/Memory.asm"
  PCI_Lib:
    %include "Lib/PCI.asm"
  USB_Lib:
    %include "Lib/USB.asm"
Code_end:

; Padding code -------------------------------------------------
Code_Padding                 equ (Code_Size_In_Pages * Code_Size) - Code_Size
Code_Size_In_Pages           equ (Code_Size + Page_Size - 1) / Page_Size
Code_Size                    equ Code_end - Code
Times Code_Padding db 0
;-----------------------------------------------------

Data:
  Draw_data: 
    %include "Lib/Data/Draw.asm"
  Memory_data:
    %include "Lib/Data/Memory.asm"
  ;PCI_Lib:
    ;%include "Lib/PCI.asm"
  ;USB_Lib:
    ;%include "Lib/USB.asm"
    
  ; Карта памяти которую нужно получить у UEFI, Выделить странцы с типом EfiRuntimeData, записать туда, и вернуть физ адресс.
  ; PMM (Physical Memory Manager) это общее название под-системы, которая распеределяет блоки физ. памяти, какие заняты какие нет. 
  ; Обычно каждое ядро реализовывает эту под систему самостоятельно.
  Physical_Address_MemMap dq 0   
  Core_Physical_Address dq 0
  Core_Stack_Physical_Address dq 0
Data_end:

; Padding data -------------------------------------------------
Data_Padding                  equ (Data_Size_In_Pages * Page_Size) - Data_Size
Data_Size_In_Pages            equ (Data_Size + Page_Size - 1) / Page_Size
Data_Size                     equ Data_end - Data
Times Data_Padding db 0
;-----------------------------------------------------

End:

; Чтобы ядро работало, нужно выделить память для кода ядра, даных ядра, и стэка, при этом последовательность и выравнивание должны оставться не изменными.
; Здесь производиться расчёт сколько нужно странц для ядра
;Core_Total_Need_Pages         equ Core_Size_In_Pages + Core_Stack_Size_In_Pages
Core_Size_In_Pages            equ Code_Size_In_Pages + Data_Size_In_Pages
Core_Stack_Size_In_Pages      equ 4

Page_Size equ 4096
