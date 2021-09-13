%include "boot/mb2.inc"
%include "boot/vga_text_32.inc"
%include "boot/string.inc"
%include "boot/apic.inc"
%include "lib_asm.inc"
%include "boot/ap_init.inc"
bits 32
global entry_point

section .text
extern check_cpu, print_reg
extern apic_init, apic_base
extern pit32_wait_ms

; ebx = memory map
; eax = mgic number
entry_point:
	mov		esp, stack_end
	mov		ebp, esp
	push	ebx
	push	eax

	call	vga_text_init
	call	vga_text_clear

	mov		al, 0x0f
	call	vga_text_set_color

	print	welcome_msg

	pop		eax

	cmp		eax, 0x36d76289
	jne		.not_multiboot

	; print	long_line
	call	check_cpu

	pop		ebx
	push	ebx

	; print_register ebx
	print	mem_msg
	; print_register ebx

	mov		eax, [ ebx ]
	push	eax
	mov		edi, mb2flags_str.value_h
	call	dword2str
	mov		ax, 0ah
	stosw

	print	mb2flags_str

	; mk_dd_hstr	[ ebx ], mb2flags_str.value
	; mk_dd_hstr	[ ebx + 4 ], mb2flags_str.value_h
	; print	mb2flags_str

	mov		ecx, 8

.mb2_loop:
	; mov		eax, dword [ ebx + ecx ]
	; mov		edi, mb2_tag_str.type
	; call	dword2hstr
	; mov		eax, dword [ ebx + ecx + 4 ]
	; mov		edi, mb2_tag_str.size
	; call	dword2hstr
	; mov		eax, dword [ ebx + ecx + 4 ]
	; mov		edi, mb2_tag_str.size_dec
	; call	dword2str
	;
	; xor		al, al
	; stosb
	; print	mb2_tag_str
	;
	; print( mb2_tag_str.tail )

	mov		eax, dword [ ebx + ecx ]
	print	[ eax * 4 + mb2_tag_type_str_tbl ]
	print	colon_str

	; print_register ecx

	mov		eax, dword [ ebx + ecx ]
	call	[ eax * 4 + mb2_tag_print_tbl ]

	print	endl

	mov		eax, dword [ ebx + ecx + 4 ]
	add		ecx, eax

	; align 8
	test	ecx, 7
	jz		.mb2_loop_cnt
	and		ecx, ~7
	add		ecx, 8

.mb2_loop_cnt:
	cmp		ecx, [ ebp - 8 ]
	jb		.mb2_loop

	; copy AP init code to 0x2000
	; cld
	; mov		esi, ap_init_test
	; mov		edi, REAL_BASE
	; mov		ecx, ap_init_test_end - ap_init_test
	; shr		ecx, 2
	; rep		movsd
	memcpyd		REAL_BASE, [ trampoline_section_addr ], [ trampoline_section_size ]
	sfence
	wbinvd


	; mov		eax, [ REAL_BASE + ap_hello2_str - ap_init_test ]
	; mov		eax, [ ( REAL_BASE + ap_hello_str - ap_init ) ]
	mov		eax, ap_hello_str
	sub		eax, ap_init
	mov		eax, [ eax + REAL_BASE ]
	cmp		al, 'H'
	jne		.invalid_ap_init

	; call second CPU

	call	apic_init

	; push	eax
	; print_register	eax
	; print_register	edx

	cmp		edx, 0
	jnz		.apic_too_high

	; pop		eax
	; hlt

	mov		ebx, eax
	; and		ebx, dword ~0fffh

	apic_read	IA32_APIC_LOCAL_ID, eax
	and		eax, 0FF000000h
	mov		dword [ boot_id ], eax

	print	boot_id_str
	print_register eax

	apic_read	IA32_APIC_SPUR_IVR, eax
	or		eax, 1 << 8
	apic_write	IA32_APIC_SPUR_IVR, eax

	print	svr_str
	print_register eax

	; TODO: make proper error handler
	; mov		eax, dword [ ebx + 370h ]
	; and		eax, ~0ffh
	; or		eax, 02h
	; mov		dword [ ebx + 370h ], eax
	; print	error_entry_str
	; print_register eax

	mov		eax, 0c4500h
	apic_write	IA32_APIC_ICR, eax
	xor		eax, eax
	apic_write	IA32_APIC_ICR_HIGH, eax
	sfence
	; call	wait_sec
	mov		ecx, 11
.loop_10ms:
	call	pit32_wait_ms
	loop	.loop_10ms

	mov		eax, 0c4600h | ( REAL_BASE >> 12 )
	apic_write	IA32_APIC_ICR_LOW, eax
	xor		eax, eax
	apic_write	IA32_APIC_ICR_HIGH, eax
	sfence

	mov		ecx, 211
.loop_200ms:
	call	pit32_wait_ms
	loop	.loop_200ms

	; call	wait_sec
	mov		eax, 0c4600h | ( REAL_BASE >> 12 )
	apic_write	IA32_APIC_ICR_LOW, eax
	xor		eax, eax
	apic_write	IA32_APIC_ICR_HIGH, eax
	sfence

	mov		ecx, 211
.loop_201ms:
	call	pit32_wait_ms
	loop	.loop_201ms
	call	wait_sec
	call	wait_sec

	; mov		eax, [ ap_hello_str ]
	; cmp		al, 'H'
	; jne		.invalid_ap_init

	; hlt


; 	mov		dword [ ebx + 280h ], 0
;
; 	mov		eax, dword [ ebx + 310h ]
; 	print_register	eax
; 	and		eax, 0x00ffffff
; 	or		eax, 1 << 24
; 	mov		dword [ ebx + 310h ], eax
;
; 	; 0x300)) & 0xfff00000) | 0x00C500;
; 	mov		eax, dword [ ebx + 300h ]
; 	print_register	eax
; 	and		eax, 0xfff00000
; 	or		eax, 0x00C500
; 	mov		dword [ ebx + 300h ], eax
; 	sfence
; 	; hlt
; 	; lapic_ptr + 0x300)) & (1 << 12
; .wait_ap_iti_conf:
; 	mfence
; 	mov		eax, dword [ ebx + 300h ]
; 	; print_register	eax
; 	test	eax, 1 << 12
; 	jz		.wait_ap_iti_conf
;
; 	mov		eax, dword [ ebx + 310h ]
; 	and		eax, 0x00ffffff
; 	or		eax, 1 << 24
; 	mov		dword [ ebx + 310h ], eax
;
; 	; 0x300)) & 0xfff00000) | 0x008500;
; 	mov		eax, dword [ ebx + 300h ]
; 	and		eax, 0xfff00000
; 	or		eax, 0x008500
; 	mov		dword [ ebx + 300h ], eax
; 	sfence
; 	; lapic_ptr + 0x300)) & (1 << 12
; .wait_ap_iti_conf2:
; 	mfence
; 	mov		eax, dword [ ebx + 300h ]
; 	test	eax, 1 << 12
; 	jz		.wait_ap_iti_conf2
;
;
; 	mov		dword [ ebx + 280h ], 0
; 	mov		eax, dword [ ebx + 310h ]
; 	and		eax, 0x00ffffff
; 	or		eax, 1 << 24
; 	mov		dword [ ebx + 310h ], eax
;
; 	mov		eax, dword [ ebx + 300h ]
; 	and		eax, 0xfff0f800
; 	or		eax, 0x000608
; 	mov		dword [ ebx + 300h ], eax


	print	halt_str


	hlt

.invalid_ap_init:
	print	invalid_ap_init_str
	print	space_str
	push	eax
	mov		eax, REAL_BASE
	print_dword
	pop		eax
	print	space_str
	print_register	eax
	mov		eax, ap_init
	print_register	eax
	hlt

.apic_too_high:
	print	apic_too_high_str
	hlt

.not_multiboot:
	print	not_multiboot_msg
	hlt

wait_sec:
	xor		al, al
	out		70h, al
	in		al, 71h
	mov		ah, al
.loop:
	xor		al, al
	out		70h, al
	in		al, 71h

	cmp		al, ah
	jz		.loop

	ret




print_tag_type_cmdline:           ;1
print_tag_type_boot_loader_name:  ;2
	print	multiboot_tag_string.string, ebx, ecx
	ret

print_tag_type_load_base_addr:    ;21
	print_dword	[ ebx + ecx + multiboot_tag_load_base_addr.load_base_addr ]
	ret

print_tag_type_module:            ;3
	print		module_at_str
	print_dword	[ ebx + ecx + multiboot_tag_module.mod_start ]
	print		dash_str
	print_dword	[ ebx + ecx + multiboot_tag_module.mod_end ]
	print		colon_str
	print		ebx, ecx, multiboot_tag_module.cmdline
	ret

print_tag_type_basic_meminfo:     ;4
	print		lomem_str
	print_dword_dec	[ ebx + ecx + multiboot_tag_basic_meminfo.mem_lower ]
	print		KB_str
	print		space_str
	print		himem_str
	print_dword_dec	[ ebx + ecx + multiboot_tag_basic_meminfo.mem_upper ]
	print		KB_str
	ret

print_tag_type_bootdev:           ;5
	print		biosdev_str
	print_dword	[ ebx + ecx + multiboot_tag_bootdev.biosdev ]
	print		space_str
	print		slice_str
	print_dword	[ ebx + ecx + multiboot_tag_bootdev.slice ]
	print		space_str
	print		part_str
	print_dword	[ ebx + ecx + multiboot_tag_bootdev.part ]
	ret

print_tag_type_mmap:              ;6
	print		version_str
	print_dword	[ ebx + ecx + multiboot_tag_mmap.entry_version ]
	print		space_str
	print		size_str
	print_dword	[ ebx + ecx + multiboot_tag_mmap.entry_size ]

	push		ebx
	push		ecx
	push		edx

	; init:
	; ebx - start of the structure
	; ecx - end of the structure
	add			ebx, ecx
	mov			ecx, [ ebx + multiboot_tag_mmap.size ]
	add			ecx, ebx

	; edx - size of an entry
	mov			edx, [ ebx + multiboot_tag_mmap.entry_size ]
	; ebx - the first entry
	add			ebx, multiboot_tag_mmap.entries

.entries_loop:
	cmp			ebx, ecx
	jae			.end_of_table

	; .addr	resq 1
	; .len	resq 1
	; .type	resd 1

	print		endl
	print		addr_str
	print_dword	[ ebx + multiboot_mmap_entry.addr + 4 ]
	print_dword	[ ebx + multiboot_mmap_entry.addr ]
	print		space_str

	print		len_str
	print_dword	[ ebx + multiboot_mmap_entry.len + 4 ]
	print_dword	[ ebx + multiboot_mmap_entry.len ]

	print		space_str
	print		type_str
	print_dword_dec [ ebx + multiboot_mmap_entry.type ]
	print		space_str

	mov			eax, [ ebx + multiboot_mmap_entry.type ]
	print		[ eax * 4 + mb2_mmap_type_str_tbl ]

	add			ebx, edx
	jmp			.entries_loop

.end_of_table:

	pop			edx
	pop			ecx
	pop			ebx
	ret

print_tag_type_vbe:               ;7
	ret

print_tag_type_framebuffer:       ;8
	print		addr_str
	print_dword	[ ebx + ecx + multiboot_tag_framebuffer.framebuffer_addr + 4 ]
	print_dword	[ ebx + ecx + multiboot_tag_framebuffer.framebuffer_addr ]
	ret

print_tag_type_elf_sections:      ;9
	print				space_str
	print				size_str
	print_dword_dec		[ ebx + ecx + multiboot_tag_elf_sections.size ]
	print				space_str
	print				number_str
	print_dword_dec		[ ebx + ecx + multiboot_tag_elf_sections.num ]
	print				space_str
	print				entry_size_str
	print_dword_dec		[ ebx + ecx + multiboot_tag_elf_sections.entsize ]
	print				space_str
	print				shndx_str
	print_dword_dec		[ ebx + ecx + multiboot_tag_elf_sections.shndx ]
	; print	endl

	push	ebx
	push	ecx
	push	edx

	add		ebx, ecx
	mov		edx,  multiboot_tag_elf_sections.sections
	mov		ecx, [ ebx + multiboot_tag_elf_sections.num ]
	dec		ecx
	add		edx, [ ebx + multiboot_tag_elf_sections.entsize ]
	; mov		ecx, 1

.entry_loop:
	print		endl


	push		edx
	mov			eax, [ ebx + multiboot_tag_elf_sections.shndx ]
	mul			dword [ ebx + multiboot_tag_elf_sections.entsize ]
	pop			edx

	mov			esi, [ ebx + eax + multiboot_tag_elf_sections.sections + elf64_header.addr ]
	add			esi, [ ebx + edx + elf64_header.name ]
	print
	print		space_str

	; print_dword	[ ebx + edx + elf64_header.name ]
	; print	space_str
	print_dword [ ebx + edx + elf64_header.type ]
	print	space_str

	print_dword	[ ebx + edx + elf64_header.addr + 4 ]
	print_dword [ ebx + edx + elf64_header.addr ]
	print	space_str

	print_dword	[ ebx + edx + elf64_header.offset + 4 ]
	print_dword [ ebx + edx + elf64_header.offset ]
	print	space_str

	print_dword	[ ebx + edx + elf64_header.size + 4 ]
	print_dword [ ebx + edx + elf64_header.size ]
	print	space_str

	push		ecx
	push		edx
	mov			eax, [ ebx + multiboot_tag_elf_sections.shndx ]
	mul			dword [ ebx + multiboot_tag_elf_sections.entsize ]
	pop			edx
	mov			esi, [ ebx + eax + multiboot_tag_elf_sections.sections + elf64_header.addr ]
	add			esi, [ ebx + edx + elf64_header.name ]
	; push		esi
	; print
	; print		endl
	; mov			esi, trampoline_section_name
	; print
	; pop			esi
	cmpstr		trampoline_section_name, esi, [ trampoline_section_name_len ]
	jnz			.skip_sect

	; print		endl
	; print		tesxt16_found_str
	push		eax
	mov			eax, [ ebx + edx + elf64_header.addr ]
	mov			[ trampoline_section_addr ], eax
	mov			eax, [ ebx + edx + elf64_header.addr + 4 ]
	mov			[ trampoline_section_addr + 4 ], eax
	; print		space_str
	; print_dword		[ trampoline_section_addr + 4 ]
	; print_dword		[ trampoline_section_addr ]

	mov			eax, [ ebx + edx + elf64_header.size ]
	mov			[ trampoline_section_size ], eax
	mov			eax, [ ebx + edx + elf64_header.size + 4 ]
	mov			[ trampoline_section_size + 4], eax
	; print		space_str
	; print_dword		[ trampoline_section_size + 4 ]
	; print_dword		[ trampoline_section_size ]

	pop			eax

.skip_sect:
	pop			ecx
	add		edx, [ ebx + multiboot_tag_elf_sections.entsize ]
	loop	.entry_loop_s

	pop		edx
	pop		ecx
	pop		ebx
	ret
.entry_loop_s:
	jmp		.entry_loop

print_tag_type_apm:               ;10
print_tag_type_efi32:             ;11
print_tag_type_efi64:             ;12
print_tag_type_smbios:            ;13
	ret

print_tag_type_acpi_old:          ;14
	ret

print_tag_type_acpi_new:          ;15
	ret

print_tag_type_network:           ;16
print_tag_type_efi_mmap:          ;17
print_tag_type_efi_bs:            ;18
print_tag_type_efi32_ih:          ;19
print_tag_type_efi64_ih:          ;20
print_tag_end:                    ;0
	ret

; bits 16
; align 4
; ap_init_test:
; 	mov		ds, cx
; 	; mov		si, ap_hello_str - ap_init_test
; 	mov		ax, 0b800h
; 	mov		es, ax
; 	; xor		di, di
; 	mov		di, 2 * 80 * 10
;
; 	mov		ah, 0f0h
;
; 	cld
; ; .print_loop:
; ; 	lodsb
; ; 	cmp		al, 0
; ; 	jz		.end_print
; ; 	stosw
; ; 	jmp		.print_loop
; ; .end_print:
; 	mov		al, 'H'
; 	stosb
; 	mov		al, 'i'
; 	stosb
; 	mov		al, 'H'
; 	stosb
; 	mov		al, 'i'
; 	stosb
; 	mov		al, 'H'
; 	stosb
; 	mov		al, 'i'
; 	stosb
; 	mov		al, 'H'
; 	stosb
; 	mov		al, 'i'
; 	stosb
; 	mov		al, 'H'
; 	stosb
; 	mov		al, 'i'
; 	stosb
; 	mov		al, 'H'
; 	stosb
; 	mov		al, 'i'
; 	stosb
; 	hlt
;
; ; ap_init_print_hello:
;
; ap_hello2_str	db "Hello from another CPU.", 0
; ap_init_test_end:


section .data
mb2_tag_print_tbl:
		dd print_tag_end                    ;0
		dd print_tag_type_cmdline           ;1
		dd print_tag_type_boot_loader_name  ;2
		dd print_tag_type_module            ;3
		dd print_tag_type_basic_meminfo     ;4
		dd print_tag_type_bootdev           ;5
		dd print_tag_type_mmap              ;6
		dd print_tag_type_vbe               ;7
		dd print_tag_type_framebuffer       ;8
		dd print_tag_type_elf_sections      ;9
		dd print_tag_type_apm               ;10
		dd print_tag_type_efi32             ;11
		dd print_tag_type_efi64             ;12
		dd print_tag_type_smbios            ;13
		dd print_tag_type_acpi_old          ;14
		dd print_tag_type_acpi_new          ;15
		dd print_tag_type_network           ;16
		dd print_tag_type_efi_mmap          ;17
		dd print_tag_type_efi_bs            ;18
		dd print_tag_type_efi32_ih          ;19
		dd print_tag_type_efi64_ih          ;20
		dd print_tag_type_load_base_addr    ;21

mb2_tag_type_str_tbl:
		dd multiboot_tag_type_end
		dd multiboot_tag_type_cmdline
		dd multiboot_tag_type_boot_loader_name
		dd multiboot_tag_type_module
		dd multiboot_tag_type_basic_meminfo
		dd multiboot_tag_type_bootdev
		dd multiboot_tag_type_mmap
		dd multiboot_tag_type_vbe
		dd multiboot_tag_type_framebuffer
		dd multiboot_tag_type_elf_sections
		dd multiboot_tag_type_apm
		dd multiboot_tag_type_efi32
		dd multiboot_tag_type_efi64
		dd multiboot_tag_type_smbios
		dd multiboot_tag_type_acpi_old
		dd multiboot_tag_type_acpi_new
		dd multiboot_tag_type_network
		dd multiboot_tag_type_efi_mmap
		dd multiboot_tag_type_efi_bs
		dd multiboot_tag_type_efi32_ih
		dd multiboot_tag_type_efi64_ih
		dd multiboot_tag_type_load_base_addr

mb2_mmap_type_str_tbl:
		dd multiboot_memory_zero_str
		dd multiboot_memory_available_str
		dd multiboot_memory_reserved_str
		dd multiboot_memory_acpi_reclaimable_str
		dd multiboot_memory_nvs_str
		dd multiboot_memory_badram_str

multiboot_tag_type_end				asciiz "End tag"
multiboot_tag_type_cmdline			asciiz "Cmd line tag"
multiboot_tag_type_boot_loader_name	asciiz "Boot loader name tag"
multiboot_tag_type_module			asciiz "Module tag"
multiboot_tag_type_basic_meminfo	asciiz "Basic meminfo tag"
multiboot_tag_type_bootdev			asciiz "Bootdev tag"
multiboot_tag_type_mmap				asciiz "Mmap tag"
multiboot_tag_type_vbe				asciiz "VBE tag"
multiboot_tag_type_framebuffer		asciiz "Framebuffer tag"
multiboot_tag_type_elf_sections		asciiz "ELF sections tag"
multiboot_tag_type_apm				asciiz "APM tag"
multiboot_tag_type_efi32			asciiz "EFI32 tag"
multiboot_tag_type_efi64			asciiz "EFI64 tag"
multiboot_tag_type_smbios			asciiz "SMBIOS tag"
multiboot_tag_type_acpi_old			asciiz "ACPI old tag"
multiboot_tag_type_acpi_new			asciiz "ACPI new tag"
multiboot_tag_type_network			asciiz "Network tag"
multiboot_tag_type_efi_mmap			asciiz "EFI mmap tag"
multiboot_tag_type_efi_bs			asciiz "EFI BS tag"
multiboot_tag_type_efi32_ih			asciiz "EFI32 IH tag"
multiboot_tag_type_efi64_ih			asciiz "EFI64 IH tag"
multiboot_tag_type_load_base_addr	asciiz "Load base addr tag"

multiboot_memory_zero_str				asciiz "ZERO"
multiboot_memory_available_str			asciiz "AVAILABLE"
multiboot_memory_reserved_str			asciiz "RESERVED"
multiboot_memory_acpi_reclaimable_str	asciiz "ACPI_RECLAIMABLE"
multiboot_memory_nvs_str				asciiz "NVS"
multiboot_memory_badram_str				asciiz "BADRAM"

trampoline_section_name				asciiz ".text16"
trampoline_section_name_len			dd trampoline_section_name_len - trampoline_section_name
trampoline_section_addr				dq 0
trampoline_section_size				dq 0




colon_str		asciiz ": "
module_at_str	asciiz "at "
dash_str		asciiz "-"
KB_str			asciiz "KB"

himem_str		asciiz "High mem: "
lomem_str		asciiz "Low mem: "

biosdev_str		asciiz "BIOS dev: "
slice_str		asciiz "slice: "
part_str		asciiz "part: "

version_str		asciiz "ver.: "
size_str		asciiz "size: "

addr_str		asciiz "addr: "
len_str			asciiz "length: "
type_str		asciiz "type: "
pitch_str		asciiz "pitch: "
width_str		asciiz "width: "
height_str		asciiz "height: "
bpp_str			asciiz "BPP: "
number_str		asciiz "Number: "
entry_size_str	asciiz "Entry size: "
shndx_str		asciiz "shndx: "

welcome_msg			asciiz "The kernel has been loaded into memeory.", 0x0a
; long_line	db	"----------------------------------------------------------------------------------------------------------------------------------------------------------", 0ah, 0
mem_msg				asciiz "Reading from multiboot2 info... "
not_multiboot_msg	asciiz "Loaded with non-multiboot2 bootloader.", 0x0a
apic_too_high_str	asciiz "APIC mapped too high.", 0ah
halt_str			asciiz "Halting BSP", 0ah
boot_id_str			asciiz "Boot id: "
error_entry_str		asciiz "Error entry str: "
svr_str				asciiz "SVR value: "
invalid_ap_init_str	asciiz "There is no ap init at "
tesxt16_found_str	asciiz "Found .text16 section: "


mb2flags_str	db "MB2 size: "
.value_h		times (8) db " "
.value			times (8) db " "
 				db 0ah, 0
mb2_tag_str		db "MB2 record: type: "
.type			times (8) db " "
				db " size: "
.size			times (8) db " "
				db " ("
.size_dec		times (10) db " "
				db 0
.tail			db ")", 0ah, 0
boot_id			dd 0

section .bss
align 8
stack_start:
	resd 2048
stack_end:
