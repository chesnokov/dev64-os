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

    push eax
    push ebx
    
    mov eax, [irq0_fractions]
    mov ebx, [sys_uptime]
    add eax, 293984
    mov [irq0_fractions], eax
    adc ebx, 1
    mov [sys_uptime], ebx    
    ; send end of interrupt
    i8259_1_eoi

    pop ebx
    pop eax
    iretd

section .data
global sys_uptime
global irq0_fractions

sys_uptime:
    dd 0
irq0_fractions:
    dd 0

