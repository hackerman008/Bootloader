;
; module to load the gdtr register with the gdt_descriptor and 
; set the segment registers with appropriate values
;

[bits 16]
switch_to_pm:
	cli		; stops interrupts. since we are switching to
			; protected mode. real mode interrupts wont work
			; until we set up interrupt vector for protected
			; mode 
	lgdt [gdt_descriptor]
	
	mov eax, cr0	; we cannot directly set cr0
	or eax, 0x1
	mov cr0, eax

	jmp CODE_SEG:init_pm	; make a far jmp (i.e to a new segment) to				  ; our 32 bit code. this also forces the 
				; CPU to flush its cache of pre-fetched 
				; and real-mode decoded instructions which				  ; can cause problems

[bits 32]
; initialize registers and the stack once in PM
init_pm:
	mov ax, DATA_SEG 
	mov ds, ax
	mov ss, ax
	mov gs, ax
	mov fs, ax
	mov es, ax
	
	mov ebp, 0x90000	;set stack safely at the top of freespace
	mov esp, ebp
	
	call BEGIN_PM		; finally call some know label

