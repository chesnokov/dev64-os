%include 'const.inc'
%include 'klib.inc'

%define dataOffset(a) (a-start)

global start
global gdt
global hello_world

extern dbg_clear_screen

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

align 32
; Address for the GDT
gdt:

align 1
; Null Segment
gdt_null:             
        dd 0
        dd 0

; Code segment, read/execute, nonconforming		
gdt_code:
        dw 0FFFFh
        dw 0
        db 0
        db 0x9a
        db 0xcf
        db 0

; Data segment, read/write, expand down
gdt_data:
        dw 0FFFFh
        dw 0
        db 0
        db 0x92
        db 0xcf
        db 0

; 16-bit code segment		
gdt_code16:
        dw 0FFFFh
        dw 0
        db 0
        db 0x9e
        db 0
        db 0

; 16-bit data segment
gdt_data16:
        dw 0FFFFh
        dw 0
        db 0
        db 0x92
        db 0
        db 0	
; 32-bit code segment
gdt_code32_start:
        dw 0FFFFh
        dw 0
        db 1
        db 0x9a
        db 0xcf
        db 0
		

gdtr:
	dw gdtr-gdt-1
	dd gdt

align 32
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
;  call i16initVideo
;
; 
;
; switch to protected mode
;
  mov ax, KERNEL_SEGMENT
  mov ds, ax
  mov es, ax

  cli
  mov al, 0xff
  out	0x21,al		; unmask all irqs of 8259a-1
  out	0xa1,al		; unmask all irqs of 8259a-2

  lgdt  [ds:dataOffset(gdtr)]
  
  in al, 0x92
  or al, 2
  out 0x92, al

  mov eax, cr0 
  or al, 1	
  mov cr0, eax 
  jmp 0x28:dataOffset(_protected)
  
  use32
_protected:
  jmp 0x8:start32
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

start_print:
  mov  edi, 0xB8000  ; video memory address
  
show_message:
  mov  esi, hello_world
  mov ah, 7
  cld
	
message_loop:                   
  lodsb                         
  test al, al                   
  jz   exit                    
  stosw
  cmp di, 0xB8000+25*80*2
  jl message_loop
  jmp start_print
exit:
  jmp $
  jmp show_message
  
hello_world:
  db 'Hello world', 0
SECTION .bss
    resb 8192               ; This reserves 8KBytes of memory here
_sys_stack:
