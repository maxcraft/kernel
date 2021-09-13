%ifndef STRING_INC
%define STRING_INC

extern byte2str, word2str, dword2str
extern byte2hstr, word2hstr, dword2hstr

%macro mk_dd_hstr 0
	mov		edi, reg_val_32_str
	call	dword2hstr
%endmacro

%macro mk_dd_hstr 1-2 reg_val_32_str
	mov		eax, %1
	mov		edi, %2
	call	dword2hstr
%endmacro

%macro mk_dd_str 1-2 reg_val_32_str
	mov		eax, %1
	mov		edi, %2
	call	dword2str
	xor		al, al
	stosb
%endmacro

%macro mk_dw_hstr 0
	mov		edi, reg_val_32_str
	call	word2hstr
%endmacro

%macro mk_dw_hstr 1-2 reg_val_32_str
	mov		ax, %1
	mov		edi, %2
	call	word2hstr
%endmacro

%macro mk_dw_str 1-2 reg_val_32_str
	mov		ax, %1
	mov		edi, %2
	call	word2str
	xor		al, al
	stosb
%endmacro

%macro mk_db_hstr 0
	mov		edi, reg_val_32_str
	call	byte2hstr
%endmacro

%macro mk_db_hstr 1-2 reg_val_32_str
	mov		al, %1
	mov		edi, %2
	call	byte2hstr
%endmacro

%macro mk_db_str 0
	mov		edi, reg_val_32_str
	call	byte2str
	xor		al, al
	stosb
%endmacro

%macro mk_db_str 1-2 reg_val_32_str
	mov		al, %1
	mov		edi, %2
	call	byte2str
	xor		al, al
	stosb
%endmacro

%macro cmpstr 3
	cld
	push	ecx
	push	edi
	push	esi
	mov		edi, %1
	mov		esi, %2
	mov		ecx, %3
	repe	cmpsb
	pop		esi
	pop		edi
	pop		ecx
%endmacro

%ifdef VGA_TEXT_32_INC
%macro print_dword 1-2	reg_val_32_str
	mk_dd_hstr	%1, %2
	print	%2
%endmacro

%macro print_dword 0
	mk_dd_hstr
	print	reg_val_32_str
%endmacro

%macro print_dword_dec 1-2	reg_val_32_str
	mk_dd_str	%1, %2
	print	%2
%endmacro


%macro print_word 1-2	reg_val_32_str
	mk_dw_hstr	%1, %2
	print	%2
%endmacro

%macro print_word 0
	mk_dw_hstr
	print	reg_val_32_str
%endmacro

%macro print_word_dec 1-2	reg_val_32_str
	mk_dw_str	%1, %2
	print	%2
%endmacro

%macro print_byte 1-2	reg_val_32_str
	mk_db_hstr	%1, %2
	print	%2
%endmacro

%macro print_byte 0
	mk_db_hstr
	print	reg_val_32_str
%endmacro

%macro print_byte_dec 1-2	reg_val_32_str
	mk_db_str	%1, %2
	print	%2
%endmacro

%macro print_byte_dec 0
	mk_db_str
	print	reg_val_32_str
%endmacro

%macro print_register 1
	mov		eax, %1
	mov		esi, reg_%1_name
	call	print_reg
%endmacro

%endif ; VGA_TEXT_32_INC

%macro asciiz 1+
db %1, 0
%endmacro

section .data
reg_eax_name		asciiz "EAX: "
reg_ebx_name		asciiz "EBX: "
reg_ecx_name		asciiz "ECX: "
reg_edx_name		asciiz "EDX: "
reg_edi_name		asciiz "EDI: "
reg_esi_name		asciiz "ESI: "
reg_esp_name		asciiz "ESP: "
reg_ebp_name		asciiz "EBP: "
reg_val_32_str	times (10) db 0
				db 0
endl			db	0ah, 0
space_str		asciiz " "


%endif ; STRING_INC
