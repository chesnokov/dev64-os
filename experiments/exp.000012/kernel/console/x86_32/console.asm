%include 'console/structs.inc'

;
; The structure below contains data used by console routines
;  

section .data
global vtyData

vtyData:

istruc VtyData
  at VtyData.windowOffset
    dw 0
  at VtyData.cursorOffset
    dw 0
  at VtyData.row
    db 0
  at VtyData.col
    db 0
  at VtyData.attrib
    db 7   ; default attribute
iend
