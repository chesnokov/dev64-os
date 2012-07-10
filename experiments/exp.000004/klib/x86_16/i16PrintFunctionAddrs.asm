;
; prints function addresses
; just for DEMO purpose
;
; Parameters
; No
;
; Return
; Nothing
;
; Clobbers
; AX
;
segment .text
[bits 16]
global i16PrintFunctionAddrs

extern i16AL2Hex
extern i16ALPrint
extern i16E820MemDetect
extern i16E820MemPrint
extern i16MemPrintHex
extern i16NumberPrintHex
extern i16PrintNL

i16PrintFunctionAddrs:
  push dword i16PrintNL
  push dword i16NumberPrintHex
  push dword i16MemPrintHex
  push dword i16E820MemPrint
  push dword i16E820MemDetect
  push dword i16ALPrint
  push dword i16AL2Hex
  
  mov si, sp
  mov cx, 7
.l1:
  call localPrintOneNumber
  loop .l1
  
  add sp, 4*7
  ret
  
; [DS:SI] - number
localPrintOneNumber:
  push cx
  mov cx, 4
  call i16PrintNL
  call i16NumberPrintHex
  pop cx
  ret
  