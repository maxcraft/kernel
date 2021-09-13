; default text display routines for early 32-bit mode
section .text
bits 32

global vga_text_clear, vga_text_scroll_up, vga_text_scroll_down, vga_text_puts, vga_text_init
global vga_text_set_color, vga_text_get_color


DISPLAY_MEM equ 0xb8000
DISPLAY_WIDTH equ 80
DISPLAY_HEIGHT equ 25
text_color	db	0x0f
text_cursor_x	db	0x00
text_cursor_y	db	0x00
cursor_start	equ 14
cursor_end		equ 15
VGA_CMD_PORT	equ 0x03D4
VGA_DATA_PORT	equ 0x03D5


vga_text_clear:
	pushfd
	push	eax
	push	edi
	push	ecx
	cld
	mov		ecx, DISPLAY_HEIGHT * DISPLAY_WIDTH
	xor		eax, eax
	mov		word [ text_cursor_x ], ax
	mov		ah, [ text_color ]
	mov		edi, DISPLAY_MEM
	rep		stosw

	pop		ecx
	pop		edi
	pop		eax
	popfd
	ret

vga_text_scroll_up:
	pushfd
	push	eax
	push	ecx
	push	edi
	push	esi

	cld
	mov		ecx, DISPLAY_WIDTH * ( DISPLAY_HEIGHT - 1 )
	mov		edi, DISPLAY_MEM
	mov		esi, DISPLAY_MEM + DISPLAY_WIDTH * 2
	rep	movsd
	xor		eax, eax
	mov		ecx, DISPLAY_WIDTH / 2
	rep stosd

	pop		esi
	pop		edi
	pop		ecx
	pop		eax
	popfd
	ret

vga_text_scroll_down:
	pushfd
	push	eax
	push	ecx
	push	edi
	push	esi
	std
	mov		ecx, DISPLAY_WIDTH * ( DISPLAY_HEIGHT - 1 )
	mov		edi, DISPLAY_MEM + DISPLAY_WIDTH * ( DISPLAY_HEIGHT ) - 4
	mov		esi, DISPLAY_MEM + DISPLAY_WIDTH * ( DISPLAY_HEIGHT - 1 ) - 4
	rep	movsd
	xor		eax, eax
	mov		ecx, DISPLAY_WIDTH / 2
	rep stosd
	pop		esi
	pop		edi
	pop		ecx
	pop		eax
	popfd
	ret

; bh = y, bl = x
puts_adjust_cursor:
	xor 	bl, bl
	inc		bh
	cmp		bh, DISPLAY_HEIGHT
	jge		.scroll_line
	ret
.scroll_line:
	call	vga_text_scroll_up
	dec		bh
	ret

vga_text_puts:
	pushfd
	push	eax
	push	ebx
	push	edi
	push	edx

	mov		edi, DISPLAY_MEM
	xor		eax, eax
	mov		al, [ text_cursor_y ]
	mov		ebx, DISPLAY_WIDTH * 2
	mul		ebx
	xor		ebx, ebx
	mov		bl, [ text_cursor_x ]
	shl		ebx, 1
	add		eax, ebx
	add		edi, eax

	xor		eax, eax
	mov		ah, [ text_color ]
	mov		bx, [ text_cursor_x ]
.print_loop:
	lodsb
	cmp		al, 0
	jz		.print_end
	cmp		al, 0x0a
	jz		.new_line
	stosw
	inc		bl
	cmp		bl, DISPLAY_WIDTH
	jl		.print_loop
.new_line:
	call	puts_adjust_cursor
	jmp		.print_loop

.print_end:
	mov		word [ text_cursor_x ], bx
	mov		ax, bx
	call	vga_text_move_cursor

	pop		edx
	pop		edi
	pop		ebx
	pop		eax
	popfd
	ret

vga_text_get_color:
	mov		al, [ text_color ]
	ret

vga_text_set_color:
	mov		[ text_color ], al
	ret

; al - x
; ah - y
vga_text_move_cursor:
	pushfd
	push	ebx
	push	edx

	xor		ebx, ebx
	mov 	bl, al
	shr		ax, 8
	mov		dl, DISPLAY_WIDTH
	mul		dl
	add		bx, ax

.set_offset:
	mov		dx, VGA_CMD_PORT
	mov		al, 0x0f
	out		dx, al

	inc		dl
	mov		al, bl
	out		dx, al

	dec		dl
	mov		dx, VGA_CMD_PORT
	mov		al, 0x0e
	out		dx, al

	inc		dl
	mov		al, bh
	out		dx, al

	pop		edx
	pop		ebx
	popfd
	ret

vga_text_init:
	pushfd
	push	eax
	push	ebx
	push	edx

	mov		byte [ text_color ], 0x0f
	mov		word [ text_cursor_x ], 0

	; set cursor scanning lines
	mov		dx, VGA_CMD_PORT
	mov		al, 0x0a
	out		dx, al
	inc		dx
	in		al, dx
	and		al,0xc0
	or		al, cursor_start
	out		dx, al

	dec		dx
	mov		al, 0x0b
	out		dx, al
	inc		dx
	in 		al, dx
	and		al, 0xe0
	or		al, cursor_end
	out		dx, al

	xor		eax, eax
	call	vga_text_move_cursor

	pop		edx
	pop		ebx
	pop		eax
	popfd
	ret
