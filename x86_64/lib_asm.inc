%ifndef LIB_ASM_INC
%define LIB_ASM_INC

%macro memcpyd 3
	cld
	mov		edi, %1
	; print_register edi
	; print	space_str
	mov		esi, %2
	; push	esi
	; print_register esi
	; print	space_str
	mov		ecx, %3
	; print_register ecx
	; print	space_str
	shr		ecx, 2
	; print_register ecx
	; print	endl
	; pop		esi
	rep		movsd
%endmacro

%endif ; LIB_ASM_INC
