section .text
bits 32

global apic_base, apic_init

apic_init:
	mov		ecx, 1bh
	rdmsr

	and		eax, dword ~0fffh
	mov		dword[ apic_base ], eax
	mov		dword[ apic_base + 4 ], edx
	ret

apic_get_base:
	mov		eax, dword[ apic_base ]
	and		eax, dword ~0fffh
	mov		edx, dword[ apic_base + 4 ]
	ret

section .data

apic_base dq 0
