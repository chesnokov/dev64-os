;
; Some constants and structures for console routines
;
VIDEO_BUFFER_ADDR equ 0xB8000
;
; The number of text columns console has
;
CONSOLE_COLUMNS equ 80
;
; The number of text rows the console has
;
CONSOLE_ROWS equ 25
;
; Current window maximum offset
;
CONSOLE_WINDOW_MAX_OFFSET equ CONSOLE_ROWS * CONSOLE_COLUMNS * 2 
;
; CONSOLE_WINDOW_SIZE
;
CONSOLE_WINDOW_SIZE equ CONSOLE_ROWS * CONSOLE_COLUMNS * 2
;
; Special characters supported by kernel console functions
;
LF equ 0xa
CR equ 0xd
BACKSPACE equ 0x8
;
; VGA control (CRTC) registers
; @ http://www.osdever.net/FreeVGA/vga/crtcreg.htm
;
VGA_ADDR_REG equ 0x3d4
VGA_DATA_REG equ 0x3d5
;
; Cursor registers
;
VGA_CURSOR_HIGH equ 0xe
VGA_CURSOR_LOW equ 0xf

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

