;
; module to print string in protected mode
;

[bits 32]	; directive to tell assemble to encode in 32 bits

; constants
VIDEO_MEMORY equ 0xb83e8
WHITE_ON_BLACK equ 0x0f

; prints a null terminated string pointed to by EDX
print_string_pm:
 
  pusha
  mov edx, VIDEO_MEMORY		; set edx to the start of vid mem
 
print_string_pm_loop:
  mov al, [ebx]			; store the char at ebx in AL
  mov ah, WHITE_ON_BLACK	; store the attributes in AH

  cmp al, 0		; null reached or not
  je done
 
  mov [edx], ax		; store char and attributes at current character
			; cell
  add ebx, 1		; next character
  add edx, 2		; move to next character cell in vid mem
			; NOTE: each character cell is divided into 2 
			; parts 1>character 2>attributes. Both are 8 bits
			; long

  jmp print_string_pm_loop

done:
  popa
  ret 



