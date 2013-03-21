; 
; Prints number specified by [ds:esi]  in hex format
; the length of the number is passed in cx
; 
; Parameters:
; [DS:ESI] - address of number to print
; ECX - number of bytes in number
;
; Return:
; at the end of operation ESI += ECX
;
; Clobbers 
; Nothing
;
segment .text
[bits 32]
global numberPrintHex

extern memPrintHex                

numberPrintHex:
  push eax
  push ecx
  mov eax, esi
  add eax, ecx
  push eax     ; eax = esi + ecx
  dec eax
  mov esi, eax
  pushf
  std
  call memPrintHex
  popf
  pop esi       ; restore si from stack
  pop ecx
  pop eax
  ret