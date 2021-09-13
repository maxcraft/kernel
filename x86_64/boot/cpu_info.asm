%include "boot/vga_text_32.inc"
%include "boot/string.inc"
section .text
bits 32

global check_cpu
extern print_reg

%macro serialize_cpu_brand 0
	stosd
	mov		eax, ebx
	stosd
	mov		eax, ecx
	stosd
	mov		eax, edx
	stosd
%endmacro

check_cpu:
	call	check_cpuid
	xor		eax, eax
	cpuid

	; print_dword
	; print	space_str

	mov		[ cpu_name_str ], ebx
	mov		[ cpu_name_str + 4 ], edx
	mov		[ cpu_name_str + 8 ], ecx
	print	cpu_name_str
	print	endl

	mov		eax, 80000000h
	cpuid
	cmp		eax, 80000000h
	jb		.no_cpuid_ext
	; print_dword
	; print	space_str
	; mov		eax, 80000000h
	; cpuid
	cmp		eax, 80000008h
	jb		.no_addr_size
	push	eax
	mov		eax, 80000008h
	cpuid
	mov		edx, eax
	print	phys_addr_len_str
	mov		eax, edx
	print_byte_dec
	print	space_str
	print	linear_add_len_str
	mov		eax, edx
	shr		eax, 8
	print_byte_dec
	; print_dword
	print	endl
	pop		eax
.no_addr_size:
	cmp		eax, 80000004h
	jb		.no_brand_string

	push	eax
	cld
	mov		edi, proc_brand_str
	mov		eax, 80000002h
	cpuid
	serialize_cpu_brand
	mov		eax, 80000003h
	cpuid
	serialize_cpu_brand
	mov		eax, 80000004h
	cpuid
	serialize_cpu_brand
	print	proc_brand_str
	print	endl
	pop		eax
.no_brand_string:
	; check long mode
	cmp		eax, 80000001h
	jb		.no_long_mode
	mov		eax, 80000001h
	cpuid
	test	edx, 1 << 29
	jz		.no_long_mode

	xor		eax, eax
	inc		eax
	cpuid
	test	edx, 1 << 9
	jz		.no_apic
	; hlt
	ret
.no_long_mode:
	print	no_long_mode_str
	hlt
.no_apic:
	print	no_apic_str
	hlt
.no_cpuid_ext:
	print	no_ext_cpuid_str
	hlt

check_cpuid:
	pushfd
	pop		eax
	mov		ebx, eax
	xor		eax, 00200000h
	push	eax
	popfd
	pushfd
	pop		eax
	cmp		eax, ebx
	jz		.nocpuid
	ret
.nocpuid:
	print	no_cpuid_str
	hlt


section .data
cpu_name_str	dd 0, 0, 0,
				db 0
no_cpuid_str	asciiz "cpuid instruction is not supported."
no_ext_cpuid_str	asciiz "cpuid instruction does not support extension."
phys_addr_len_str	asciiz "physical address length: "
linear_add_len_str	asciiz "linear address length: "
proc_brand_str		times( 12 ) dd 0
no_long_mode_str	asciiz "No long mode support detected. "
no_apic_str			asciiz "No APIC on chip."
