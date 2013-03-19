%include 'console/consts.inc'
%include 'console/structs.inc'

section .text
[bits 32]

extern vtyData
extern readVGAReg
extern alPrint
extern numberPrintHex

global initVideo

;
; initializes VtyData structure for the future use
; Parameters:
; None
;
; Output:
; None
;
; Clobbers:
; ax, dx
;
initVideo:
  call saveCursor
  call calcOffset
  ret
  
;
; gets cursor position from VGA controller
; and saves it in VtyData structure
;
; Clobbers:
; dx, al
;
saveCursor:
  mov al, VGA_CURSOR_LOW
  call readVGAReg
  mov  byte [ vtyData + VtyData.row ], al
  mov al, VGA_CURSOR_HIGH
  call readVGAReg
  mov ah, al
  mov al, [ vtyData + VtyData.row ]
  mov dl, CONSOLE_COLUMNS
  div dl
  mov byte [ vtyData + VtyData.row ], al
  mov byte [ vtyData + VtyData.col ], ah
  ret

;
; calculates the position of cursorOffset
; Parameters:
; VtyData.row, VtyData.col, VtyData.windowOffset
;
; Output:
; VtyData.cursorOffset
;
; Clobbers:
; ax, dx
;
calcOffset:
  mov al, [ vtyData + VtyData.row ]
  mov dl, CONSOLE_COLUMNS 
  mul dl
  movzx dx, byte [ vtyData + VtyData.col ]
  add ax, dx
  shl ax, 1
  mov [ vtyData + VtyData.cursorOffset ], ax
  ret
  

