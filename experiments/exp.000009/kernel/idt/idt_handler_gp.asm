;
; General protection fault handler
;
%include 'kernel/consts.inc'
%include 'kernel/idt/consts.inc'
%include 'kernel/idt/idt.inc'
%include 'console/consts.inc'

section .text
[bits 32]
global idt_handler_gp

extern strPrint
extern numberPrintHex
extern printNL

align 16

idt_handler_gp:
    idt_pusha
	
    ; print '*general protection fault: '
    mov ax, KERNEL_DATA_SEGMENT
    mov ds, ax
    mov esi, gp_message
    call strPrint
	
	  ; print the error code from a stack (esp+48)
    mov ax, ss      ; ds = ss
    mov ds, ax 
    mov esi, esp
    add esi, IDT_ALLREG_SIZE
    mov ecx, 4
    call numberPrintHex
    call printNL
	  
    ; restore the registers, throw away the error code from the stack
    idt_popa
    add esp, 4      ; 4 is the size of the error code
    iretd

section .data

gp_message:
    db CR, LF, '*general protection fault: '