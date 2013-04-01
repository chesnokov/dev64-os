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
%include 'console/consts.inc'

segment .text
[bits 32]
global printNL

extern alPrint

printNL:
  push ax
  mov al, CR
  call alPrint
  mov al, LF
  call alPrint
  pop ax

  ret
