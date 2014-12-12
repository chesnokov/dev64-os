;
; 0x1000:0 is start position of kernel
; Boot loader puts kernel code in this address
;
KERNEL_SEGMENT equ 0x1000

;
; 0x60:0 - start of kernel data segment
; This address is used by kernel entry code
; for temporary store of different data from BIOS
;
KERNEL_DATA_SEGMENT equ 0x60

;
; 0x60:0xf9f0 - initial stack pointer used in Real Mode
; This address is used for kernel stack by kernel entry code
;
KERNEL_START_SP equ 0xf9f0

;
; KERNEL_SEGMENT_DESCRIPTOR
;
KERNEL_SEGMENT_DESCRIPTOR equ 0x8

;
;
;
KERNEL_DATA_DESCRIPTOR equ 0x10
;
; This physical address is used for page directory entry
; The page table after this
;
PAGE_DIRECTORY equ 0x1000
;
; This physical address is used for memory allocation
;
MEMORY_ALLOCATION_PAGE equ 0x3000
;
;
; Base address of the kernel virtual address range
;
KERNEL_VIRTUAL_BASE equ 0xffc00000
;
;
;
MEMORY_ALLOCATION_BASE equ 0xff800000
