section .text
bits 32

global byte2str, word2str, dword2str
global byte2hstr, word2hstr, dword2hstr

; stack - characters
; ecx - number of characters
; modifies: eax, ebx
put_char:
	pop		ebx		; return address
	cmp		ecx, 0
	jz		.exit
	cld

.next_char:
	pop		ax
	stosb
	loop	.next_char
.exit:
	jmp		ebx

; al - byte
; edi - string pointer
byte2str:
	pushfd
	push	ebx
	push	ecx

	xor		ecx, ecx
	mov		bh, 10
.loop:
	xor		ah, ah
	div		bh
	add		ah, '0'
	mov		bl, ah
	push	bx
	inc		ecx
	cmp		al, 0
	jne		.loop

	call put_char

	pop		ecx
	pop		ebx
	popfd
	ret

; ax - word
; edi - string pointer
word2str:
	pushfd
	push	ebx
	push	ecx
	push	edx

	xor		ecx, ecx
	mov		bx, 10
.loop:
	xor		edx, edx
	div		bx
	add		dx, '0'
	push	dx
	inc		ecx
	cmp		ax, 0
	jne		.loop

	call put_char

	pop		edx
	pop		ecx
	pop		ebx
	popfd
	ret

; eax - dword
; edi - string pointer
dword2str:
	pushfd
	push	ebx
	push	ecx
	push	edx

	xor		ecx, ecx
	mov		ebx, 10
.loop:
	xor		edx, edx
	div		ebx
	add		dx, '0'
	push	dx
	inc		ecx
	cmp		eax, 0
	jne		.loop

	call put_char

	pop		edx
	pop		ecx
	pop		ebx
	popfd
	ret

; eax - the number to convert
; ecx - number of 4-bit sections
do_2hstr:
	pushfd
	push	ebx
	push	ecx
	push	edx
	push	ebp
	mov		ebp, esp

	mov		edx, eax
.loop:
	mov		ebx, edx
	and		ebx, 0Fh
	mov		al, byte [ ebx + hex_table ]
	push	ax
	shr		edx, 4
	loop	.loop

	mov		ecx, [ ebp + 8 ]
	call	put_char

	mov		esp, ebp
	pop		ebp
	pop		edx
	pop		ecx
	pop		ebx
	popfd
	ret

; al - byte
; edi - string pointer
byte2hstr:
	push	ecx

	mov		ecx, 2
	call	do_2hstr
	pop		ecx
	ret

; ax - word
; edi - string pointer
word2hstr:
	push	ecx

	mov		ecx, 4
	call	do_2hstr
	pop		ecx
	ret

; eax - dword
; edi - string pointer
dword2hstr:
	push	ecx

	mov		ecx, 8
	call	do_2hstr
	pop		ecx
	ret

section .data
hex_table	db	"0123456789ABCDEF"

section	.bss
char_stack	resd 100
char_stack_end:
