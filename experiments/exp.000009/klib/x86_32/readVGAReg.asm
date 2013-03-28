;
; Reads VGA register to al
;
; Parameters
; al - register number
;
; Clobbers
; dx,al
;
%include 'console/consts.inc'

section .text
[bits 32]

global readVGAReg

readVGAReg:
  mov dx, VGA_ADDR_REG
  out dx, al
  inc dx
  in al, dx
  ret
