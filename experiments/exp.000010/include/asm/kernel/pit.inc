;
; Program Interval Timer Constants
; for additional details 
; @see http://wiki.osdev.org/PIT
;
; PIT channels
; 
; channel 0
PIT_CH0 equ 0x0 
; channel 1
PIT_CH1 equ 0x80
; channel 2
PIT_CH2 equ 0xc0
;
; PIT access modes
;
PIT_AM_LATCH equ 0
PIT_AM_LO equ 0x10
PIT_AM_HI equ 0x20
PIT_AM_LOHI equ 0x30
;
; PIT operating mode
;
PIT_OM_0 equ 0
PIT_OM_1 equ 0x2
PIT_OM_2 equ 0x4
PIT_OM_3 equ 0x6
PIT_OM_4 equ 0x8
PIT_OM_5 equ 0xa
;
; PIT BCD/binary
;
PIT_BINARY equ 0
PIT_BCD equ 1
;
; This file contains macro for Programmable Interval Timer
; It setup PIT channel 0 to generate IRQ0 100 times per second
; I.e. 1 per millisecond
;
%macro init_pit 0
; mode 2 rate generator
; access mode low/hi byte
; channel 0 
  mov al, ( PIT_CH0 | PIT_AM_LOHI |  PIT_OM_2 )
  out 0x43, al
; divider 11931 for ~100 Hz (0x2e9b)
; low byte is 0x9b  
  mov al, 0x9b
  out 0x40, al
; high byte is 0x2e
  mov al, 0x2e
  out 0x40, al
%endmacro
