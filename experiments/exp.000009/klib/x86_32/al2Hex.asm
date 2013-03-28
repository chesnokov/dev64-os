;
; converts byte in al to hexadecimal format
; and pass it to function specified by ebx register
;
; Parameters:
; AL - byte to convert to hex
; EBX - callback function to be called for each 
;      converted digit. The digit will be passed
;      to the callback function in AL
;
; Return value:
; None
;
; Clobbered registers
; None (callback should preserve all registers)
;

  segment .text
  [bits 32]
  global al2Hex

al2Hex:
  push ax
  mov ah, 1
  rol al, 4 ; get high half byte first
.l1:
  and al, 0xf
  cmp al, 10
  jl .m1
  add al, 7  
.m1:  
  add al, 0x30
  push ax
  call ebx
  pop ax
  cmp ah,0
  je .m2
  pop ax ; restore original byte
  push ax
  xor ah,ah
  jmp .l1
.m2:
  pop ax 
  ret
