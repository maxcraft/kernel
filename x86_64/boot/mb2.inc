%ifndef MULTIBOOT_HEADER
%define MULTIBOOT_HEADER 1

; /*  How many bytes from the start of the file we search for the header. */
%define MULTIBOOT_SEARCH                        32768
%define MULTIBOOT_HEADER_ALIGN                  8

; /*  The magic field should contain this. */
%define MULTIBOOT2_HEADER_MAGIC                 0xe85250d6

; /*  This should be in %eax. */
%define MULTIBOOT2_BOOTLOADER_MAGIC             0x36d76289

; /*  Alignment of multiboot modules. */
%define MULTIBOOT_MOD_ALIGN                     0x00001000

; /*  Alignment of the multiboot info structure. */
%define MULTIBOOT_INFO_ALIGN                    0x00000008

; /*  Flags set in the ’flags’ member of the multiboot header. */

%define MULTIBOOT_TAG_ALIGN                  8
%define MULTIBOOT_TAG_TYPE_END               0
%define MULTIBOOT_TAG_TYPE_CMDLINE           1
%define MULTIBOOT_TAG_TYPE_BOOT_LOADER_NAME  2
%define MULTIBOOT_TAG_TYPE_MODULE            3
%define MULTIBOOT_TAG_TYPE_BASIC_MEMINFO     4
%define MULTIBOOT_TAG_TYPE_BOOTDEV           5
%define MULTIBOOT_TAG_TYPE_MMAP              6
%define MULTIBOOT_TAG_TYPE_VBE               7
%define MULTIBOOT_TAG_TYPE_FRAMEBUFFER       8
%define MULTIBOOT_TAG_TYPE_ELF_SECTIONS      9
%define MULTIBOOT_TAG_TYPE_APM               10
%define MULTIBOOT_TAG_TYPE_EFI32             11
%define MULTIBOOT_TAG_TYPE_EFI64             12
%define MULTIBOOT_TAG_TYPE_SMBIOS            13
%define MULTIBOOT_TAG_TYPE_ACPI_OLD          14
%define MULTIBOOT_TAG_TYPE_ACPI_NEW          15
%define MULTIBOOT_TAG_TYPE_NETWORK           16
%define MULTIBOOT_TAG_TYPE_EFI_MMAP          17
%define MULTIBOOT_TAG_TYPE_EFI_BS            18
%define MULTIBOOT_TAG_TYPE_EFI32_IH          19
%define MULTIBOOT_TAG_TYPE_EFI64_IH          20
%define MULTIBOOT_TAG_TYPE_LOAD_BASE_ADDR    21

%define MULTIBOOT_HEADER_TAG_END  0
%define MULTIBOOT_HEADER_TAG_INFORMATION_REQUEST  1
%define MULTIBOOT_HEADER_TAG_ADDRESS  2
%define MULTIBOOT_HEADER_TAG_ENTRY_ADDRESS  3
%define MULTIBOOT_HEADER_TAG_CONSOLE_FLAGS  4
%define MULTIBOOT_HEADER_TAG_FRAMEBUFFER  5
%define MULTIBOOT_HEADER_TAG_MODULE_ALIGN  6
%define MULTIBOOT_HEADER_TAG_EFI_BS        7
%define MULTIBOOT_HEADER_TAG_ENTRY_ADDRESS_EFI32  8
%define MULTIBOOT_HEADER_TAG_ENTRY_ADDRESS_EFI64  9
%define MULTIBOOT_HEADER_TAG_RELOCATABLE  10

%define MULTIBOOT_ARCHITECTURE_I386  0
%define MULTIBOOT_ARCHITECTURE_MIPS32  4
%define MULTIBOOT_HEADER_TAG_OPTIONAL 1

%define MULTIBOOT_LOAD_PREFERENCE_NONE 0
%define MULTIBOOT_LOAD_PREFERENCE_LOW 1
%define MULTIBOOT_LOAD_PREFERENCE_HIGH 2

%define MULTIBOOT_CONSOLE_FLAGS_CONSOLE_REQUIRED 1
%define MULTIBOOT_CONSOLE_FLAGS_EGA_TEXT_SUPPORTED 2

%define MULTIBOOT_FRAMEBUFFER_TYPE_INDEXED 0
%define MULTIBOOT_FRAMEBUFFER_TYPE_RGB     1
%define MULTIBOOT_FRAMEBUFFER_TYPE_EGA_TEXT     2

%define MULTIBOOT_MEMORY_AVAILABLE              1
%define MULTIBOOT_MEMORY_RESERVED               2
%define MULTIBOOT_MEMORY_ACPI_RECLAIMABLE       3
%define MULTIBOOT_MEMORY_NVS                    4
%define MULTIBOOT_MEMORY_BADRAM                 5

struc multiboot_color
.red	resb 1
.green	resb 1
.blue	resb 1
endstruc

struc multiboot_mmap_entry
.addr	resq 1
.len	resq 1
.type	resd 1
.zero	resd 1
endstruc

struc multiboot_tag
.type	resd	1
.size	resd	1
endstruc

struc multiboot_tag_string
.type	resd	1
.size	resd	1
.string	resb	0
endstruc

struc multiboot_tag_module
.type		resd 1
.size		resd 1
.mod_start	resd 1
.mod_end	resd 1
.cmdline	resb 0
endstruc

struc multiboot_tag_basic_meminfo
.type	resd 1
.size	resd 1
.mem_lower	resd 1
.mem_upper	resd 1
endstruc

struc multiboot_tag_bootdev
.type	resd 1
.size	resd 1
.biosdev	resd 1
.slice	resd 1
.part	resd 1
endstruc

struc multiboot_tag_mmap
.type	resd 1
.size	resd 1
.entry_size	resd 1
.entry_version	resd 1
.entries resb 0
endstruc

struc multiboot_vbe_info_block
.external_specification	resb 512
endstruc

struc multiboot_vbe_mode_info_block
.external_specification	resb 256
endstruc

struc multiboot_tag_vbe
.type	resd 1
.size	resd 1

.vbe_mode	resw 1
.vbe_interface_seg	resw 1
.vbe_interface_off	resw 1
.vbe_interface_len	resw 1

;  struct multiboot_vbe_info_block vbe_control_info;
.vbe_control_info	resb 512
;  struct multiboot_vbe_mode_info_block vbe_mode_info;t
.vbe_mode_info		resb 256
endstruc

struc multiboot_tag_framebuffer
.multiboot_tag_framebuffer_common:
.type	resd 1
.size	resd 1

.framebuffer_addr	resq 1
.framebuffer_pitch	resd 1
.framebuffer_width	resd 1
.framebuffer_height	resd 1
.framebuffer_bpp	resb 1
.framebuffer_type	resb 1
.reserved	resw 1

.framebuffer_red_field_position	resb 1
.framebuffer_red_mask_size	resb 1
.framebuffer_green_field_position	resb 1
.framebuffer_green_mask_size	resb 1
.framebuffer_blue_field_position	resb 1
.framebuffer_blue_mask_size	resb 1

.framebuffer_palette_num_colors	equ .framebuffer_red_field_position ;resw 1
.framebuffer_palette equ .framebuffer_green_field_position ;resb 0
endstruc

struc multiboot_tag_elf_sections
.type	resd 1
.size	resd 1
.num	resd 1
.entsize	resd 1
.shndx	resd 1
.sections	resb 1
endstruc

struc multiboot_tag_apm
.type	resd 1
.size	resd 1
.version	resw 1
.cseg	resw 1
.offset	resd 1
.cseg_16	resw 1
.dseg	resw 1
.flags	resw 1
.cseg_len	resw 1
.cseg_16_len	resw 1
.dseg_len	resw 1
endstruc

struc multiboot_tag_efi32
.type	resd 1
.size	resd 1
.pointer	resd 1
endstruc

struc multiboot_tag_efi64
.type	resd 1
.size	resd 1
.pointer	resq 1
endstruc

struc multiboot_tag_smbios
.type	resd 1
.size	resd 1
.major	resb 1
.minor	resb 1
.reserved	resb 6
.tables	resb 0
endstruc

struc multiboot_tag_old_acpi
.type	resd 1
.size	resd 1
.rsdp	resb 0
endstruc

struc multiboot_tag_new_acpi
.type	resd 1
.size	resd 1
.rsdp	resb 0
endstruc

struc multiboot_tag_network
.type	resd 1
.size	resd 1
.dhcpack	resb 0
endstruc

struc multiboot_tag_efi_mmap
.type	resd 1
.size	resd 1
.descr_size	resd 1
.descr_vers	resd 1
.efi_mmap	resb 0
endstruc

struc multiboot_tag_efi32_ih
.type	resd 1
.size	resd 1
.pointer	resd 1
endstruc

struc multiboot_tag_efi64_ih
.type	resd 1
.size	resd 1
.pointer resq 1
endstruc

struc multiboot_tag_load_base_addr
.type	resd 1
.size	resd 1
.load_base_addr	resd 1
endstruc

struc elf64_header
.name 	resd 1 ; Section  name
.type	resd 1 ; Section  type
.attr	resq 1 ; Section  attributes
.addr	resq 1 ; Virtual  address  in  memory
.offset	resq 1 ; Offset  in  file
.size	resq 1 ; Size  of  section
.link	resd 1 ; Link  to  other  section
.info	resd 1 ; Miscellaneous  information
.addralign	resq 1 ; Address  alignment  boundary
.entsize	resq 1 ; Size  of  entries,  if  section  has  table 
endstruc

%endif
