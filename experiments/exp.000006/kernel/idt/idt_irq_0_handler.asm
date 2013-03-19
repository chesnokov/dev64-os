;
; timer interrupt handler
;
%include 'i8259.inc'
%include 'kernel/idt/idt.inc'

section .text
global idt_irq_0_handler
[bits 32]

align 16
idt_irq_0_handler:
align 1

    push ax
    ; send end of interrupt
    i8259_1_eoi
   
    pop ax
    iretd
    
