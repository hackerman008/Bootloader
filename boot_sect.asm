; A boot sector that boots a C kernel in 32 bit protected mode
;

[org 0x7c00]
KERNEL_OFFSET equ 0x1000  ;memory offset to which we will load the kernel
[bits 16]
	mov [BOOT_DRIVE], dl  ; BIOS stores our boot drive in dl
	
	mov bp, 0x9000  ;stack setup
	mov sp, bp
	
	mov bx, MSG_REAL_MODE  ; print 16 bit real mode msg  
	call print_string

	call load_kernel  ; load our kernel
	
	mov bx, MSG_LOAD_KERNEL2
	call print_string

	; checking for low memory
	;---------------------------------------;
	; int 0x12				
	; return AX = total number of KB 
     	; AX value measures from 0 to bottom of extended BIOS data area
	;---------------------------------------;

	clc 
	int 0x12
	jc .Error

	call switch_to_pm  ; switch to protected mode

	jmp $

.Error:
	mov bx, ERROR_LOW_MEM
	call print_string
	

;include files
%include "print_string.asm"
%include "disk_load.asm"
%include "gdt_descriptor.asm"
%include "print_string_pm.asm"
%include "switch_to_pm.asm"

[bits 16]
; load kernel
load_kernel:
	mov bx, MSG_LOAD_KERNEL
	call print_string

	mov bx, KERNEL_OFFSET  ;es:bx pair stores points to the address
				;where the kernel will be loaded
	mov dh, 15 ;sectors will be loaded
	mov dl, [BOOT_DRIVE]
	call disk_load
	ret

[bits 32]
;code executed after the kernel switches to protected mode
BEGIN_PM:
	mov ebx, MSG_PROT_MODE
	call print_string_pm
	call KERNEL_OFFSET  ;call the kernel code ;es:bx(es:0x1000) 

	jmp $  ;hang

;global variables
BOOT_DRIVE	db 0
MSG_REAL_MODE	db "started in 16 bit real mode",0xd, 0xa,0
MSG_PROT_MODE	db "successfully landed in 32-bit protected mode",0xd,0xa,0
MSG_LOAD_KERNEL	db "loading kenel into memeory.",0xd, 0xa, 0
MSG_LOAD_KERNEL2	db "kernel load function done.",0xd, 0xa, 0
ERROR_LOW_MEM	db "failed to get low memory size",0xd, 0xa, 0

; bootsector padding
times 510 -($-$$) db 0
dw 0xaa55

