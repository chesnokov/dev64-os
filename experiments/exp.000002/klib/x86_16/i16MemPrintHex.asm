;
; prints memory in hexadecimal form
; Parameters:
; [DS:SI] - address in memory
; CX - memory size
;
; Return
; Nothing
;
; Clobbers:
; Nothing
;  
segment .text
[bits 16]
global i16MemPrintHex

extern i16ALPrint
extern i16AL2Hex


i16MemPrintHex:
  push ax
  push cx
  push ebx
  mov ebx, i16ALPrint
.l1:
  lodsb
  call i16AL2Hex
  loop .l1
  pop ebx
  pop cx
  pop ax

  ret