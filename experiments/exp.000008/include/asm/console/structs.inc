
;
; The structure for kernel console data
;
struc VtyData
  .windowOffset: resw 1
  .cursorOffset: resw 1
  .row: resb 1
  .col: resb 1
  .attrib: resb 1
endstruc

