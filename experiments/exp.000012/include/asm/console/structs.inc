
;
; The structure for kernel console data
;
struc VtyData
;
; The offset of the first byte of video memory which is visible at position 0
;
  .windowOffset: resw 1
;
; Cursor offset of start of 'current window'
;
  .cursorOffset: resw 1
;
; Cursor current row
;
  .row: resb 1
;
; Current attributes
;
  .col: resb 1
;
; Character attributes used for output
;
  .attrib: resb 1
endstruc

