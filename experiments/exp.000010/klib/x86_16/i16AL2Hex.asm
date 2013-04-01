;
; converts byte in al to hexadecimal format
; and pass it to function specified by bx register
;
; Parameters:
; AL - byte to convert to hex
; BX - callback function to be called for each 
;      converted digit. The digit will be passed
;      to the callback function in AL
;
; Return value:
; None
;
; Clobbered registers
; None (if callback function do not trash registers)
;

  segment .text16
  [bits 16]
  global i16AL2Hex

i16AL2Hex:
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
  call bx
  cmp ah,0
  je .m2
  pop ax ; restore original byte
  push ax
  xor ah,ah
  jmp .l1
.m2:
  pop ax 
  ret
  
