;
; The IDT table
;
section .data
global global_idt
global global_idtr

align 16
global_idt:
align 1
    dd 0, 0          ; 0x0
    dd 0, 0          ; 0x1
    dd 0, 0          ; 0x2
    dd 0, 0          ; 0x3
    dd 0, 0          ; 0x4
    dd 0, 0          ; 0x5
    dd 0, 0          ; 0x6
    dd 0, 0          ; 0x7
    dd 0, 0          ; 0x8
    dd 0, 0          ; 0x9
    dd 0, 0          ; 0xa
    dd 0, 0          ; 0xb
    dd 0, 0          ; 0xc
    dd 0, 0          ; 0xd
    dd 0, 0          ; 0xe
    dd 0, 0          ; 0xf
    dd 0, 0          ; 0x10
    dd 0, 0          ; 0x11
    dd 0, 0          ; 0x12
    dd 0, 0          ; 0x13
    dd 0, 0          ; 0x14
    dd 0, 0          ; 0x15
    dd 0, 0          ; 0x16
    dd 0, 0          ; 0x17
    dd 0, 0          ; 0x18
    dd 0, 0          ; 0x19
    dd 0, 0          ; 0x1a
    dd 0, 0          ; 0x1b
    dd 0, 0          ; 0x1c
    dd 0, 0          ; 0x1d
    dd 0, 0          ; 0x1e
    dd 0, 0          ; 0x1f
    dd 0, 0          ; 0x20 (hardware intr 0)
    dd 0, 0          ; 0x21
    dd 0, 0          ; 0x22
    dd 0, 0          ; 0x23
    dd 0, 0          ; 0x24
    dd 0, 0          ; 0x25
    dd 0, 0          ; 0x26
    dd 0, 0          ; 0x27
    dd 0, 0          ; 0x28
    dd 0, 0          ; 0x29
    dd 0, 0          ; 0x2a
    dd 0, 0          ; 0x2b
    dd 0, 0          ; 0x2c
    dd 0, 0          ; 0x2d
    dd 0, 0          ; 0x2e
    dd 0, 0          ; 0x2f
    dd 0, 0          ; 0x30
    dd 0, 0          ; 0x31
    dd 0, 0          ; 0x32
global_idt_size    equ $-global_idt
global_idtr:
    dw global_idt_size-1
    dd global_idt
