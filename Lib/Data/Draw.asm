; DAE Data ---------------------------------------------
DAE_X                 dq 0           ;X coordinate symbols
DAE_Y                 dq 0           ;Y coordinate symbols
DAE_Color             dd 0           ;Color Symbols
DAE_FrameBuffer       dq 0           ;Pointer BF
DAE_FrameBufferSize   dq 0           ;Size BF
DAE_HEX_Text          dq 0, 0        ;Text, 64 bit in format HEX, after converting
                      db 0
DAE_Hello_World       db "Hello World!", 0
DAE_Display_Symbols_Heigth    dq 91
DAE_Display_Symbols_Width     dq 160
DAE_Display_Heigth            dq 640
DAE_Display_Width             dq 800
DAE_Symbol_Height             dq 7
DAE_Symbol_Width              dq 5

DAE_Chars:
  %include "CharsTable.asm"
  
