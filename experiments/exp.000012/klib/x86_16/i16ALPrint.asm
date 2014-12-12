;
; prints character from AL register using BIOS function 0x10
;
; Parameters:
; AL - character
;
; Return:
; Nothing
;
; Clobbers:
; Nothing
;
  segment .text16
  [bits 16]
  global i16ALPrint

i16ALPrint:

  push ax
  push bx
  mov ah, 0xe
  xor bh,bh
  int 0x10
  pop bx
  pop ax

  ret
