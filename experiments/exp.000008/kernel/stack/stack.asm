global _sys_stack

SECTION .bss    

    resb 0x2000   ; This reserves 8KBytes of memory here
_sys_stack:
