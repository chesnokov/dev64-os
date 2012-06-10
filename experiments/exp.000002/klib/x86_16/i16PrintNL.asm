;
; prints NL (new line) character to screen
;
; Parameters:
; None
;
; Return:
; Nothing
;
; Clobbers
; Nothing
;
segment .text
[bits 16]
global i16PrintNL

extern i16ALPrint

i16PrintNL:
  push ax
  mov al, 0xd
  call i16ALPrint
  mov al, 0xa
  call i16ALPrint
  pop ax

  ret