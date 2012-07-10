
;
; prints memory map entries obtained by i16E820MemDetect
;
; Parameters:
; [DS:SI] - address of first memory map entry
; BP - number of element in memory map
;
; Return:
; None
;
; Clobbers:
; AX, CX
;
extern i16ALPrint
extern i16NumberPrintHex
extern i16PrintNL

segment .text
[bits 16]
global i16E820MemPrint



i16E820MemPrint:

  push si
  mov cx, bp
  call i16PrintNL
.l1:
  call i16E820PrintMemInterval
  loop .l1
  pop si

  ret


;
; prints one memory interval entry
;
; Parameters:
; [DS:SI] - address of memory interval entry
; 
; Clobbers:
; AX
;
i16E820PrintMemInterval:
  push cx

  mov cx, 8
  call i16NumberPrintHex ; 00000000
  call localPrintSpace

  call i16NumberPrintHex ; 00000000
  call localPrintSpace

  mov cx, 4
  call i16NumberPrintHex ; '0000'
  call localPrintSpace

  call i16NumberPrintHex ; '0000'
  call i16PrintNL

  pop cx

  ret


;
; local function
;
localPrintSpace:

  mov al, ' ' 
  call i16ALPrint
  
  ret  
	
	
