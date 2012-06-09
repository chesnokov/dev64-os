; 
; Prints number specified by ds:si  in hex format
; the length of number is passed in cx
; 
; at the end of operation si += cx
; clobbers 
; AX
;
segment .text
[bits 16]
global i16NumberPrintHex

extern i16MemPrintHex                

i16NumberPrintHex:
  push cx
  mov ax, si
  add ax, cx
  push ax     ; ax = si + cx
  dec ax
  mov si,ax
  pushf
  std
  call i16MemPrintHex
  popf
  pop si       ; restore si from stack
  pop cx
  ret