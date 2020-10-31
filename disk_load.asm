
; routine to load the kernel from the disk to address specified by es:bx
; es = 0x0000
; bx = 0x1000
; final address = 0x1000
disk_load:
	push dx  ; after reading the disk the bios will change the dx 
		;value to the amount of sectors read
	mov ah, 0x02	;BIOS read sector function
	mov al, dh	;read dh=15 sectors
	mov ch, 0x00	;cylinder=0
	mov dh, 0x00	;head=0
	mov cl, 0x02	;start reading from sector=2 (exclude boot sector)
	
	int 0x13	;BIOS interrupt (wont be available when we enter
			;protected mode)
	jc disk_error_bios	;jump if error 
				;(bIOS sets the carry flag in case
			;of error reading from disk )
	pop dx
	cmp dh, al	;if AL(sectors read)!= DH(sectors expected)
			;print error
	jne disk_error_2
	ret

		

disk_error_bios:
	mov bx, DISK_ERROR_MSG_BIOS
	call print_string
	jmp $		;print error and hang
disk_error_2:
	mov bx, DISK_ERROR_MSG_2
	call print_string
	jmp $		;print error and hang
	


	

DISK_ERROR_MSG_BIOS	db "disk read error. carry flag set", 0, 10
DISK_ERROR_MSG_2	db "read sectors not equal to total sectors",10,0																				
