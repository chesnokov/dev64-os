%include 'kernel/consts.inc'
%include 'kernel/pit.inc'
%include 'klib.inc'
%include 'console/consts.inc'
%include 'console/structs.inc'
%include 'i8259.inc'
%include 'kernel/utils.inc'

%define dataOffset(a) (a-start)

global start
global gdt
global kernelInit
global hello_world

extern e820MemPrint
extern alPrint
extern strPrint
extern initVideo
extern updateCursor
extern _sys_stack
extern idt_set_handlers
extern turn_on_paging
extern sys_uptime
extern memPrintHex
extern vtyData
extern al2Hex
extern memPrintH
extern irq0_fractions

section .text16
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
; Global address for the GDT
gdt:

align 1
;
; Null Segment
gdt_null:             
    dd 0
    dd 0
;
; Code segment, read/execute, nonconforming		
;
gdt_code:
    dw 0FFFFh
    dw 0
    db 0
    db 0x9a
    db 0xcf
    db 0
;
; Data segment, read/write, expand down
;
gdt_data:
    dw 0FFFFh
    dw 0
    db 0
    db 0x92
    db 0xcf
    db 0
;
; 16-bit code segment		
;
gdt_code16:
    dw 0FFFFh
    dw 0
    db 0
    db 0x9e
    db 0
    db 0
;
; 16-bit data segment
;
gdt_data16:
    dw 0FFFFh
    dw 0
    db 0
    db 0x92
    db 0
    db 0	
;	
; 32-bit code segment
;
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

;
; CPU is in Real Mode yet
; 
align 8
kernelInit:
align 1
;
; initialize data segment for real mode memory detection routine
;
    mov ax, KERNEL_DATA_SEGMENT
    mov ds, ax
    mov es, ax
;
; set stack pointer points to the memory 
; immediately before the kernel start
;
    mov ss, ax
    mov sp, KERNEL_START_SP
;  
; put memory table at es:di 
; input es:di -> address for memory table
; output bp -> entry count
; bp register should be left intact before it will be 
; stored in 
    xor  di, di
    mov si, di
    call i16E820MemDetect
;
; switch to protected mode
;
    mov ax, KERNEL_SEGMENT
    mov ds, ax
    mov es, ax
;
; mask maskable interrupts in CPU
;
    cli
;
;
;
    lgdt  [ds:dataOffset(gdtr)]
;
; turn on A20 line, allow 32 bits addressing
;
    in al, 0x92
    or al, 2
    out 0x92, al
;
; turn on protected mode
;
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
    section .text16
    [BITS 32]
    global start32
start32:
    mov  ax, 0x10  ;  second descriptor is our data segment
    mov  ds, ax
    mov  es, ax
    mov  gs, ax
    mov  fs, ax
    mov  ss, ax
;
; temporary stack while paging is turned off
; when paging is turned on then all global external
; addresses in all segments except .text16 are mapped
; to virtual memory at the last page of memory
; 0xffc00000. _sys_stack is mapped also. So use temporary
; stack before turn_on_paging and assign _sys_stack after that
;
    mov esp,0x10000-4
;
; Turn on paging
;
    call turn_on_paging
    mov  esp,_sys_stack
;
; store memory map entry count from bp
;
    mov [mm_entry_count], bp
;
; initialize Programmable Interval Timer to generate
; IRQ0 once per 1 millisecond (i.e. 100 times/s).
;
    init_pit
;
; initialize kernel text mode console
;    
    call initVideo
;
; print detected memory map (mm)
;
    print ok_message
    print protected_mode_message
    print mm_message
;
; print memory map which where obtained from BIOS
; by function i16E820MemDetect earlier
; actually the length 
;
    mov esi, KERNEL_DATA_SEGMENT * 0x10
    call e820MemPrint
    call updateCursor
;
; set up interrupt handlers
;   
   call idt_set_handlers
;
; initialize i8259 cascade mode
; remap interrupt 0 to vector 0x20
; remap interrupt 8 to vector 0x28
;
    i8259_init_cascade 0x20,0x28
    i8259_unmask_all
    sti
  
kernel_loop:
    hlt
    print_hex_in_position sys_uptime,4,0,0
    jmp kernel_loop

kernel_loop_message:
    db 'interrupt received', CR, LF, 0
ok_message:
    db 'ok', CR, LF, 0
protected_mode_message:
    db 'entered protected mode...ok', CR, LF, 0
mm_message:
    db CR, LF, 'memory map:', CR, LF, 0

    section .data
global mm_entry_count
mm_entry_count:
    dd 0
