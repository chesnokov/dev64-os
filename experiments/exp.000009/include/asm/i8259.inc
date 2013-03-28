;
; This file includes macroses for i8259 interrupt controller
;

;
; mask all irq of 8259a-1 and 8259a-2
;
%macro i8259_mask_all 0
    mov  al, 0xff
    out  0x21, al    ; mask all irqs of 8259a-1
    out  0xa1, al    ; mask all irqs of 8259a-2  
%endmacro

;
; unmask all irq of 8259a-1 and 8259a-2
;
%macro i8259_unmask_all 0
    xor  al, al
    out  0x21, al    ; unmask all irqs of 8259a-1
    out  0xa1, al    ; unmask all irqs of 8259a-2  
%endmacro

;
; init i8259a for cascade mode
;
; Parameters
;   an interrupt vector number for irq 0
;   the interrupt vector number for irq 8
%macro i8259_init_cascade 2

    mov  al, 0x11    ; send ICW1 to both controllers
    out 0x20, al
    out 0xa1, al

    mov al, %1      ; ICW2
    out 0x21, al     ; set vector numbers mapping
    mov al, %2
    out 0xa1, al

    mov al, 0x4      ; ICW3
    out 0x21, al     ; set line for master and slave 
    mov al, 0x2
    out 0xa1, al

    mov al, 0x1     ; ICW4 special fully nested 8086 mode
    out 0x21, al
    mov al, 0x1     ; ICW4 fully nested 8086 mode
    out 0xa1, al

%endmacro

;
; mask irq for the first i8259a interrupt controller
;
%macro i8259_1_mask_irq 1
    in	al, 0x21
    or	al, 1<<%1
    out	0x21, al
%endmacro

;
; mask irq for the second i8259a interrupt controller
;
%macro i8259_2_mask_irq 1
    in al, 0xa1
    or al, 1<<%1
    out 0xa1, al
%endmacro

;
; unmask irq for the first i8259a interrupt controller
;
%macro i8259_1_unmask_irq 1
    in	al, 0x21
    and	al, ~(1<<%1)
    out	0x21, al
%endmacro

;
; unmask irq for the first i8259a interrupt controller
;
%macro i8259_2_unmask_irq 1
    in	al, 0xa1
    and	al, ~(1<<%1)
    out	0xa1, al
%endmacro

;
; send EOI (End Of Interrupt)
;
%macro i8259_1_eoi 0                             
    mov	al, 0x20
    out	0x20, al
%endmacro

%macro i8259_2_eoi 0
    mov al, 0x20
    out 0xa0, al
%endmacro

