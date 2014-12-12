extern global_idt
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

;
; Handle keyboard input
;
%macro handle_keyboard_input 0
  extern al2Hex
  extern alPrint
  extern updateCursor
;
; Read keyboard controller status register
; When bit 0 is set to 1, this bit indicates the
; controller placed data into its output buffer
; but the system microprocessor has not yet read the
; data. When the system microprocessor read the 
; output buffer (address 0x60), this bit returns 0
; This mean if bit 0 is 0 then nothing to do
  in al, 0x64
  test al, 1
  jz %%finish_macro
; Read keyboard scancode
  in al, 0x60
; Convert to hex and print
  push ebx
  mov ebx, alPrint
  call al2Hex
  call updateCursor  
  pop ebx
; local macro label
; @ see http://www.nasm.us/xdoc/2.10.01/html/nasmdoc4.html#section-4.3.2
%%finish_macro:
%endmacro
