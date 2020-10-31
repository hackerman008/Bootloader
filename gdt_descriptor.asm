; GDT table defination 
;

gdt_start:

gdt_null:
	dd 0x0
	dd 0x0		;total 64 bits of 0's. because first entry in gdt
			; is always null

gdt_code:
	; base = 0x0, limit = 0xffff
	; 1st flags: (present)1 (privilage)00 (descriptor type)1 -> 1001b
	; type flags: (code)1 (conforming)0 (readable)1 (accessed)0 ->
	; 1010b
	; 2nd flags : (granularity)1 (32bit default)1 (64-bit seg)0 
	; (AVL)0 -> 1100b	

	dw 0xffff	; limit (bits 0-15)
	dw 0x0		; base (bits 0-15)
	db 0x0		; base (bits 16-32)
	db 10011010b	; 1st flags , type  flags
	db 11001111b	; 2nd flags, limit (bits 16-19)
	db 0x0		; base (bits 24-31)

gdt_data:
	; base = 0x0, limit = 0xffff
	; 1st flags: (present)1 (privilage)00 (descriptor type)1 -> 1001b
	; type flags: (code)0 (expand down)0 (writable)1 (accessed)0 ->
	; 0010
	; 2nd flags : (granularity)1 (32bit default)1 (64-bit seg)0 
	; (AVL)0 -> 1100b	

	dw 0xffff	; limit (bits 0-15)
	dw 0x0		; base (bits 0-15)
	db 0x0		; base (bits 16-32)
	db 10010010b	; 1st flags , type  flags
	db 11001111b	; 2nd flags, limit (bits 16-19)
	db 0x0		; base (bits 24-31)

gdt_end:		; will be used to calculte the size of gdt

;; GDT descriptor
gdt_descriptor:
	dw gdt_end - gdt_start -1	; gdt size always one less (first
					; entry is null thats why ?)
	dd gdt_start

; constants will be used later to set the segment registers appropriately
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start


















