%include 'kernel/consts.inc'
;
PAGE_SIZE equ 0x1000
;
; Page directory entry flags
;
PDE_P equ 1b
PDE_W equ 10b
PDE_U equ 100b
PDE_PS equ 0x80
;
; Page table entry flags
;
PTE_P equ 1b
PTE_W equ 10b
PTE_U equ 100b
;
; CR4 register PSE flag is 4th bit in this register
;
PSE_BIT equ 0x10
;
; first parameter - base address of page directory
; second parameter - entry number
; last parameter - entry value
;
; Flags are added automatically
; P | W | U
;
%macro assign_pd_entry 3
    mov eax, ((%3) | PDE_P | PDE_W)
    mov [ %1 + (%2 * 4) ], eax
%endmacro

%macro turn_pg_on 0
;
; Turn on PG
;
  mov eax, cr0
  or eax, 0x80000000
  mov cr0, eax
%endmacro


    section .text16
    [BITS 32]
    global turn_on_paging

;
; This function turns paging on
; Clobbers eax, ecx, edi
turn_on_paging:
;
; Use two subsequent pages to store a page directory (PD)
; and a page table (PT)
;
; The first page is the page directory (PD)
; The second is the page table (PT)
;
  xor eax, eax
;
; Place edi the address of PD, use it as base address
; when access PD and PTs
;
  mov edi, PAGE_DIRECTORY
;
; 2 pages of double words
;
  mov ecx, 2 * PAGE_SIZE/4
; save edi for future use
  push edi
  rep stosd
  pop edi
;
; Now we have 2 empty subsequent pages filled with 0s
;
; Each page directory entry contains reference to 4M region
; or page table. If entry is not marked with P (present) flag
; then such entry is ignored. We filled pages with 0s so all
; entries in the page directory are marked "not present"
;
; assign first entry reference to the first page table
; assign_pd_entry edi, 0, ((PAGE_DIRECTORY + PAGE_SIZE) | (PDE_U))
  assign_pd_entry edi, 0, ( 0 | PDE_PS)
;
; assign page table for memory allocation tables
;
  assign_pd_entry edi, 1022, (PAGE_DIRECTORY + PAGE_SIZE)
; assign last entry reference to the the address 0
; to have kernel area here
  assign_pd_entry edi, 1023, (0 | PDE_PS)
;
; Now we have page directory and one page table
; for address range 0xff800000-0xffc00000
; Address 0xff800000 will be used by memory
; allocation tables
  add edi, PAGE_SIZE
  mov eax, MEMORY_ALLOCATION_PAGE | PTE_P | PTE_W
  mov [ edi ], eax
;
;
; Fill the first page table
; Fill only 1st Megabyte of pages (256 entries)
;  mov ecx, 0x100000 / 4096
; Each entry is present and writable
;  mov eax, PTE_P | PTE_W
; edi contains pointer to the PD
; add page size to have a pointer to the PT
;  add edi, PAGE_SIZE
;
;.l1:
;	stosd
; Increment by 0x1000 to have 0, 0x1000, 0x2000, ...
; sequence in page table entries
;	add eax, PAGE_SIZE
;	loop .l1
;
; Setup cr3 page directory base address
;
  mov eax, PAGE_DIRECTORY
  mov cr3, eax
;
; Turn on PS flag of cr4 register
; which allows using of 4M pages
;
  mov eax, cr4
  or eax, PSE_BIT
  mov cr4, eax
;
;
;
  turn_pg_on

  ret







