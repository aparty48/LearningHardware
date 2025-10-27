EFI:
%include "src/lib/EFI.asm"

Core:
%include "src/Core.asm"
Core_END:
Temp_Core_Physical_Address dq 0
Temp_Core_Stack_Physical_Address dq 0
Temp_Size_MemMap_In_Pages dq 0
Temp_Pointer_PMM_Map dq 0
Temp_Pointer_Init_Data_Structure dq 0
