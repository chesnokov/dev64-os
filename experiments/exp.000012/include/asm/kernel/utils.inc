;
; Some helper macros
;
%macro print 1
    mov esi, %1
    call strPrint
%endmacro

;
; calculate offset by position
;
%macro consolePositionTo.edi 2
    mov di, (%1 * 80  + %2) * 2
    add di, [ vtyData + VtyData.windowOffset ]
    movzx edi, di
%endmacro

%macro console.printInSpecifiedPosition 4
%%base.address:
    mov esi, %1
    mov ecx, %2
        
    consolePositionTo.edi %3,%4
;
; Next three lines used to get local address
;
;    call %%base.address
;%%base.address:
;    pop ebx
;    add ebx, %%callback.function - %%base.address
    mov ebx, %%callback.function 
    call memoryConvertToHex
    jmp %%finish.macro
    
%%callback.function:    
    mov ah, [ vtyData + VtyData.attrib ]
    mov [ VIDEO_BUFFER_ADDR + edi ], ax
    inc edi
    inc edi
    ret
 
%%finish.macro:
%endmacro