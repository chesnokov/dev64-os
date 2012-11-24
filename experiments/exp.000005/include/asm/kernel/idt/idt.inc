;
; This file contains definitions of macros for IDT manipulation
; 
; Parameters
; vector number
; handler address
;
; Clobbers eax, esi
; 
%macro idt_set_interrupt_gate 2
    ; copy address of interrupt handler
    mov eax, %2
    mov esi, global_idt
    mov [esi + 8*%1], ax
    shr eax, 16
    mov [esi + 8*%1 + 6 ], ax
    ; set interrupt segment
    mov word [esi + 8*%1 + 2], KERNEL_SEGMENT_DESCRIPTOR
    ; set interrupt_gate_parameters
    mov word [esi + 8*%1 + 4], 1000111000000000b
%endmacro

;
; Preserve all registers
;
%macro	idt_pusha 0
    push	ds
    push	es
    push	fs
    push	gs
    pusha
%endmacro

;
; Restore all registers
;
%macro	idt_popa 0
    popa
    pop	gs
    pop	fs
    pop	es
    pop	ds
%endmacro
