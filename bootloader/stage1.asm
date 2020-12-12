;**********************************************************************
; Stage1 bootsector to load stage 2
;
;
;***********************************************************************

[BITS 16]
[ORG 0x7C00]

jmp bootloader_stage1

;include files
%include "bootloader/print_string.asm"

bootloader_stage1:
	mov [BOOT_DRIVE], dl
	; setting stac space and stack segment
	xor ax, ax
	mov ss, ax
	mov sp, 0x9000

	; clear screen
	mov ah, 0x6			; function number 
	xor al, al			; lines to scroll 0 = clear
	xor bx, bx			
	mov bh, 0x7			; background color and foreground color
	xor cx, cx			; ch = upper row , cl = left col
	mov dh, 24			; dh = lower row, dl = right col
	mov dl, 79
	int 0x10

	; Enable A20 gate
	;in al, 0x92
	;or al,2
	;out 0x92, al																					
	mov bx, WELCOME_MSG
	call print_string

	; checking for extended read functionality
	mov ah,0x41			; function number for extended read extension
	mov bx, 0x55AA			; fixed val
	mov dl, 0x80			; drive index (80h = HDD). Our image file will be treated as a harddrive image with a FAT32 file system
	int 0x13

	jc extension_not_supported

	; load the second stage bootloader from disk
	mov ah, 0x42			; function for reading extended sector functionality
	mov si, DAPACK			; disk address packet struct
	mov dl, 0x80			; drive index (0x08 = HDD)
	int 0x13
	
	jc read_failed

	; jmp to stage2 loader and execute
	jmp dword 0x0000:0x4000 
	

DAPACK:
	db	0x10
	db	0
blkcnt:	dw	3		; int 13 resets this to # of blocks actually read/written
db_add:	dw	0x4000		; memory buffer destination address
	dw	0		; in memory page zero
d_lba:	dd	1		; put the lba to read in this spot
	dd	0		; more storage bytes only for big lba's ( > 4 bytes )
 

;DAP:
;.size		db 0x10		; structure size
;.null		db 0x0		; reserved
;.count		dw 0x6		; num.of sectors to read
;.offset	dw 0x0		; offset where the stage2 bootloader will be loaded
;.segment	dw 0x8c0	; segment where the stage 2 bootloader will be loaded
;.lba		dd 0x1		; absolute sector number from where to start reading sectors
;.lba48		dd 0	

extension_not_supported:
	mov bx, EXTENDED_READ_NOT_SUPPORTED
	call print_string
	jmp $

read_failed:
	mov bx, STAGE2_READ_FAILED
	call print_string
	jmp $

	

;global_variables
BOOT_DRIVE	db 0
WELCOME_MSG	db "Welcome.. the bootloader is loading the necessary files", 0xd, 0xa, 0
EXTENDED_READ_NOT_SUPPORTED	db "Extended read functionality is not supported in this system.", 0xd, 0xa, 0
STAGE2_READ_FAILED	db "Could not load stage."


times 446-($-$$) db 0		; after 446 will be values put there at the time of creating the disk so we are using 446 instead of 512. the formatting software will make the bootsector bootable.
