
;
; prints memory map entries obtained by i16E820MemDetect
;
; Parameters:
; [DS:ESI] - address of first memory map entry
; BP - number of elements in memory map
;
; Return:
; None
;
; Clobbers:
; EAX, ECX
;
extern alPrint
extern numberPrintHex
extern printNL

segment .text
[bits 32]
global e820MemPrint

e820MemPrint:

  push esi
  movzx ecx, bp
.l1:
  call e820PrintMemInterval
  loop .l1
  pop esi

  ret


;
; prints one memory interval entry
;
; Parameters:
; [DS:ESI] - address of memory interval entry
; 
; Clobbers:
; EAX
;
e820PrintMemInterval:
  push ecx

  mov ecx, 8
  call numberPrintHex ; 00000000
  call localPrintSpace

  call numberPrintHex ; 00000000
  call localPrintSpace

  mov cx, 4
  call numberPrintHex ; '0000'
  call localPrintSpace

  call numberPrintHex ; '0000'
  call printNL

  pop ecx

  ret


;
; local function
;
localPrintSpace:

  mov al, ' ' 
  call alPrint
  
  ret  
	
	
