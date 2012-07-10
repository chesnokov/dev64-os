;
; Writes al to VGA register specified by ah
; Parameters 
; ah - register number
; al - value
; 
;
; Clobbers
; dx, al
;
%include 'console.inc'

section .text
[bits 32]

global writeVGAReg

writeVGAReg:
  mov dx, VGA_ADDR_REG
  xchg ah, al
  out dx, al
  inc dx
  xchg ah,al
  out dx, al
  ret