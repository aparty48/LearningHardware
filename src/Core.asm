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
    
    jmp $
    hlt
  
  COM_Print:
    ;rbx - pointer to massage
    ;Used: r8, rdx, rax
    COM_Print_Loop:
      xor r8, r8
      mov r8b, [rbx]
      cmp r8b, 0
      je COM_Print_end
      
      COM_Print_out_byte:
        mov dx, 0x3FD
        in al, dx
        test al, 0x20
        jz COM_Print_out_byte
        mov dx, 0x3F8
        mov al, r8b
        out dx, al
        inc rbx
        jmp COM_Print_Loop
        
    COM_Print_end: 
      ret
    
  Memory_code:
    %include "src/lib/Memory.asm"
  PMM_code:
    %include "src/lib/PMM.asm"
  PCI_Lib:
    %include "src/lib/PCI.asm"
  USB_Lib:
    %include "src/lib/USB.asm"
  Draw_code:
    %include "src/lib/Draw.asm"
Code_end:

; Padding code -------------------------------------------------
Code_Padding                 equ (Code_Size_In_Pages * Code_Size) - Code_Size
Code_Size_In_Pages           equ (Code_Size + Page_Size - 1) / Page_Size
Code_Size                    equ Code_end - Code
Times Code_Padding db 0
;-----------------------------------------------------

Data:
  Memory_data:
    %include "src/lib/Data/Memory.asm"
  PMM_data:
    %include "src/lib/Data/PMM.asm"
  Draw_data: 
    %include "src/lib/Data/Draw.asm"
  ;PCI_Lib:
    ;%include "src/lib/PCI.asm"
  ;USB_Lib:
    ;%include "src/lib/USB.asm"
   
  Core_Physical_Address dq 0
  Core_Stack_Physical_Address_Start dq 0
  Core_Stack_Physical_Address_End dq 0
  Core_Msg_Initing db "Initing core...", 13, 10, 0
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
