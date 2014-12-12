%include 'i8259.inc'
%include 'kernel/idt/idt.inc'


section .text
global idt_irq_1_handler
[bits 32]

;
; keyboard interrupt handler
;
align 16
idt_irq_1_handler:
align 1

    push ax
; handle keyboard input    
    handle_keyboard_input   
; send end of interrupt
    i8259_1_eoi
   
    pop ax
    iretd
    
