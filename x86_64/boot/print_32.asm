%include "boot/vga_text_32.inc"
%include "boot/string.inc"
section .text
bits 32
global print_reg

; eax - value
; esi - pointer to the name string
print_reg:
	pushfd
	pushad
	push	eax
	print
	pop		eax

	print_dword
	; print	endl
	popad
	popfd
	ret
