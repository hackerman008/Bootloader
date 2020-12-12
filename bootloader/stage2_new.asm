;********************************************************************
; 1. loads sector 0  at segment:offset & jumps to it
; 2. go to offset 446+8 from segment:offset & read the 2 byte value (i.e
;	the root directory entry cluster number)
; 3. goes to the root directory entry and reads the entry & increment by
;	32 bytes if not match for the next entry
; 4. reads the filename and cluster number where the kernel begins.
; 5. converts cluster number to LBA.
; 6. loads the file at the specified LBA at a segment:offset & jumps to 
;	the specified offset.
; 7.Keep loading contents of file using FAT entries & then jump to the 
;	execution.
;********************************************************************

[ORG 0x4000]
[BITS 16]

jmp stage2_new

;; includes
%include "bootloader/print_string.asm"
%include "bootloader/print_string_pm.asm"
%include "bootloader/switch_to_pm.asm"
%include "bootloader/gdt_descriptor.asm"


;; Constants
;; temporary storage address for files
SEGMENT_ADDRESS		equ 0x4F00
OFFSET_ADDRESS		equ 0x0F00

SEGMENT_ADDRESS2	equ 0x3F00
OFFSET_ADDRESS2		equ 0x0F00
CLUSTER_SIZE		equ 0x1000

KERNEL_SEGMENT_ADDRESS	equ 0x0000
KERNEL_OFFSET_ADDRESS	equ 0x1000	

;; variables
PARTITION_START		dw 0
CLUSTER_HIGH		dw 0
CLUSTER_LOW		dw 0
ROOT_DIRECTORY_ADD	equ 2072576
TEMP_A			dd 0
CURRENT_CLUSTER		dd 0
SECTORS_PER_CLUSTER	dd 0
CLUSTER_BEGIN		dd 0
COUNTER			dd 0 		
FILE_END		db 0

[bits 16]
;; stage2_new start ---------------------------------------------------
stage2_new:
	mov ax, SEGMENT_ADDRESS
	mov gs, ax

	; read the sector 0 to get the root directory value
	mov word [DAP.offset], OFFSET_ADDRESS
	mov word [DAP.segment], SEGMENT_ADDRESS
	mov ah, 0x42
	mov si, DAP
	mov dl, 0x80		; drive index (0x80 = HDD)
	int 0x13		; bios diskett interrupt

	mov ax, [gs:(OFFSET_ADDRESS + 446 + 8)]
	mov word [PARTITION_START], ax
	
	;; load the dirctory entry table
	mov word [DAP.offset], OFFSET_ADDRESS
	mov word [DAP.segment], SEGMENT_ADDRESS
	mov ax, 4048						; this is where the root directory address is in a 491 MB disk
	mov word [DAP.lba], ax
	mov si, DAP
	call load_sectors_from_disk


	mov si, OFFSET_ADDRESS
	xor cx, cx
.next:
	;; check for string KERNEL.BIN
	xor ax,ax
	mov al, byte [gs:si]		
	cmp al, 0x4B		;K
	jne .somewhere

	mov al, byte [gs:(si+1)]		
	cmp al, 0x45		;E
	jne .somewhere

	mov al, byte [gs:(si+2)]		
	cmp al, 0x52		;R
	jne .somewhere

	mov al, byte [gs:(si+3)]		
	cmp al, 0x4E		;N
	jne .somewhere
	mov al, byte [gs:(si+4)]		
	cmp al, 0x45		;E
	jne .somewhere
	mov al, byte [gs:(si+5)]		
	cmp al, 0x4C		;L
	jne .somewhere

	mov al, byte [gs:(si+6)]		
	cmp al, 0x20		;space 
	jne .somewhere
	mov al, byte [gs:(si+7)]		
	cmp al, 0x20		;space
	jne .somewhere

	mov al, byte [gs:(si+8)]		
	cmp al, 0x42		;B
	jne .somewhere

	mov al, byte [gs:(si+9)]		
	cmp al, 0x49		;I
	jne .somewhere

	mov al, byte [gs:(si+10)]		
	cmp al, 0x4E		;N
	jne .somewhere

	mov ax, [gs:(si+20)]
	mov [CLUSTER_HIGH], ax		; get the cluster number for the file

	mov ax,[gs:(si+26)]
	mov [CLUSTER_LOW], ax
	
	mov bx, FILE_FOUND		
	call print_string
	jmp .next_stage

.somewhere:
	add si, 32			;; increment with offset 32 to check for next file entry 
	inc cx
	cmp cx, 4
	je root_descriptor_entry_not_found
	jmp .next


.next_stage:
	mov bx, word [CLUSTER_HIGH]
	shr ebx, 4			; move by 4  to accomodate the low bits
	movzx eax, word [CLUSTER_LOW]
	or eax, ebx			; ebx stores the CURRENT_CLUSTER 
	mov dword [CURRENT_CLUSTER], eax
	

	call .load_fat	
	
	mov word [DAP.offset], KERNEL_OFFSET_ADDRESS		; kernel will be loaded at this address
	mov word [DAP.segment], KERNEL_SEGMENT_ADDRESS

.load_kernel:	
	call .convert_CLUSTER_NUM_TO_LBA
	
	call .load_file
	call .find_next_cluster_inside_fat		; finds next cluster or ends if no more clusters to load
	inc dword [COUNTER]
	jmp .load_kernel
	
.convert_CLUSTER_NUM_TO_LBA:
	mov eax, dword [CURRENT_CLUSTER]
	sub eax, 2
	mov dword [SECTORS_PER_CLUSTER], 8
	mov ebx, dword [SECTORS_PER_CLUSTER]
	mul ebx
	add eax, 4048			; 4048 is the cluster begin.(i.e root directory start)
					; (4048+8) sector = file start. 
	mov dword [TEMP_A], eax
	ret

.load_file:
	mov eax, [TEMP_A] 				
	mov dword [DAP.lba], eax			; absolute sector number where the file starts
	mov si, DAP
	mov word [DAP.count], 8				; load a full cluster (i.e 8 sectors)
	call load_sectors_from_disk
	; do test and load next sector if there or end
	ret	

;; get the next cluster number for the file from the FAT entry in the FAT table
.load_fat:
	mov word [DAP.offset], OFFSET_ADDRESS2
	mov word [DAP.segment], SEGMENT_ADDRESS2	
	mov eax, 2080					; ----------"----------
	mov dword [DAP.lba], eax			; FAT table sector start
	mov si, DAP	
	mov word [DAP.count], 3				; total FAT size = 984 sectors (& 2 FAT tables).
	call load_sectors_from_disk
	ret	

.find_next_cluster_inside_fat:
	cmp byte [FILE_END], 1
	je .no_more_cluster_jmp_end
	mov ax, SEGMENT_ADDRESS2
	mov gs, ax
	mov si, OFFSET_ADDRESS

	;; traverse FAT entry to get next cluster number
	mov eax, dword [CURRENT_CLUSTER]
	mov dword [TEMP_A], eax
	shl eax, 2					; fat_offset = current_cluster * 4
	shr eax, 9					; temp = fat_offset / sector_size(512)
	add eax, 2080					; fat_sector = fat_begin + temp  . declare variable ? no use at the moment. 
	mov ebx, dword [CURRENT_CLUSTER]
	shl ebx, 2					; ebx *2
	and ebx, 512 -1					; entry_offset_inside_FAT = fat_offset % sector_size
	mov cx, word [gs:(si+bx)]
	mov word [CURRENT_CLUSTER], cx 
	;check if file end or not
	mov edx, dword [gs:(si+bx+4)]
	cmp edx, 0xFFFFFFF8
	jge .set_file_end
	jmp .do_not_set_file_end

.set_file_end:
	mov byte [FILE_END], 1
.do_not_set_file_end:
	add word [DAP.offset], 0x1000 
	mov ecx, dword [gs:(si+bx)]
	mov eax, ecx
	ret

 
;; switch to protected mode and jmp to kernel 	
.no_more_cluster_jmp_end:
	call switch_to_pm
	jmp begin_pm																													 
[bits 32]
begin_pm:
	jmp KERNEL_OFFSET_ADDRESS			; kernel offset
	
	
;; repeatedly called functions
;; load a sector from disk
load_sectors_from_disk:
	mov ah, 0x42
	mov dl, 0x80
	int 0x13
	ret

root_descriptor_entry_not_found:
	mov bx, ER_ROOT_DESCRIPTOR_ENTRY_NOT_FOUND
	call print_string 	

;stage2_new end ----------------------------------------------------

DAP:
.size		db 0x10
.reserved	db 0
.count	 	dw 3
.offset		dw 0		; offset
.segment	dw 0		; segment
.lba		dd 0		; absolute sector value lower bits
.lbahigh	dd 0 		; --------''----------- higher bits


;strings
FILE_FOUND	db "Found the file entry in the root directory", 0xd, 0xa, 0
FILE_NOT_FOUND	db "no entry matching kernel.bin found in root directory", 0xd, 0xa, 0

ER_ROOT_DESCRIPTOR_ENTRY_NOT_FOUND db "root descriptor entry not found", 0xd, 0xa, 0
