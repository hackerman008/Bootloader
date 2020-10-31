;
;	A simple function that prints a null terminated string 
;

print_string:
	; bx = string address
	pusha			; save all the caller registers
	mov ah, 0x0e		; tty interrupt handler
.loop:
	mov al, [bx] 	; store the character in al
	test al, al
	cmp al, 0		; test if end of string is reached
	jz .end
	int 0x10
	inc bx
	jmp .loop

.end:	
	popa
	ret
	
		

