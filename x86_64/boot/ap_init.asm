section .text16
bits 16
%define AP_INIT_
;org	0 ; start from 0
%include "boot/ap_init.inc"


ap_init:
	jmp		REAL_BASE >> 4:.ap_code - ap_init
.ap_code:
	mfence
	invd
	mov		ds, cx
	mov		si, ap_hello_str - ap_init
	mov		ax, 0b800h
	mov		es, ax
	; xor		di, di
	mov		di, 2 * 80 * 10

	mov		ah, 0f0h

	cld
; .print_loop:
; 	lodsb
; 	cmp		al, 0
; 	jz		.end_print
; 	stosw
; 	sfence
; 	wbinvd
; 	jmp		.print_loop
; .end_print:
	mov		al, 'H'
	stosw
	mov		al, 'i'
	stosw
	mov		al, 'H'
	stosw
	mov		al, 'i'
	stosw
	mov		al, 'H'
	stosw
	mov		al, 'i'
	stosw
	mov		al, 'H'
	stosw
	mov		al, 'i'
	stosw
	mov		al, 'H'
	stosw
	mov		al, 'i'
	stosw
	mov		al, 'H'
	stosw
	mov		al, 'i'
	stosw
	sfence
	wbinvd
	hlt

; ap_init_print_hello:

ap_hello_str	db "Hello from another CPU. ", 0

ap_init_end:
