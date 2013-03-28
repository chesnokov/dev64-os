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
%macro calc_console_position 2
    mov di, (%1 * 80  + %2) * 2
    add di, [ vtyData + VtyData.windowOffset ]
    movzx edi, di
%endmacro

;
; The parameters:
;
%macro printAbsoluteAL 0
    mov ah, [ vtyData + VtyData.attrib ]
    mov [ VIDEO_BUFFER_ADDR + edi ], ax
    inc edi
    inc edi
%endmacro

%macro print_in_position 3
    mov esi, %3
    calc_console_position %1,%2
%%continue_print_in_position:
    printAbsoluteAL
    lodsb
    test al, al
    jnz %%finish_print_in_position
%%finish_print_in_position:
%endmacro

%macro print_hex_in_position 4
    mov esi, %1
    mov ecx, %2
        
    calc_console_position %3,%4
    mov ebx, %%print_lambda
    call memPrintH
    jmp %%finish_print_hex_in_position
    
align 8    
global %%print_lambda
%%print_lambda:    
align 1
    printAbsoluteAL
    ret
 
%%finish_print_hex_in_position:
%endmacro