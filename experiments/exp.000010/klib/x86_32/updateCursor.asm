%include 'console/consts.inc'
%include 'console/structs.inc'

  segment .text
  [bits 32]
  global updateCursor
  
  extern vtyData  ; console data structure
  extern writeVGAReg

updateCursor:
  push cx
  mov cx, [ vtyData + VtyData.windowOffset ]
  add cx, word [ vtyData + VtyData.cursorOffset ]
  shr cx, 1
  xchg ch, al
  mov ah, 0xe
  call writeVGAReg
  mov ah, 0xf
  xchg cl, al
  call writeVGAReg  
  pop cx
  ret
