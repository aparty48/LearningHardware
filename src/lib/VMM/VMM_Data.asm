VMM_Create_Map_Pointer dq 0
VMM_Delete_Map_Pointer dq 0
VMM_Map_Pointer dq 0
VMM_Unmap_Pointer dq 0

VMM_1GB_Page_Entry_Mask dq 0
VMM_2MB_Page_Entry_Mask dq 0
VMM_4KB_Page_Entry_Mask dq 0

VMM_Singed_Offset db 0

; Фрей - это блок памяти в физическом пространстве, имеет любой размер, но обычно таких же размеров как и страницы
; Страница - это логический блок виртуального адресного пространства
; Регион - непрерывная область из страниц или фреймов
; Страницы могут иметь размер 4 КБ, 2 МБ, 1 ГБ

;Индексация виртуального адресса
;---------------------------------------------------------------------------------------------------------------------------------------------------
; PML4
; |63           48|47     39|38     30|29     21|20     12|11         0|
; |000000000000000|000000000|000000000|000000000|000000000|000000000000|
; |Sing extension |PML4     |PDPT     |PD       |PT       |Offset      |
;
; Sing extension - копии 47 бита, если это не так, будет ошибка
;---------------------------------------------------------------------------------------------------------------------------------------------------
; PML5
; |63  57|56     48|47     39|38     30|29     21|20     12|11         0|
; |000000|000000000|000000000|000000000|000000000|000000000|000000000000|
; |      |PML5     |PML4     |PDPT     |PD       |PT       |Offset      |
; |Sing extension
;
; Sing extension - копии 56 бита, если это не так, будет ошибка
; Каждый индекс используется на своём уровне, чтобы получить запись из таблицы как из маисва
; Offset - это смещение внутри страницы
;---------------------------------------------------------------------------------------------------------------------------------------------------
; Если к примеру в таблице PD запись указывает на блок памяти, то индекс для PT таблицы не нужен, и offset расширяется, тоесть он станет 21 бит
; PML5
; |63  57|56     48|47     39|38     30|29     21|20                  0|
; |000000|000000000|000000000|000000000|000000000|000000000000000000000|
; |      |PML5     |PML4     |PDPT     |PD       |Offset               |
; |Sing extension
;---------------------------------------------------------------------------------------------------------------------------------------------------
; Для PDPT таблицы в таком же случае еще добавляется индекс PD, поэтому offset будет 30 бит
; PML5
; |63  57|56     48|47     39|38     30|29                           0|
; |000000|000000000|000000000|000000000|000000000000000000000000000000|
; |      |PML5     |PML4     |PDPT     |Offset                        |
; |Sing extension
;---------------------------------------------------------------------------------------------------------------------------------------------------
;
; From Intel 64 Manual, Volume 3A, Chapter 5 Paging, Figure 5-11
;
;---------------------------------------------------------------------------------------------------------------------------------------------------
;
; | Reserved                                                     | Ignored   | PWT
; |                                                              |           |
; |0000 0000 0000 0 .... M | M-1 .... X XXXX XXXX XXXX XXXX XXXX |XXXX XXX|X |X|XXX    <=== CR3
;                          |                                              |    |
;                          | Address of PML5 or PML4 table            PCD |    | Ignored
;
;---------------------------------------------------------------------------------------------------------------------------------------------------
;
;                                                                    Accessed |
;                                                                Reserved |   |    | Page Write Throught
; | NX             | Reserved                                    R |      |   |    |   | Read/Write
; |                |                                               |      |   |    |   |
; |X|XXX XXXX XXXX |0 .... M | M-1 .... X XXXX XXXX XXXX XXXX XXXX |X|XXX |0|X|X|X |X|X|X|1           <=== PML5 Entry present ===================
;   |                        |                                       |      |   |    |   |
;   | Ignored                | Address of PML4 table         Ignored |      |   |    |   | Present
;                                                                   Ignored |   |    | User/Supervisor
;                                                           Page Cache Disabled |
;
; | Ignored                                                                                          | Present
; |XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXX|0        <=== PML5 Entry not present ===================
;
;---------------------------------------------------------------------------------------------------------------------------------------------------
;
;                                                                    Accessed |
;                                                                Reserved |   |    | Page Write Throught
; | NX             | Reserved                                    R |      |   |    |   | Read/Write
; |                |                                               |      |   |    |   |
; |X|XXX XXXX XXXX |0 .... M | M-1 .... X XXXX XXXX XXXX XXXX XXXX |X|XXX |0|X|X|X |X|X|X|1           <=== PML4 Entry present ===================
;   |                        |                                       |      |   |    |   |
;   | Ignored                | Address of PDPT table         Ignored |      |   |    |   | Present
;                                                                   Ignored |   |    | User/Supervisor
;                                                           Page Cache Disabled |
;
; | Ignored                                                                                          | Present
; |XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXX|0        <=== PML4 Entry not present ===================
;
;---------------------------------------------------------------------------------------------------------------------------------------------------
;
;                                                                        Accessed |    | Page Write Throught
;                                                                   Page Size |   |    |
;   | Protect key   | Reserved               | Reserved             R |       |   |    |   | Read/Write
;   |               |                        |                        |       |   |    |   |
; |X|XXX X|XXX XXXX |0 .... M | M-1 .... X XX|00 0000 0000 0000 000|X |X|XX|X |1|X|X|X |X|X|X|1           <=== PDPT Entry 1 GB Page ========
; |       |                   |                                PAT |    |  |    |   |    |   |
; | NX    | Ignored           | Address of 1GB Page Frame       Ignored |  |    |   |    |   | Present
;                                                                   Global |    |   |    |
;                                                                         Dirty |   |    | User/Supervisor
;                                                               Page Cache Disabled |
;
;                                                                    Accessed |
;                                                               Page Size |   |    | Page Write Throught
; | NX             | Reserved                                    R |      |   |    |   | Read/Write
; |                |                                               |      |   |    |   |
; |X|XXX XXXX XXXX |0 .... M | M-1 .... X XXXX XXXX XXXX XXXX XXXX |X|XXX |0|X|X|X |X|X|X|1           <=== PDPT Entry page directory ===================
;   |                        |                                       |      |   |    |   |
;   | Ignored                | Address of PD table           Ignored |      |   |    |   | Present
;                                                                   Ignored |   |    | User/Supervisor
;                                                           Page Cache Disabled |
;
; | Ignored                                                                                          | Present
; |XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXX|0        <=== PDPT Entry not present ===================
;
;---------------------------------------------------------------------------------------------------------------------------------------------------
;
;                                                                        Accessed |    | Page Write Throught
;                                                                   Page Size |   |    |
;   | Protect key   | Reserved                 Reserved |           R |       |   |    |   | Read/Write
;   |               |                                   |             |       |   |    |   |
; |X|XXX X|XXX XXXX |0 .... M | M-1 .... X XXXX XXXX XXX|0 0000 000|X |X|XX|X |1|X|X|X |X|X|X|1           <=== PD Entry 2 MB Page ========
; |       |                   |                                PAT |    |  |    |   |    |   |
; | NX    | Ignored           | Address of 2MB Page Frame       Ignored |  |    |   |    |   | Present
;                                                                   Global |    |   |    |
;                                                                         Dirty |   |    | User/Supervisor
;                                                               Page Cache Disabled |
;
;                                                                    Accessed |
;                                                               Page Size |   |    | Page Write Throught
; | NX             | Reserved                                    R |      |   |    |   | Read/Write
; |                |                                               |      |   |    |   |
; |X|XXX XXXX XXXX |0 .... M | M-1 .... X XXXX XXXX XXXX XXXX XXXX |X|XXX |0|X|X|X |X|X|X|1           <=== PD Entry page directory ===================
;   |                        |                                       |      |   |    |   |
;   | Ignored                | Address of PT table           Ignored |      |   |    |   | Present
;                                                                   Ignored |   |    | User/Supervisor
;                                                           Page Cache Disabled |
;
; | Ignored                                                                                          | Present
; |XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXX|0        <=== PD Entry not present ===================
;
;---------------------------------------------------------------------------------------------------------------------------------------------------
;
;                                                                      Accessed |    | Page Write Throught
;   | Protect key   | Reserved                                    R |   PAT |   |    |   | Read/Write
;   |               |                                               |       |   |    |   |
; |X|XXX X|XXX XXXX |0 .... M | M-1 .... X XXXX XXXX XXXX XXXX XXXX |X|XX|X |X|X|X|X |X|X|X|1           <=== PT Entry 4KB Page ===================
; |       |                   |                                       |  |    |   |    |   |
; | NX    | Ignored           | Address of 4KB page frame     Ignored |  |    |   |    |   | Present
;                                                                 Global |    |   |    |
;                                                                       Dirty |   |    | User/Supervisor
;                                                             Page Cache Disabled |
;
; | Ignored                                                                                          | Present
; |XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXX|0        <=== PT Entry not present ===================
;



;VMM_Map_PML4:
  ; get index pml4
  ; get entry from pml4
  ; if P == 1
  ;     get phys address PDPT
  ; else alloc 1 frame and create pdpt table
  ; get index pdpt
  ; if P == 0
  ;    if 1Gb Page == 1,
  ;        set p = 1, set ps=1, write phys address, set attributes, return
  ;    else alloc 1 frame and create pd table
  ; else if 1Gb Page == 1, error entry exists
  ; get index pd
  ; if P = 0
  ;    if 2Mb Page == 1
  ;        set p = 1, set ps=1, write phys address, set attributes, return
  ;    else alloc 1 frame and create pt table
  ; else if 2Mb Page == 1, error entry exists
  ; get index pt
  ; if P = 1, error, entry exists
  ; else write phys address in pt table, set p=1, set attributes, return
