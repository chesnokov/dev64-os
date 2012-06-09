;
; Kernel assembly function list
;

;
; Real Mode functions
;


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
extern i16AL2Hex

;
; prints character from AL register using BIOS function 0x10
;
; Parameters:
; AL - character
;
; Return:
; Nothing
;
; Clobbers:
; Nothing
;
extern i16ALPrint

;
; get available memory map using INT 0x15, eax=0xE820
;
; Parameters:
; [DS:SI] - address where to place memory map entries
;
; Return values:
; BP - number memory map entries (records)
;
; Clobbered registers:
; All registers except ESI
;
extern i16E820MemDetect

;
; prints memory map entries obtained by i16E820MemDetect
;
; Parameters:
; [DS:SI] - address of first memory map entry
; BP - number of element in memory map
;
; Return:
; None
;
; Clobbers:
; AX, CX
;
extern i16E820MemPrint

;
; prints memory in hexadecimal form
; Parameters:
; [DS:SI] - address in memory
; CX - memory size
;
; Return
; Nothing
;
; Clobbers:
; Nothing
;  
extern i16MemPrintHex

; 
; Prints number specified by ds:si  in hex format
; the length of number is passed in cx
; 
; at the end of operation si += cx
; clobbers 
; ax
;
extern i16NumberPrintHex

;
; prints NL (new line) character to screen
;
; Parameters:
; None
;
; Return:
; Nothing
;
; Clobbers
; Nothing
;
extern i16PrintNL
