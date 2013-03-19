;
; set interrupt handlers
;
%include 'kernel/consts.inc'
%include 'kernel/idt/idt.inc'

section .text
global idt_set_handlers
[bits 32]

extern global_idt
extern global_idtr
extern idt_irq_0_handler
extern idt_handler_gp

align 4

idt_set_handlers:

align 1

    ; set interrupt handlers
    idt_set_interrupt_gate 0x20, idt_irq_0_handler

    ; load idt address register
    lidt [ds:global_idtr]
    ret