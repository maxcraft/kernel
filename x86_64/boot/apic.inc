%ifndef APIC_INC
%define APIC_INC

; FEE0 0000H Reserved
; FEE0 0010H Reserved
; FEE0 0020H Local APIC ID Register Read/Write.
%define IA32_APIC_LOCAL_ID 20h
; FEE0 0030H Local APIC Version Register Read Only.
%define IA32_APIC_LOCAL_VERSION 30h
; FEE0 0040H Reserved
; FEE0 0050H Reserved
; FEE0 0060H Reserved
; FEE0 0070H Reserved
; FEE0 0080H Task Priority Register (TPR) Read/Write.
%define IA32_APIC_TASK_PRIORITY 80h
; FEE0 0090H Arbitration Priority Register (APR) Read Only.
%define IA32_APIC_ARB_PRIORITY 90h
; FEE0 00A0H Processor Priority Register (PPR) Read Only.
%define IA32_APIC_PROC_PRIORITY 0a0h
; FEE0 00B0H EOI Register Write Only.
%define IA32_APIC_EOI 0b0h
; FEE0 00C0H Remote Read Register (RRD) Read Only
%define IA32_APIC_RDR 0c0h
; FEE0 00D0H Logical Destination Register Read/Write.
%define IA32_APIC_LDR 0d0h
; FEE0 00E0H Destination Format Register Read/Write (see Section 10.6.2.2).
%define IA32_APIC_DFR 0e0h
; FEE0 00F0H Spurious Interrupt Vector Register Read/Write (see Section 10.9).
%define IA32_APIC_SPUR_IVR 0f0h
; FEE0 0100H In-Service Register (ISR); bits 31:0 Read Only.
%define IA32_APIC_ISR 0100h
; FEE0 0110H In-Service Register (ISR); bits 63:32 Read Only.
; FEE0 0120H In-Service Register (ISR); bits 95:64 Read Only.
; FEE0 0130H In-Service Register (ISR); bits 127:96 Read Only.
; FEE0 0140H In-Service Register (ISR); bits 159:128 Read Only.
; FEE0 0150H In-Service Register (ISR); bits 191:160 Read Only.
; FEE0 0160H In-Service Register (ISR); bits 223:192 Read Only.
; FEE0 0170H In-Service Register (ISR); bits 255:224 Read Only.
; FEE0 0180H Trigger Mode Register (TMR); bits 31:0 Read Only.
%define IA32_APIC_TMR 0180h
; FEE0 0190H Trigger Mode Register (TMR); bits 63:32 Read Only.
; FEE0 01A0H Trigger Mode Register (TMR); bits 95:64 Read Only.
; FEE0 01B0H Trigger Mode Register (TMR); bits 127:96 Read Only.
; FEE0 01C0H Trigger Mode Register (TMR); bits 159:128 Read Only.
; FEE0 01D0H Trigger Mode Register (TMR); bits 191:160 Read Only.
; FEE0 01E0H Trigger Mode Register (TMR); bits 223:192 Read Only.
; FEE0 01F0H Trigger Mode Register (TMR); bits 255:224 Read Only.
; FEE0 0200H Interrupt Request Register (IRR); bits 31:0 Read Only.
%define IA32_APIC_IRR 0200h
; FEE0 0210H Interrupt Request Register (IRR); bits 63:32 Read Only.
; FEE0 0220H Interrupt Request Register (IRR); bits 95:64 Read Only.
; FEE0 0230H Interrupt Request Register (IRR); bits 127:96 Read Only.
; FEE0 0240H Interrupt Request Register (IRR); bits 159:128 Read Only.
; FEE0 0250H Interrupt Request Register (IRR); bits 191:160 Read Only.
; FEE0 0260H Interrupt Request Register (IRR); bits 223:192 Read Only.
; FEE0 0270H Interrupt Request Register (IRR); bits 255:224 Read Only.
; FEE0 0280H Error Status Register Read Only.
%define IA32_APIC_ERROR_STATUS 0280h
; FEE0 0290H through FEE0 02E0H Reserved
; FEE0 02F0H LVT Corrected Machine Check Interrupt (CMCI) Register Read/Write.
%define IA32_APIC_LVT_CMCI 02f0h
; FEE0 0300H Interrupt Command Register (ICR); bits 0-31 Read/Write.
%define IA32_APIC_ICR 0300h
%define IA32_APIC_ICR_LOW 0300h
; FEE0 0310H Interrupt Command Register (ICR); bits 32-63 Read/Write.
%define IA32_APIC_ICR_HIGH 0310h
; FEE0 0320H LVT Timer Register Read/Write.
%define IA32_APIC_LVT_TIMER 0320h
; FEE0 0330H LVT Thermal Sensor Register Read/Write.
%define IA32_APIC_LVT_THERMAL 0330h
; FEE0 0340H LVT Performance Monitoring Counters Register Read/Write.
%define IA32_APIC_LVT_PERFORMANCE 0340h
; FEE0 0350H LVT LINT0 Register Read/Write.
%define IA32_APIC_LVT_LINT0 0350h
; FEE0 0360H LVT LINT1 Register Read/Write.
%define IA32_APIC_LVT_LINT1 0360h
; FEE0 0370H LVT Error Register Read/Write.
%define IA32_APIC_LVT_ERROR 0360h
; FEE0 0380H Initial Count Register (for Timer) Read/Write.
%define IA32_APIC_INIT_COUNTER 0380h
; FEE0 0390H Current Count Register (for Timer) Read Only.
%define IA32_APIC_CURR_COUNTER 0390h
; FEE0 03A0H through
; FEE0 03D0H Reserved
; FEE0 03E0H Divide Configuration Register (for Timer) Read/Write.
%define IA32_APIC_DCR 03e0h
; FEE0 03F0H Reserved

%macro apic_read 2-3 ebx
	mov		%2, dword [ %3 + %1 ]
%endmacro

%macro apic_write 2-3 ebx
	mov		dword [ %3 + %1 ], %2
%endmacro

%endif ; APIC_INC
