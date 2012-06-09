%include 'const.inc'
%include 'klib.inc'

%define dataOffset(a) (a-start)


global start

section .text
[BITS 16]
;
; 16-bit sergment
; kernel entry point
; Boot Loader will pass control here
; works in real mode yet
;
start:
  jmp kernelInit
;
; some data may be placed here in the future
; probably GDT data for example
;
kernelInit:
;
; initialize data segment for real mode memory detection routine
;
  mov ax, KERNEL_DATA_SEGMENT
  mov ds, ax
  mov es, ax
  mov ss, ax
  mov sp, KERNEL_START_SP
  xor  di,di
  mov si,di
;  
; put memory table at es:di 
; input es:di -> address for memory table
; output bp -> entry count
;  
  call i16E820MemDetect
  call i16E820MemPrint
  jmp $
;
; 32-bit protected mode code
;
  section .text
  [BITS 32]
  global start32
start32:
  mov  ax, 0x10  ;  second descriptor is our data segment
  mov  ds, ax
  mov  es, ax
  mov  gs, ax
  mov  fs, ax
  mov  ss, ax
  mov  esp,_sys_stack
  sti

  mov  edi, 0xB8000  ; video memory address
;  extern get_hello
show_message:
;  call get_hello
;  mov  esi, eax  ; message
;  cld

;message_loop:
;  lodsb
;  test al, al
;  jz   exit
;  stosb
;  mov  al, 7
;  stosb
;  jmp  message_loop
exit:

 ; extern dbg_scroll_screen
 ; push 1
 ; call dbg_scroll_screen
 ; add esp,4

 ; cli
  jmp show_message


SECTION .bss
    resb 8192               ; This reserves 8KBytes of memory here
_sys_stack:
