; This piece of code ensures that we execute the entry of the kernel 
;
[bits 32]
[extern main]

	call main	;invoke main from kernel.bin
	jmp $

