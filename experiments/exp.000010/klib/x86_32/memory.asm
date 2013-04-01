;
; prints memory in hexadecimal form
; Parameters:
; [DS:ESI] - address in memory
; ECX - memory size
;
; Return
; Nothing
;
; Clobbers:
; esi
;
segment .text
[bits 32]
global memoryPrintHex
global memoryConvertToHex

extern alPrint
extern al2Hex

memoryPrintHex:
  push eax
  push ecx
  push ebx

  mov ebx, alPrint
.l1:
  lodsb
  call al2Hex
  loop .l1

  pop ebx
  pop ecx
  pop eax

  ret

;
; This function converts memory bytes pointed by
; register esi to hexadecimal form, place the 
; converted digit to register al and do callback
; to function passed in ebx register
; 
; Parameters:
; esi - pointer to memory to convert to hex form
; ecx - number of bytes
;
; Function use lodsb instruction inside, so direction
; flag 
memoryConvertToHex:
  push eax
  push ecx

.l2:
  lodsb
  call al2Hex
  loop .l2

  pop ecx
  pop eax

  ret
