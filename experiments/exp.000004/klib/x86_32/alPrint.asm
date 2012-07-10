;
; prints character from AL register in protected mode
;
; function use VtyData structure
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
%include 'console.inc'

  segment .text
  [bits 32]
  global alPrint
  
  extern vtyData  ; console data structure
  extern writeVGAReg

alPrint:
;
; if (al  == LF) goto procLF
;
  cmp al, LF
  je procLF
  
;
; if (al == CR) goto procCR
;
  cmp al, CR
  je procCR
;
; else 
;

procOrdinary:

;
; process ordinary character
;
  push ax
  push edi
;
; di = vtyData.cursorOffset
; di += vtyData.windowOffset
; edi = di
; ah = vtyData.attrib
; *( VIDEO_BUFFER_ADDR + edi ) = ax
;
    mov di, [ vtyData + VtyData.cursorOffset ]
    add di, [ vtyData + VtyData.windowOffset ]
    movzx edi, di
    mov ah, [ vtyData + VtyData.attrib ]
    mov [ VIDEO_BUFFER_ADDR + edi ], ax
	
incrementCursorPosition:	
;
; al = col
; al++
; if (al >= CONSOLE_COLUMNS) goto .rowChanged
;
    mov al, [ vtyData + VtyData.col ]
    inc al
    cmp al, CONSOLE_COLUMNS
    jge .rowChanged
;	
; else {
;   col = col + 1; 
;   cursorOffset +=2
; }
    mov [ vtyData + VtyData.col ], al
    add word [ vtyData + VtyData.cursorOffset ], 2

  pop edi
  pop ax
  ret

;
; al > CONSOLE_COLUMNS
;
.rowChanged:
    call procCR
    call procLF
	
  pop edi
  pop ax
  ret
;
; process Line Feed
;
; Clobbers:
; ax
;
procLF:

  push ax
  
;
; al = VtyData.row
; al++
; if (al >= CONSOLE_ROWS) goto scrollDown
;
    mov al, [ vtyData + VtyData.row ]
    inc al
    cmp al, CONSOLE_ROWS
    jge scrollDown
	
;
; VtyData.row = al
;  
    mov [ vtyData + VtyData.row ], al
;
; VtyData.cursorOffset += CONSOLE_COLUMNS * 2
;  
    add word [ vtyData + VtyData.cursorOffset ], CONSOLE_COLUMNS * 2
	
  pop ax
  ret

scrollDown:

    push edx
;
; dx = VtyData.windowOffset
; ax = dx
; ax + = CONSOLE_COLUMNS * 2
; if ( ax >= CONSOLE_WINDOW_MAX_OFFSET) goto scrollHead
;
      mov dx, [ vtyData + VtyData.windowOffset ] 
      mov ax, dx
      add ax, CONSOLE_COLUMNS * 2
      cmp ax, CONSOLE_WINDOW_MAX_OFFSET
      jge scrollHead

;
; VtyData.windowOffset = ax
;	  
	  mov [ vtyData + VtyData.windowOffset ], ax
;
; cursorOffset -= 2
;	  
;	  sub word [ vtyData + VtyData.cursorOffset ], CONSOLE_COLUMNS * 2
;
; memset last string
;	  
	  push ecx
	  push edi	  
;
; fill last line with space characters
;	  
	  movzx edi, dx
     add edi, VIDEO_BUFFER_ADDR + CONSOLE_COLUMNS * (CONSOLE_ROWS) * 2	  
	  mov ecx, CONSOLE_COLUMNS
	  mov ah, [ vtyData +  VtyData.attrib ]
	  mov al, ' '
	  rep stosw
;
; update VGA controller window Offset register
;	  
    call setVGAOffset	

	  pop edi
	  pop ecx
  
    pop edx
	
  pop ax
  ret

;
; scroll the display window to 0 offset
; Parameters:
; dx - current window offset
;
;
;
scrollHead:  

    push edi
    push esi
    push ecx

;	  
; memcpy ( VIDEO_BUFFER_ADDR, VIDEO_BUFFER_ADDR + windowOffset, CONSOLE_WINDOW_SIZE / 2 )
;
      mov edi , VIDEO_BUFFER_ADDR 
      movzx esi, dx
	    add esi, edi ; VIDEO_BUFFER_ADDR + windowOffset
		 add esi, CONSOLE_COLUMNS * 2
	    mov ecx, CONSOLE_COLUMNS * (CONSOLE_ROWS - 1)
	    rep movsw
;
; VtyData.windowOffset = 0
;
		mov word [ vtyData + VtyData.windowOffset ], 0
	  
     mov edi, VIDEO_BUFFER_ADDR + CONSOLE_COLUMNS * (CONSOLE_ROWS - 1 ) * 2	  
	  mov ecx, CONSOLE_COLUMNS
	  mov ah, [ vtyData +  VtyData.attrib ]
	  mov al, ' '
	  rep stosw
		
;
; update VGA controller window Offset register
;	  
		
		call setVGAOffset
	
	  pop ecx
	  pop esi
	  pop edi
	  
    pop edx
	
  pop ax
  ret

;
; process Carrige Return
;
procCR:

  push ax
  
;
; ax = VtyData.col
; ax *= 2
;
  movzx ax, byte [ vtyData + VtyData.col ]
  shl ax, 1		
;  
; VtyData.cursorOffset -= ax
;
  sub [ vtyData + VtyData.cursorOffset ], ax
;
; VtyData.col = 0
;
  mov byte [ vtyData + VtyData.col ], 0

  pop ax
  ret

;
; Parameters 
; vtyData + VtyData.windowOffset
; clobbers
; ax, dx, cx
;
setVGAOffset:
  mov cx, [ vtyData + VtyData.windowOffset ]
  shr cx,1
  mov ax, cx
  mov ah, 0xd
  call writeVGAReg
  mov ah, 0xc
  mov al, ch
  call writeVGAReg
  ret  