;
; __cdecl int puts(const char * str);
;
; Parameters:
; str - zero terminated string
;
; Returns:
; string length
;
  segment .text
  [bits 32]
  global puts
  
  extern alPrint
  
puts:
  push ebp
  mov ebp, esp
  push esi
  mov esi, [ ebp + 8 ]
.putsLoop:
  lodsb
  test al, al
  jz .endPuts
  call alPrint
  jmp .putsLoop
.endPuts:
  sub esi, [ ebp + 8 ]
  mov eax, esi
  pop esi
  leave
  ret
  