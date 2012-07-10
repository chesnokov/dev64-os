;
; prints string specified by [DS:SI]
;
; Parameters:
; [DS:SI] - zero terminated string
;
; Return:
; Nothing
;
; Clobbers:
; SI, AL
;
  segment .text
  [bits 32]
  global strPrint
  
  extern alPrint
  
strPrint:
  lodsb
  test al, al
  jz .endStrPrint
  call alPrint
  jmp strPrint
.endStrPrint:  
  ret