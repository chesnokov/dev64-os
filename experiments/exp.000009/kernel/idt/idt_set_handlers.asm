%include 'kernel/consts.inc'
%include 'kernel/idt/idt.inc'

section .text
global idt_set_handlers
[bits 32]

extern global_idtr
extern idt_irq_0_handler
extern idt_irq_1_handler

align 4

;
; Setup global Interrupt Descriptor Table
;
;
idt_set_handlers:

align 1

;
; set timer interrupt handler
;
    idt_set_interrupt_gate 0x20, idt_irq_0_handler
;
; set keyboard interrupt handler
;
    idt_set_interrupt_gate 0x21, idt_irq_1_handler

;
; load idt address register
;
    lidt [ds:global_idtr]
    ret
