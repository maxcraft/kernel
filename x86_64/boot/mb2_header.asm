bits 32

section .multiboot_header
align 4
%include "boot/mb2.inc"

header_start:
	dd	MULTIBOOT2_HEADER_MAGIC ; magic
	dd	MULTIBOOT_ARCHITECTURE_I386 ; i386
	dd	header_end - header_start
	dd	-( MULTIBOOT2_HEADER_MAGIC + MULTIBOOT_ARCHITECTURE_I386 + ( header_end - header_start ) )

; end tag
	dd 0, 8

header_end:
