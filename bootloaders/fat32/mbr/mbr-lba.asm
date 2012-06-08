  section .text
  use16
  org  0x7c00 ; MBR starts at 0:0x7c00
start:
  cli 
  xor ax,ax
  mov ss,ax ; ss=0
  mov sp,0x7c00                 
  mov si,sp ; sp=si=0x7c00
  push ax                     
  pop es  ; es=0
  push ax   
  pop ds  ; ds=0
  sti
  
  ; make copy of MBR to 0:0x600
  cld               
  mov di,0x600  ; where copy
  mov cx,0x100  ; how much copy
  repne movsw   ; copy 256 words
   
  ; jump to instruction in code copy
  jmp word 0x0:code_start-0x7600
code_start:
  mov byte [0x7dfe],00 ; remove signature
  mov si,0x7be ; address of partition table
  
  ; build LBA address in stack
  push cs  ; 00 00
  push cs  ; 00 00
  push dword [si+8] ; partition LBA address
  push cs
  push word 0x7c00 ; destination address
	
  push byte 1  ; 0x1, 00
  push byte 0x10  ; 0x10, 00
	mov si, sp
	
	mov ah, 0x42  ; function
	mov dl, 0x80 ; drive id
	int 0x13
	
	jnc read_ok
	
	mov si, err_reading-0x7600 ; error message 
	
show_message:	
	lodsb              	
	cmp al,0x0
	jz infinite_loop

	push si                       
	mov bx,0x7  
	mov ah,0xe  
	int 0x10
	pop si 
	jmp show_message 
infinite_loop:
	jmp short $  ; infinite loop
	
read_ok:
  cmp word [0x7dfe], 0xaa55 
  jz start_os

	mov si, err_signature-0x7600
	jmp show_message
	
start_os:
  jmp word 0x0:0x7c00 ; pass control to boot loader
	
err_reading:
	db 'Error Reading Boot Sector',0
err_signature:
	db 'Incorrect signature',0	
	
	finish:
  times 0x1FE-finish+start db 0
  db   0x55, 0xaa   ; signature