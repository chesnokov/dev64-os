; 
; Prints number specified by [ds:si]  in hex format
; the length of number is passed in cx
; 
; Parameters:
; [DS:SI] - address of number to print
; CX - number of bytes in number
;
; Return:
; at the end of operation si += cx
;
; Clobbers 
; Nothing
;
segment .text16
[bits 16]
global i16NumberPrintHex

extern i16MemPrintHex                

i16NumberPrintHex:
  push ax
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
  pop ax
  ret
